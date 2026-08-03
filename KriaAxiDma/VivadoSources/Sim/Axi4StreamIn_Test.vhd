library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity Axi4StreamIn_Test is
--  Port ( );
end Axi4StreamIn_Test;

architecture Behavioral of Axi4StreamIn_Test is
  constant c_DEPTH : integer := 4;
  constant c_WIDTH : integer := 8;
  
  signal r_reset : std_logic := '0';
  signal r_clock : std_logic := '0';
  
  signal r_s_axis_tdata   : std_logic_vector(c_WIDTH - 1 downto 0);
  signal r_s_axis_tkeep   : std_logic_vector((c_WIDTH / 4) - 1 downto 0);
  signal r_s_axis_tvalid  : std_logic;
  signal r_s_axis_tlast   : std_logic;
  signal r_s_axis_tready : std_logic;
  
  signal r_m_axis_tdata  : std_logic_vector(c_WIDTH - 1 downto 0);
  signal r_m_axis_tkeep  : std_logic_vector((c_WIDTH / 4) - 1 downto 0);
  signal r_m_axis_tvalid : std_logic;
  signal r_m_axis_tlast  : std_logic;
  signal r_m_axis_tready : std_logic;
  signal r_m_axis_tready  : std_logic := '0';
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
      m_axis_tready => r_m_axis_tready,
      m_axis_tready => r_m_axis_tready
    );
  
  process is
  begin
    r_reset <= '1';
    wait for 5 ns;
    r_reset <= '0';
    wait for 5 ns;
    r_axis_tdata_in  <= x"10";
    wait for 10 ns;
    r_axis_tvalid_in <= '1';
    wait for 10 ns;
    r_axis_tdata_in  <= x"0F";
    wait for 10 ns;
    r_axis_tdata_in  <= x"0E";
    r_axis_tready_in <= '1';
    wait for 10 ns;
    r_axis_tdata_in  <= x"0D";
    wait for 10 ns;
    r_axis_tdata_in  <= x"0C";
    wait for 10 ns;
    r_axis_tdata_in  <= x"0B";
    wait for 10 ns;
    r_axis_tdata_in  <= x"0A";
    wait for 10 ns;
    wait for 10 ns;
    wait for 10 ns;
    wait for 10 ns;
    wait for 10 ns;
    wait for 10 ns;
    wait for 10 ns;
    wait for 10 ns;
    finish;
 
  end process;

end Behavioral;
