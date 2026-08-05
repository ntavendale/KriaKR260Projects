library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity Axi4StreamIn_Test is
--  Port ( );
end Axi4StreamIn_Test;

architecture Behavioral of Axi4StreamIn_Test is
  constant c_DEPTH : integer := 16;
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
  Unit_Under_Test : entity work.Axi4StreamIn
    generic map (
      FIFO_WIDTH => c_WIDTH,
      FIFO_DEPTH => c_DEPTH
      )
    port map (
      s_axis_aclk => r_clock,
      s_axis_aresetn => r_reset,
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
    r_reset <= '0';
    wait until r_clock = '1';
    r_reset <= '1';
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"00000010";
    wait until r_clock = '1';
    r_s_axis_tvalid <= '1';
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"0000000F";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"0000000E";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"0000000D";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"0000000C";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"0000000B";
    r_m_axis_tready <= '1';
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"0000000A";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"00000009";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"00000008";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"00000007";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"00000006";
    wait until r_clock = '1';
    r_s_axis_tdata  <= x"00000005";
    wait until r_clock = '1';
    wait until r_clock = '1';
    wait until r_clock = '1';
    wait until r_clock = '1';
    wait until r_clock = '1';
    wait until r_clock = '1';
    wait until r_clock = '1';
    wait until r_clock = '1';
    finish;
  end process;

end Behavioral;
