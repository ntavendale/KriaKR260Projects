-- Copyright 2025 Nigel Tavendale
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this code 
-- associated documentation files (the "Code"), to deal in the Code without restriction, including 
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
-- and/or sell copies of the Code, and to permit persons to whom the Code is furnished to do so, 
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial 
-- portions of the Code.
--
-- THE CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
-- TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
-- SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CODE OR THE USE OR 
-- OTHER DEALINGS IN THE CODE.
library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity nexys_a7_demo_top is
  port (
    clk         : in std_logic;
    btnC        : in std_logic;
    CPU_RESETN  : in std_logic; -- active low
    sw          : in std_logic_vector(15 downto 0);
    an          : out std_logic_vector(7 downto 0);
    seg         : out std_logic_vector(6 downto 0); -- GFEDCAB
    RsRx        : in std_logic; 
    RsTx        : out std_logic
  );
end nexys_a7_demo_top;

architecture rtl of nexys_a7_demo_top is
  constant cCLOCKS_PER_ANODE: Natural := 100000;
  signal r_resetn              : std_logic := '1'; --active low
  signal r_reset               : std_logic := '0';
  signal r_send_btn            : std_logic := '0';
  signal r_send_button_pressed : std_logic := '0';
  signal r_switches            : std_logic_vector (15 downto 0) := (others => '0');
  
  signal r_input_data: std_logic_vector (31 downto 0) := (others => '0');
  signal r_display_data: std_logic_vector (31 downto 0) := (others => '0');
  signal r_input_data_valid: std_logic := '0';
  
  signal r_send_switch_data: std_logic := '0';
  signal r_tx_transmitting: std_logic := '0';
  signal r_tx_done: std_logic := '0';
  signal r_output_data: std_logic_vector (31 downto 0) := (others => '0');
  
  
  component generic_debounce_filter is
    generic (
      DEBOUNCE_LIMIT : integer := 1000000;
      SIGNAl_COUNT: Integer := 1);
    port (
      i_clk           : in std_logic;
      i_noisy_signal  : in std_logic_vector(SIGNAl_COUNT -1 downto 0);
      o_debounced     : out std_logic_vector(SIGNAl_COUNT -1 downto 0)
      );
  end component;
  
  component uart32_rx is
    generic (
      -- Needs to be set correctly for clock and baud rate
      -- For Basys3 it's 100MHz cklock / 115200 baud rate.
      CLKS_PER_BIT : Integer := 868     -- Needs to be set correctly
    );
    port (
      i_clk        : in  std_logic; -- clock signal.
      i_Serial     : in  std_logic; -- serial data in
      o_data_valid : out std_logic; -- driven high when Data Value has been deserialized
      o_data       : out std_logic_vector(31 downto 0) -- deserialized data out
    );
  end component;
  
  component uart32_tx is
    generic (
      -- Needs to be set correctly for clock and baud rate
      -- For Basys3 it's 100MHz cklock / 115200 baud rate.
      CLKS_PER_BIT : integer := 868     -- Needs to be set correctly
    );
    port (
      i_clk             : in  std_logic;
      i_data_valid      : in  std_logic; -- Driven high when data value in i_TX_Byte ready to be serialized
      i_data_to_send    : in  std_logic_vector(31 downto 0);
      o_transmitting    : out std_logic;
      o_serial_out      : out std_logic; -- Serial Output
      o_tx_done         : out std_logic
    );
end component;
  
  component seven_segment_display is
    generic (CYCLES_PER_ANODE : natural);
    port (
      i_Clock     : in std_logic;
      i_Reset     : in std_logic;
      i_Displayed : in std_logic_vector(31 downto 0); -- compact BCD. 4 BCD Values of 4 bits each
      o_Anodes    : out std_logic_vector(7 downto 0);
      o_Segments  : out std_logic_vector(6 downto 0)
    );
  end component;
begin

  -- debounce button c to suppluy reset signal
  generic_debounce_filter_btn: generic_debounce_filter
    generic map (SIGNAl_COUNT => 2)
    port map (
      i_clk => clk,
      i_noisy_signal(0) => btnC,
      i_noisy_signal(1) => CPU_RESETN,
      o_debounced(0) => r_send_btn,
      o_debounced(1) => r_resetn
   );
   r_reset <= not r_resetn;
   
   generic_debounce_filter_sw: generic_debounce_filter
    generic map (SIGNAl_COUNT => 16)
    port map (
      i_clk => clk,
      i_noisy_signal => sw,
      o_debounced => r_switches
   );
   r_output_data(31 downto 24) <=  r_switches(7 downto 0);
   r_output_data(23 downto 16) <=  r_switches(15 downto 8);
   r_output_data(15 downto 0) <=  r_switches;
   
   uart32_rx_0: uart32_rx
     port map (
      i_clk => clk,
      i_Serial => RsRx,
      o_data_valid => r_input_data_valid,
      o_data => r_input_data
    );
    
    r_display_data <= r_input_data when r_input_data_valid = '1';
    
    uart32_tx_0: uart32_tx
     port map (
      i_clk => clk,
      i_data_valid => r_send_switch_data, 
      i_data_to_send => r_output_data,
      o_transmitting => r_tx_transmitting,
      o_serial_out => RsTx,
      o_tx_done => r_tx_done
    );
    
    r_send_switch_data <= '0' when (r_send_button_pressed = '0' or r_tx_done = '1') else '1';
    
    p_check_send: process(r_send_btn)
    begin  
      r_send_button_pressed <= '0';
      if rising_edge(r_send_btn) then
        r_send_button_pressed <= '1';
      end if;
    end process;
    
    seven_segment_display_0: seven_segment_display
     generic map (CYCLES_PER_ANODE => cCLOCKS_PER_ANODE)
     port map (
      i_Clock => clk,
      i_Reset => r_reset,
      i_Displayed => r_display_data,
      o_Anodes => an,
      o_Segments => seg
    );
end rtl;