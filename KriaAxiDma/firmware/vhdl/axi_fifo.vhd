library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Starting internal test
--[156549.159588] start_transfer(RX1,0) (len=00000400)
--[156549.159605] wait_for_transfer(RX1,0)
--[156549.159624] start_transfer(TX0,0) (len=00000400)
--[156549.159635] wait_for_transfer(TX0,0)
--[156549.159652] xilinx-vdma a0000000.dma: Channel 00000000b5e39c8f has errors 10, cdr 0 tdr 0
--[156549.167951] sync_callback
--[156549.167967] sync_callback
--[156549.168064] Internal test complete

entity axi_fifo is
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
    s_axis_tlast : in std_logic;
    s_axis_tdata  : in std_logic_vector(FIFO_WIDTH - 1 downto 0);
    s_axis_tkeep  : in std_logic_vector((FIFO_WIDTH / 8) - 1 downto 0);

    -- AXI master (output_ interface
    m_axis_tready : in std_logic;
    m_axis_tvalid : out std_logic;
    m_axis_tlast : out std_logic := '0';
    m_axis_tdata  : out std_logic_vector(FIFO_WIDTH - 1 downto 0);
    m_axis_tkeep  : out std_logic_vector((FIFO_WIDTH / 8) - 1 downto 0) := (others => '1')
  );
end axi_fifo;

architecture rtl of axi_fifo is

  -- The FIFO is full when the RAM contains ram_depth - 1 elements
  type fifo_array_type is array (0 to FIFO_DEPTH - 1) of std_logic_vector(s_axis_tdata'range);
  signal fifo_array : fifo_array_type;

  -- Newest element at head, oldest element at tail
  subtype index_type is natural range fifo_array_type'range;
  signal head : index_type;
  signal tail : index_type;
  signal count : index_type := 0;
  signal count_p1 : index_type;

  -- Internal versions of entity signals with mode "out"
  signal r_ready_to_receive : std_logic := '0';
  
  signal r_ready_to_send : std_logic := '0';

  -- True the clock cycle after a simultaneous read and write
  signal read_while_write_p1 : std_logic;

  -- Increment or wrap the index if this transaction is valid
  function next_index(
    index : index_type;
    ready : std_logic;
    valid : std_logic) return index_type is
  begin
    if ready = '1' and valid = '1' then
      if index = index_type'high then
        return index_type'low;
      else
        return index + 1;
      end if;
    end if;

    return index;
  end function;

  -- Logic for handling the head and tail signals
  procedure index_proc(
    signal clk : in std_logic;
    signal rstn : in std_logic;
    signal index : inout index_type;
    signal ready : in std_logic;
    signal valid : in std_logic) is
  begin
      if rising_edge(clk) then
        if rstn = '0' then
          index <= index_type'low;
        else
          index <= next_index(index, ready, valid);
        end if;
      end if;
  end procedure;

begin

  -- Copy internal signals to output
  s_axis_tready <= r_ready_to_receive;
  m_axis_tvalid <= r_ready_to_send;

  -- Update head index on write
  PROC_HEAD : index_proc(aclk, aresetn, head, r_ready_to_receive, s_axis_tvalid);

  -- Update tail index on read
  PROC_TAIL : index_proc(aclk, aresetn, tail, m_axis_tready, r_ready_to_send);

  -- Write to and read from the RAM
  PROC_RAM : process(aclk)
  begin
    if rising_edge(aclk) then
      if (r_ready_to_receive = '1' and s_axis_tvalid = '1') then
        fifo_array(head) <= s_axis_tdata;
      end if;  
      if (r_ready_to_send = '1' and m_axis_tready = '1') then
        m_axis_tdata <= fifo_array(next_index(tail, m_axis_tready, r_ready_to_send));
      end if;  
    end if;
  end process;

  -- Find the number of elements in the fifo array
  PROC_COUNT : process(head, tail)
  begin
    if (r_ready_to_receive = '1' and s_axis_tvalid = '1') then
      if head < tail then
        count <= head - tail + FIFO_DEPTH;
      else
        count <= head - tail;
      end if;  
    end if;
  end process;

  -- Delay the count by one clock cycles
  PROC_COUNT_P1 : process(aclk)
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        count_p1 <= 0;
      else
        count_p1 <= count;
      end if;
    end if;
  end process;

  -- Set in_ready when the RAM isn't full
  PROC_IN_READY : process(count, aresetn)
  begin
    if (count < FIFO_DEPTH - 1) and (aresetn /= '0') then
      r_ready_to_receive <= '1';
    else
      r_ready_to_receive <= '0';
    end if;
  end process;

  -- Detect simultaneous read and write operations
  PROC_READ_WHILE_WRITE_P1: process(aclk)
  begin
    if rising_edge(aclk) then
      if aresetn = '0' then
        read_while_write_p1 <= '0';

      else
        read_while_write_p1 <= '0';
        if r_ready_to_receive = '1' and s_axis_tvalid = '1' and
          m_axis_tready = '1' and r_ready_to_send = '1' then
          read_while_write_p1 <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Set out_valid when the RAM outputs valid data
  PROC_OUT_VALID : process(count, count_p1, read_while_write_p1, aresetn)
  begin
    -- If the RAM is empty or was empty in the prev cycle
    if count = 0 or count_p1 = 0 or aresetn = '0' then
      r_ready_to_send <= '0';
    -- If simultaneous read and write when almost empty
    elsif count = 1 and read_while_write_p1 = '1' then
      r_ready_to_send <= '0';
    else  
      r_ready_to_send <= '1';
    end if;
  end process;

end architecture;