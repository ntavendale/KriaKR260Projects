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
    DATA_WIDTH: Integer := 32
  );
  port (
    aclk          : in  std_logic;
    aresetn       : in  std_logic; -- active low reset

    -- AXI slave (input) interface
    s_axis_tready : out std_logic := '0';
    s_axis_tvalid : in std_logic;
    s_axis_tlast  : in std_logic;
    s_axis_tdata  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_axis_tkeep  : in std_logic_vector((DATA_WIDTH/8) - 1 downto 0);
    
    -- AXI master (output_ interface
    m_axis_tready : in std_logic;
    m_axis_tvalid : out std_logic;
    m_axis_tlast : out std_logic := '0';
    m_axis_tdata  : out std_logic_vector(DATA_WIDTH -1 downto 0);
    m_axis_tkeep  : out std_logic_vector((DATA_WIDTH/8) - 1 downto 0) := (others => '1');

    serial_clk  : inout std_logic;
    serial_data : inout std_logic;
    
    -- PMOD_SSD (PMOD 2 & 3 Lower)
    ssd: out STD_LOGIC_VECTOR(6 downto 0);
    SsdDigitSelect: out std_logic;

    -- PMOD4 OUTPUTS
    led: out std_logic_vector(7 downto 0)
  );
end axi_stream_io;

architecture rtl of axi_stream_io is
  constant cHUMIDITY_RESOLUTION : Integer range 0 to 14 :=  14;  -- Humidity resolution in bits (must be 14, 11, or 8)
  constant cTEMPERATURE_RESOLUTION: Integer range 0 to 14 := 14; -- Temperature resolution in bits (must be 14 or 11)
  signal r_s_axis_tdata    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal r_m_axis_tdata    : std_logic_vector(DATA_WIDTH - 1 downto 0);
  
  signal r_led_state       : std_logic_vector(7 downto 0) := (others => '0');
  signal r_responded       : STD_LOGIC := '0';
  
  signal r_resolution           : std_logic_vector(15 downto 0) := x"0E0E"; -- Upper Byte = Temperature, Lower Byte = Humidity
  signal r_display_humidity_res : std_logic := '0';
  signal r_dispalyed_resolution : std_logic_vector(7 downto 0) := "00010100"; -- 2 BCD Values of 4 bits each

  signal r_ack_error: std_logic;
  signal r_relative_humidity: std_logic_vector(cHUMIDITY_RESOLUTION - 1 downto 0);
  signal r_temperature: std_logic_vector(cTEMPERATURE_RESOLUTION - 1 downto 0);
  signal r_output_data: std_logic_vector (31 downto 0) := (others => '0');

  component pmod_ssd is
    generic (CYCLES_PER_ANODE : natural);
    port (
      i_clk       : in std_logic;
      i_resetn    : in std_logic;
      i_displayed : in std_logic_vector(7 downto 0); -- compact BCD. 2 BCD Values of 4 bits each
      o_anode     : out std_logic;
      o_ssd       : out std_logic_vector(6 downto 0)
    );
  end component;

  component pmod_hygrometer is
    generic (
      sys_clk_freq            : Integer := 100_000_000;       --input clock speed from user logic in Hz
      HUMIDITY_RESOLUTION     : Integer range 0 to 14 := cHUMIDITY_RESOLUTION;  --RH resolution in bits (must be 14, 11, or 8)
      TEMPERATURE_RESOLUTION  : Integer range 0 to 14 := cTEMPERATURE_RESOLUTION); --temperature resolution in bits (must be 14 or 11)
    port (
      clk               : in    std_logic;                                               --system clock
      reset_n           : in    std_logic;                                               --asynchronous active-low reset
      temp_resolution   : in    std_logic_vector(7 downto 0);                            -- user set temp resolution 
      humid_resolution  : in    std_logic_vector(7 downto 0);                            -- user set humid resolution
      scl               : inout std_logic;                                               --I2C serial clock
      sda               : inout std_logic;                                               --I2C serial data
      i2c_ack_err       : out   std_logic;                                               --I2C slave acknowledge error flag
      relative_humidity : out   std_logic_vector(cHUMIDITY_RESOLUTION - 1 downto 0);      --relative humidity data obtained
      temperature       : out   std_logic_vector(cTEMPERATURE_RESOLUTION  - 1 downto 0)); --temperature data obtained
    end component;
begin
  -- slave signals (input)
  s_axis_tready <= '1';
  r_s_axis_tdata <= s_axis_tdata;
    
  m_axis_tdata <= r_m_axis_tdata;

  resolution_display: pmod_ssd
    generic map (CYCLES_PER_ANODE => 250000)
    port map (
      i_clk => aclk,
      i_resetn => aresetn,
      i_displayed => r_dispalyed_resolution, -- compact BCD. 2 BCD Values of 4 bits each
      o_anode => SsdDigitSelect,
      o_ssd => ssd
    );

  pmod_hygro: pmod_hygrometer
      port map (
        clk  => aclk,
        reset_n => aresetn,
        temp_resolution => r_resolution(15 downto 8),
        humid_resolution => r_resolution(7 downto 0),
        scl => serial_clk,
        sda => serial_data,
        i2c_ack_err => r_ack_error,
        relative_humidity => r_relative_humidity,
        temperature => r_temperature
    );
    -- the most significant bits hold the data. The LSBs are always 0   
    r_output_data(31 downto (32 - cHUMIDITY_RESOLUTION)) <=  r_temperature;
    r_output_data((32 - cHUMIDITY_RESOLUTION) -1 downto 16) <=  (others => '0');
    r_output_data(15 downto (16-cTEMPERATURE_RESOLUTION)) <=  r_relative_humidity;
    r_output_data((16-cTEMPERATURE_RESOLUTION)-1 downto 0) <=  (others => '0');

  p_SET_OUTPUT: process(aclk, aresetn)
  begin
    if aresetn = '0' then
      r_responded <= '0';
    elsif rising_edge(aclk) then
      -- send response
      if (r_responded = '0' and m_axis_tready = '1' and s_axis_tlast = '1') then
        m_axis_tlast <='1';
        m_axis_tvalid <= '1';
        r_m_axis_tdata <= r_output_data;
        m_axis_tkeep <= (others => '1');
        r_responded <= '1';
      else
        m_axis_tlast <='0';
        m_axis_tvalid <= '0';
        r_responded <= '0';
      end if;  

      -- Set resolution display
      if (r_display_humidity_res = '1') then
        --Humidity
        if r_resolution(7 downto 0) = x"08" then
          r_dispalyed_resolution <= "00001000";
        elsif r_resolution(7 downto 0) = x"0B" then
          r_dispalyed_resolution <= "00010001";
        else
          r_dispalyed_resolution <= "00010100";
        end if;
      else 
        --Temperature
        if r_resolution(15 downto 8) = x"0B" then
          r_dispalyed_resolution <= "00010001";
        else
          r_dispalyed_resolution <= "00010100";
        end if; 
      end if;
    end if;
  end process;
      
  p_SIGNAL_DATA: process(s_axis_tlast)
  begin
    if rising_edge(s_axis_tlast) then
      -- light only one LED ata time
      if (r_led_state = (r_led_state'range => '0') or (r_led_state = "10000000")) then
        r_led_state <= "00000001";
      else
        r_led_state <= std_logic_vector( shift_left(unsigned(r_led_state), 1) );
      end if; 
    end if;
  end process;

  p_PROCESS_CMD: process(aclk)
  begin  
    if rising_edge(aclk) then
      if s_axis_tlast = '1' then
        if (r_s_axis_tdata(DATA_WIDTH - 1 downto (DATA_WIDTH - 8)) = x"01") then
          -- Set Resolution
          r_resolution  <= r_s_axis_tdata(15 downto 0);
        elsif (r_s_axis_tdata(DATA_WIDTH - 1 downto (DATA_WIDTH - 8)) = x"02") then
          -- set display data type
          r_display_humidity_res <= r_s_axis_tdata(0);
        end if;
      end if;  
    end if; 
  end process;
  
  -- Map the eight element vector to tthe PMOD ports to drive the external peripheral
  -- in this cas a Digilent Pmod 8LD with 8 high brightness LEDs 
  -- https://digilent.com/shop/pmod-8ld-eight-high-brightness-leds/ 
  led <= r_led_state;
end rtl;
