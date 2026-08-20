library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axi_stream_io_tb is
--  Port ( );
end axi_stream_io_tb;

architecture Behavioral of axi_stream_io_tb is
  constant c_DEPTH : integer := 8;
  constant c_WIDTH : integer := 32;
  
  signal r_reset : std_logic := '1';
  signal r_clock : std_logic := '0';
  
  signal r_s_axis_tdata   : std_logic_vector(c_WIDTH - 1 downto 0) := (others => '0');
  signal r_s_axis_tkeep   : std_logic_vector((c_WIDTH / 8) - 1 downto 0) := (others => '1');
  signal r_s_axis_tvalid  : std_logic := '0';
  signal r_s_axis_tlast   : std_logic := '0';
  signal r_s_axis_tready  : std_logic;
  
  signal r_m_axis_tdata  : std_logic_vector(c_WIDTH - 1 downto 0);
  signal r_m_axis_tkeep  : std_logic_vector((c_WIDTH / 8) - 1 downto 0);
  signal r_m_axis_tvalid : std_logic;
  signal r_m_axis_tlast  : std_logic;
  signal r_m_axis_tready : std_logic := '0';
begin
  r_clock <= not r_clock after 5 ns;  
  Unit_Under_Test : entity work.axi_stream_io
    generic map (
      FIFO_WIDTH => c_WIDTH,
      FIFO_DEPTH => c_DEPTH
      )
    port map (
      aclk => r_clock,
      aresetn => r_reset,
      -- AXI4-Stream Slave Interface (data in)
      s_axis_tdata => r_s_axis_tdata,
      s_axis_tkeep => r_s_axis_tkeep,
      s_axis_tvalid => r_s_axis_tvalid,
      s_axis_tlast => r_s_axis_tlast,
      s_axis_tready => r_s_axis_tready,
      
      m_axis_tdata => r_m_axis_tdata,
      m_axis_tkeep => r_m_axis_tkeep,
      m_axis_tvalid => r_m_axis_tvalid,
      m_axis_tlast => r_m_axis_tlast,
      m_axis_tready => r_m_axis_tready
    );
  
  process is
  begin
    r_reset <= '0'; -- Axi4 Stream FIFO has an active low reset.
    wait until r_CLOCK = '1';
    r_reset <= '1';
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"000000F0";
    wait until r_CLOCK = '1';
    r_s_axis_tvalid <= '1';
    if r_s_axis_tready /= '1' then 
      wait until r_s_axis_tready = '1';
    end if;
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"000000E0";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"000000D0";
    r_m_axis_tready <= '1';
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"000000C0";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"000000B0";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"000000A0";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000090";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000080";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000070";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000060";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000050";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000040";
    r_m_axis_tready <= '0';
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000030";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000020";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000010";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"0000000F";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"0000000E";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"0000000D";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"0000000C";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"0000000B";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"0000000A";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000009";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000008";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000007";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000006";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000005";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000004";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000003";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000002";
    wait until r_CLOCK = '1';
    r_s_axis_tdata  <= x"00000001";
    wait until r_CLOCK = '1';
    
    finish;
  end process;
end Behavioral;
