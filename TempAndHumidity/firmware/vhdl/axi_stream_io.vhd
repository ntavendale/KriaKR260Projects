library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- We are taking an axit stream and pipeing if right back out again as a FIFO
-- We indicate on an external periheral, in this cas a Digilent Pmod 8LD 
-- with 8 high brightness LEDs (https://digilent.com/shop/pmod-8ld-eight-high-brightness-leds/)
-- each time a TLAST come through indicating a transfer is going through.

-- Doesn't Vivado supply an Axi FIFO IP block? 
-- Yes it does, but not the code to go woith it. The point of this is to learn how DMA
-- and Axi streaming works and to do that I wrote my own Axi Stream IO block in VHDL 
-- which I then added to the block diagram. 
-- To work with external peripherals in the futurte I need to be able to get the data off the 
-- stream myself and strsam the replies back.  
  
entity axi_stream_io is
  generic (
    FIFO_WIDTH: integer := 32;
    FIFO_DEPTH: integer := 128
  );
  port (
    aclk          : in  std_logic;
    aresetn       : in  std_logic; -- active low reset

    -- AXI slave (input) interface
    s_axis_tready : out std_logic := '0';
    s_axis_tvalid : in std_logic;
    s_axis_tlast  : in std_logic;
    s_axis_tdata  : in std_logic_vector(FIFO_WIDTH - 1 downto 0);
    s_axis_tkeep  : in std_logic_vector((FIFO_WIDTH / 8) - 1 downto 0);
    
    -- AXI master (output_ interface
    m_axis_tready : in std_logic;
    m_axis_tvalid : out std_logic;
    m_axis_tlast : out std_logic := '0';
    m_axis_tdata  : out std_logic_vector(FIFO_WIDTH - 1 downto 0);
    m_axis_tkeep  : out std_logic_vector((FIFO_WIDTH / 8) - 1 downto 0) := (others => '1');
    
    -- PMOD1 OUTPUTS
    pmod_1_01: out std_logic;
    pmod_1_02: out std_logic;
    pmod_1_03: out std_logic;
    pmod_1_04: out std_logic;
    pmod_1_07: out std_logic;
    pmod_1_08: out std_logic;
    pmod_1_09: out std_logic;
    pmod_1_10: out std_logic
  );
end axi_stream_io;

architecture rtl of axi_stream_io is
  signal r_fifo_reset      : std_logic;
  signal r_write_enabled   : std_logic := '0';
  signal r_read_enabled    : std_logic := '0';
  signal r_fifo_read_valid : std_logic := '0';
  signal r_fifo_full       : std_logic := '0';
  signal r_fifo_empty      : std_logic := '0';
  signal r_s_axis_tdata    : std_logic_vector(FIFO_WIDTH downto 0);
  signal r_m_axis_tdata    : std_logic_vector(FIFO_WIDTH downto 0);
  
  signal r_led_state       : std_logic_vector(7 downto 0) := (others => '0');
begin
  r_fifo_reset <= not aresetn;
  -- slave signals (input)
  s_axis_tready <= '1' when r_fifo_full = '0' else '0';
  r_write_enabled <= s_axis_tvalid;
  r_s_axis_tdata(FIFO_WIDTH - 1 downto 0) <= s_axis_tdata(FIFO_WIDTH - 1 downto 0);
  r_s_axis_tdata(FIFO_WIDTH) <= s_axis_tlast;
  
  -- master signals (output)
  r_read_enabled <= m_axis_tready;
  m_axis_tvalid <= r_fifo_read_valid;
  
  m_axis_tdata(FIFO_WIDTH - 1 downto 0) <= r_m_axis_tdata(FIFO_WIDTH - 1 downto 0);
  m_axis_tlast <= r_m_axis_tdata(FIFO_WIDTH) when r_fifo_read_valid = '1' else '0';

  FIFO : entity work.ring_buffer_fifo
    generic map (
      FIFO_WIDTH => FIFO_WIDTH + 1, -- + 1 for the tlast flag
      FIFO_DEPTH => FIFO_DEPTH)
    port map (
      i_clk    => aclk,
      i_reset => r_fifo_reset,
      i_write_enabled => r_write_enabled,
      i_write_data => r_s_axis_tdata,
      -- Read port
      i_read_enabled => r_read_enabled,
      o_empty => r_fifo_empty,
      o_full => r_fifo_full,
      o_read_valid => r_fifo_read_valid,
      o_read_data => r_m_axis_tdata);
      
  SET_LED: process(s_axis_tlast)
  begin
    -- light only one LED ata time
    if rising_edge(s_axis_tlast) then
      if r_led_state = (r_led_state'range => '0') then
        r_led_state <= "00000001";
      else
        r_led_state <= std_logic_vector( shift_left(unsigned(r_led_state), 1) );
      end if; 
    end if;
  end process;
  
  -- Map the eight element vector to tthe PMOD ports to drive the external peripheral
  -- in this cas a Digilent Pmod 8LD with 8 high brightness LEDs 
  -- https://digilent.com/shop/pmod-8ld-eight-high-brightness-leds/ 
  pmod_1_01 <= r_led_state(0);
  pmod_1_02 <= r_led_state(1);
  pmod_1_03 <= r_led_state(2);
  pmod_1_04 <= r_led_state(3);
  
  pmod_1_07 <= r_led_state(4);
  pmod_1_08 <= r_led_state(5);
  pmod_1_09 <= r_led_state(6);
  pmod_1_10 <= r_led_state(7);    
     
end rtl;
