library ieee;
use ieee.std_logic_1164.all;

--Starting internal test
--[156549.159588] start_transfer(RX1,0) (len=00000400)
--[156549.159605] wait_for_transfer(RX1,0)
--[156549.159624] start_transfer(TX0,0) (len=00000400)
--[156549.159635] wait_for_transfer(TX0,0)
--[156549.159652] xilinx-vdma a0000000.dma: Channel 00000000b5e39c8f has errors 10, cdr 0 tdr 0
--[156549.167951] sync_callback
--[156549.167967] sync_callback
--[156549.168064] Internal test complete

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
    m_axis_tkeep  : out std_logic_vector((FIFO_WIDTH / 8) - 1 downto 0) := (others => '1')
  );
end axi_stream_io;

architecture rtl of axi_stream_io is
  signal r_fifo_reset: std_logic;
  signal r_write_enabled : std_logic := '0';
  signal r_read_enabled : std_logic := '0';
  signal r_fifo_read_valid : std_logic := '0';
  signal r_fifo_full : std_logic := '0';
  signal r_fifo_empty : std_logic := '0';
begin
  r_fifo_reset <= not aresetn;
  -- slave signals (input)
  s_axis_tready <= '1' when r_fifo_full = '0' else '0';
  r_write_enabled <= s_axis_tvalid;
  
  -- master signals (output)
  r_read_enabled <= m_axis_tready;
  m_axis_tvalid <= r_fifo_read_valid;

  FIFO : entity work.ring_buffer_fifo
    generic map (
      FIFO_WIDTH => FIFO_WIDTH,
      FIFO_DEPTH => FIFO_DEPTH)
    port map (
      i_clk    => aclk,
      i_reset => r_fifo_reset,
      i_write_enabled => r_write_enabled,
      i_write_data => s_axis_tdata,
      -- Read port
      i_read_enabled => r_read_enabled,
      o_empty => r_fifo_empty,
      o_full => r_fifo_full,
      o_read_valid => r_fifo_read_valid,
      o_read_data => m_axis_tdata);
      
end rtl;
