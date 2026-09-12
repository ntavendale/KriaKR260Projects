-- Copyright 2025 Nigel Tavendale
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this code 
-- associated documentation files (the "Code"), to deal in the Code without restriction, including 
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
-- and/or sell copies of the Code, and to permit persons to whom the Code is furnished to do so, 
-- subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or substantial 
-- portions of the Code.
--
-- THE CODE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
-- TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
-- SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE CODE OR THE USE OR 
-- OTHER DEALINGS IN THE CODE.
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pmod_ssd is
  generic (CYCLES_PER_ANODE : natural);
  port (
    i_clk       : in std_logic;
    i_resetn    : in std_logic;
    i_displayed : in std_logic_vector(7 downto 0); -- compact BCD. 4 BCD Values of 4 bits each
    o_anode     : out std_logic;
    o_ssd       : out std_logic_vector(6 downto 0)
  );
end pmod_ssd;

architecture rtl of pmod_ssd is
  constant ANODE_COUNT: natural := 2;
  signal bcd_value: std_logic_vector(3 downto 0);
  signal r_counter : natural range 0 to CYCLES_PER_ANODE - 1;  
  signal anode_counter: natural range 0 to ANODE_COUNT -1 ;
begin
  process(bcd_value)
  begin
    -- Segment turned on when it's value is driven LOW!
    -- On basys 3 the seven segments of ecach display egments are labled A to G 
    --(https://digilent.com/reference/programmable-logic/basys-3/reference-manual)
    -- segment vector values are  GFEDCBA in the o_Segments output vector 
    case bcd_value is
      when "0000" => o_ssd <= "0111111"; -- "0"     
      when "0001" => o_ssd <= "0000110"; -- "1"
      when "0010" => o_ssd <= "1011011"; -- "2"
      when "0011" => o_ssd <= "1001111"; -- "3"
      when "0100" => o_ssd <= "1100110"; -- "4"
      when "0101" => o_ssd <= "1101101"; -- "5"
       
      when "0110" => o_ssd <= "1111101"; -- "6" 
      when "0111" => o_ssd <= "0100111"; -- "7" 
      when "1000" => o_ssd <= "1111111"; -- "8"     
      when "1001" => o_ssd <= "1101111"; -- "9" 
      when "1010" => o_ssd <= "1011111"; -- a
      when "1011" => o_ssd <= "1111100"; -- b
      when "1100" => o_ssd <= "0111001"; -- C
      when "1101" => o_ssd <= "1011110"; -- d
      when "1110" => o_ssd <= "1111001"; -- E
      when "1111" => o_ssd <= "1110001"; -- F
      when others => o_ssd <= "1110001"; -- F
    end case;
  end process;
  
   -- Counting the number to be displayed on 4-digit 7-segment Display 
  -- on Basys 3 FPGA board  
  process (i_clk, i_resetn)
  begin
    if i_resetn = '0' then
      anode_counter <= 0;
      r_Counter     <= 0;
    elsif rising_edge(i_clk) then
      if r_Counter = CYCLES_PER_ANODE - 1 then
        -- reset counter
        r_Counter <= 0;
        -- change anode
        if anode_counter = ANODE_COUNT -1 then
          anode_counter <= 0;
        else  
          anode_counter <= anode_counter + 1;
        end if;
      else
        r_Counter <= r_Counter + 1;     
      end if;
    end if;    
  end process;
  
  process(anode_counter)
  begin
    -- Digit turned on when it's anode is driven LOW!
    case anode_counter is
      when 0 => 
        o_anode  <= '1'; -- C1 (Left)
        bcd_value <= i_displayed(7 downto 4);
      when 1 => 
        o_anode  <= '0'; -- C@ (Right)
        bcd_value <= i_displayed(3 downto 0);
    end case;
  end process;  
  
end rtl;

