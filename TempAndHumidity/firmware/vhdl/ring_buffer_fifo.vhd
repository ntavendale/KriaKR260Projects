library ieee;
use ieee.std_logic_1164.all;

entity ring_buffer_fifo is
  generic (
    FIFO_WIDTH : Integer := 32;
    FIFO_DEPTH : Integer := 128
  );
  port (
    i_clk   : in std_logic;
    i_reset : in std_logic;
  
    -- Write port
    i_write_enabled : in std_logic;
    i_write_data    : in std_logic_vector(FIFO_WIDTH - 1 downto 0);
  
    -- Read port:
    -- if using this fifo pull i_read_enabled high to indicate that 
    -- a data point is being read, and removed, from the head
    i_read_enabled : in std_logic;  
    -- there is valid data in the head positionrt that can be read 
    -- and o_read_data will contain it 
    o_read_valid   : out std_logic := '0'; 
    o_read_data    : out std_logic_vector(FIFO_WIDTH - 1 downto 0);
  
    -- Flags
    o_empty      : out std_logic;
    o_empty_next : out std_logic; -- fifo not empty yet, but will be on next read
    o_full       : out std_logic;
    o_full_next  : out std_logic;-- fifo not full yet, but will be on next write
  
    -- The number of data elements in the FIFO
    o_element_count : out Integer range FIFO_DEPTH - 1 downto 0
  );
end ring_buffer_fifo;

architecture rtl of ring_buffer_fifo is
  type fifo_array_type is array (0 to FIFO_DEPTH - 1) of std_logic_vector(i_write_data'range);
  
  signal fifo_array : fifo_array_type;
  
  -- NOTE: In VHDL a subtype is a base type paired with a specific constraint.
  --       In this case an Integer restricted to values from 0 to FIFO_DEPTH - 1
  --       which is the range of the fifo_array_type above
  subtype index_type is Integer range fifo_array_type'range;
  
  signal r_head : index_type := 0;
  signal r_tail : index_type := 0;
  
  signal r_empty         : std_logic := '1';
  signal r_full          : std_logic := '0';
  signal r_element_count : Integer range FIFO_DEPTH - 1 downto 0;
  
  -- Increment and wrap
  procedure IncremantIndex(signal index : inout index_type) is
  begin
    if index = index_type'high then
      index <= index_type'low;
    else
      index <= index + 1;
    end if;
  end procedure;
begin
  -- Copy internal signals to output
  o_empty <= r_empty;
  o_full <= r_full;
  o_element_count <= r_element_count;
  
  -- Set the full/empty indicator flags
  r_empty <= '1' when r_element_count = 0 else '0';
  o_empty_next <= '1' when r_element_count <= 1 else '0';
  r_full <= '1' when r_element_count >= FIFO_DEPTH - 1 else '0';
  o_full_next <= '1' when r_element_count >= FIFO_DEPTH - 2 else '0';

  -- Process to incrment head pointer and ensure it 
  -- does not overwrite
  PROC_HEAD : process(i_clk)
  begin  
    if rising_edge(i_clk) then
      if i_reset = '1' then
        r_head <= 0;
      else 
        -- check r_full to prevent overwrites
        if i_write_enabled = '1' and r_full = '0' then
          IncremantIndex(r_head);
        end if;
      end if;
    end if;
  end process;  
  -- Process to incrment tail pointer and ensure that 
  -- we indicate if there is valid data to read
  PROC_TAIL : process(i_clk)
  begin  
    if rising_edge(i_clk) then
      if i_reset = '1' then
        r_tail <= 0;
        o_read_valid <= '0';
      else
        -- check r_empty to prevent reading empty data
        if i_read_enabled = '1' and r_empty = '0' then
          IncremantIndex(r_tail);
          o_read_valid <= '1'; -- indicate read data is valid since we inremented
        else
          -- If we don't increment then o_read_data vector 
          -- does not contain valid data
          o_read_valid <= '0';
        end if;
      end if;
    end if;
  end process;

  PROC_FIFO : process(i_clk)
  begin
    if rising_edge(i_clk) then
      -- Don't update if full or i_write_enabled is low. 
      -- Otherwise we just continually overwrite the 
      -- r_head slot with new data.
      if i_write_enabled = '1' and r_full = '0' then
        fifo_array(r_head) <= i_write_data;
      end if;

      if (i_read_enabled = '1') then
        if (r_empty = '0') then
          o_read_data <= fifo_array(r_tail);
        end if;  
      end if;
    end if;
  end process;
  
  -- Update the element count
  PROC_COUNT : process(r_head, r_tail)
  begin
    if r_head < r_tail then
      r_element_count <= r_head - r_tail + FIFO_DEPTH;
    else
      r_element_count <= r_head - r_tail;
    end if;
  end process;
end rtl;
