library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity ring_buffer_fifo_tb is
--  Port ( );
end ring_buffer_fifo_tb;

architecture Behavioral of ring_buffer_fifo_tb is
  constant c_WIDTH : Integer := 32;
  constant c_DEPTH : Integer := 8;
  
  signal r_reset : std_logic := '0';
  signal r_clock : std_logic := '0';
  signal r_write_enabled : std_logic := '0';
  signal r_write_data  : std_logic_vector(c_WIDTH - 1 downto 0);
  signal r_read_enabled : std_logic := '0';
  signal r_read_valid : std_logic := '0';
  signal r_read_data : std_logic_vector(c_WIDTH - 1 downto 0);
  
  signal r_empty      : std_logic;
  signal r_empty_next : std_logic; -- fifo not empty yet, but will be on next read
  signal r_full       : std_logic;
  signal r_full_next  : std_logic; -- fifo not full yet, but will be on next write
  signal r_element_count : Integer;
begin
  -- Set up coverage bins
  
  r_clock <= not r_clock after 5 ns;  
  Unit_Under_Test : entity work.ring_buffer_fifo
    generic map (
      FIFO_WIDTH => c_WIDTH,
      FIFO_DEPTH => c_DEPTH
    )
    port map (
      i_clk => r_clock,
      i_reset => r_reset,
      i_write_enabled => r_write_enabled,
      i_write_data => r_write_data,
      -- Read port
      i_read_enabled => r_read_enabled,
      o_read_valid => r_read_valid,
      o_read_data => r_read_data,
      o_empty => r_empty,
      o_empty_next => r_empty_next,
      o_full => r_full,
      o_full_next => r_full_next,
      -- The number of data elements in the FIFO
      o_element_count => r_element_count
   );
   
 process is
  begin
    wait until r_CLOCK = '1';
    r_write_data  <= x"000000F0";
    wait until r_CLOCK = '1';
    r_write_data  <= x"000000E0";
    wait until r_CLOCK = '1';
    r_write_data  <= x"000000D0";
    wait until r_CLOCK = '1';
    r_write_data  <= x"000000C0";
    wait until r_CLOCK = '1';
    r_write_enabled <= '1';
    r_write_data  <= x"000000B0";
    wait until r_CLOCK = '1';
    r_write_data  <= x"000000A0";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000090";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000080";
    wait until r_CLOCK = '1';
    r_read_enabled <= '1';
    r_write_enabled <= '0';
    r_write_data  <= x"00000070";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000060";
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    wait until r_CLOCK = '1';
    r_read_enabled <= '0';
    r_write_data  <= x"00000050";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000040";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000030";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000020";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000010";
    wait until r_CLOCK = '1';
    r_write_data  <= x"0000000F";
    wait until r_CLOCK = '1';
    r_write_data  <= x"0000000E";
    wait until r_CLOCK = '1';
    r_write_data  <= x"0000000D";
    wait until r_CLOCK = '1';
    r_write_data  <= x"0000000C";
    wait until r_CLOCK = '1';
    r_write_data  <= x"0000000B";
    wait until r_CLOCK = '1';
    r_write_data  <= x"0000000A";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000009";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000008";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000007";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000006";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000005";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000004";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000003";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000002";
    wait until r_CLOCK = '1';
    r_write_data  <= x"00000001";
    wait until r_CLOCK = '1';
    finish;
  end process;  

end Behavioral;
