library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- We want to take data in on an AXI4 stream load it into a FIFO
entity AXI4StreamIn is
  generic (
    FIFO_WIDTH: integer := 32;
    FIFO_DEPTH: integer := 128
   );
  port (
    -- Vivado is very fussy about the nameing conventions and the 
    -- block diagram editor won't recognise this as an axi4 stream 
    -- input unless it structly follows vivado's naming conventions
    
    -- Control signals  
    s_axis_aclk          : in  std_logic;
    s_axis_aresetn       : in  std_logic; -- active low reset
    
    -- AXI4-Stream Slave Interface (data in)
    s_axis_tdata  : in std_logic_vector(FIFO_WIDTH - 1 downto 0);
    s_axis_tkeep  : in std_logic_vector((FIFO_WIDTH / 8) - 1 downto 0);
    s_axis_tvalid : in std_logic;
    s_axis_tlast  : in std_logic;
    s_axis_tready : out std_logic;
    
    -- AXI4-Stream Master Interface (data out)
    m_axis_tdata  : out std_logic_vector(FIFO_WIDTH - 1 downto 0);
    m_axis_tkeep  : out std_logic_vector((FIFO_WIDTH / 8) - 1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tlast  : out std_logic;
    m_axis_tready : in std_logic
  );
end AXI4StreamIn;

architecture rtl of AXI4StreamIn is
  constant DEPTH_BITS : integer := integer(ceil(log2(real(FIFO_DEPTH)))); -- number of bits needed to store index
  signal wr_index : natural range 0 to (FIFO_DEPTH - 1) := 0;
  signal rd_index : natural range 0 to (FIFO_DEPTH - 1) := 0;
  signal r_count : natural range 0 to FIFO_DEPTH := 0;  -- 1 extra to go to DEPTH
  signal r_fifo_full  : std_logic := '0';
  signal r_fifo_empty : std_logic := '1';
  -- FIFO array types and signals
  type t_fifo_array is array (0 to FIFO_DEPTH - 1) of std_logic_vector(FIFO_WIDTH - 1 downto 0);
  signal r_fifo_data : t_fifo_array; -- the actual data array
  
begin
  -- Synchronous Process for Handshaking
  p_fifo_process: process(s_axis_aclk)
  begin
    if rising_edge(s_axis_aclk) then
       if s_axis_aresetn = '0' then
         wr_index <= 0;
         rd_index <= 0;
         r_count <= 0;
       else
         if (s_axis_tvalid = '1' and m_axis_tready = '0' and r_fifo_full = '0') then
           -- Data comming in but not wanted and we have room for it
            r_count <= r_count + 1;
         elsif (s_axis_tvalid = '0' and m_axis_tready = '1' and r_fifo_empty = '0') then
           -- Data wanted but not comming in
            r_count <= r_count - 1;
         end if;
         
         -- Keep track of the write index and controls roll-over
         -- Sender has valid data and we are not full
         -- This new wr_index value will be applied at the end 
         -- of this process block to be used the NEXT time the process
         -- block runs (the next rising edge)
        if (s_axis_tvalid = '1' and r_fifo_full = '0') then
          if wr_index = FIFO_DEPTH-1 then
            wr_index <= 0;
          else
            wr_index <= wr_index + 1;
          end if;
        end if;
 
        -- Keeps track of the read index (and controls roll-over)
        -- Receiver resdy for data and we are not empty        
        -- This new rd_index value will be applied at the end 
        -- of this process block to be used the NEXT time the process
        -- block runs (the next rising edge) 
        if (m_axis_tready = '1' and r_fifo_empty = '0') then
          if rd_index = FIFO_DEPTH-1 then
            rd_index <= 0;
          else
            rd_index <= rd_index + 1;
          end if;
        end if;
        -- Note that wr_index is not the updated value from above. 
        -- in vhdl all of the updates to signals happen in parallell 
        -- at the end of the process block so the wr_index value will be 
        -- the value from the last rising edge.  
        if s_axis_tvalid = '1' and r_fifo_full = '0' then
          r_fifo_data(wr_index) <= s_axis_tdata;
        end if;
       end if;
     end if;
  end process;
  
  m_axis_tdata <= r_fifo_data(rd_index);
  m_axis_tkeep <= (others => '1'); -- all 4 bytes are part of data
  
  r_fifo_full <= '1' when r_count = FIFO_DEPTH  else '0';
  r_fifo_empty <= '1' when r_count = 0 else '0';
  
  s_axis_tready <= '0' when r_count = FIFO_DEPTH  else '1'; 
  m_axis_tvalid <= '0' when r_count = 0 else '1';
  
  m_axis_tlast <= r_fifo_empty;
  
end rtl;
