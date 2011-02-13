----------------------------------------------------------------------------------
-- Memory for input signal after FFT.
-- Copyright (C) 2011  Andrew Karpenkov
--
-- This library is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this library; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
-- USA
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library work;
use work.params.All;

entity in_mem is
Port 	 ( clk : in  STD_LOGIC;				  -- global clock
			rst : in  STD_LOGIC;				  -- reset signal
			symb_freq_en_a : in  STD_LOGIC; -- enable signal for write port of RAM
			symb_freq_wr : in  STD_LOGIC;   -- enable for write data after FFT block
 			symb_freq_adr_wr : in unsigned(9 downto 0):="0000000000"; -- address for write port
			in_fft_re  : std_logic_VECTOR(26 downto 0); -- I channel after FFT block
			in_fft_im  : std_logic_VECTOR(26 downto 0); -- Q channel after FFT block
			symb_freq_en_b : in  STD_LOGIC; -- enable signal for read port of RAM
			symb_freq_adr_rd : in unsigned(9 downto 0):="0000000000"; -- address for read port
			data_fft_re : out signed(26 downto 0); -- I channel after FFT block
			data_fft_im : out signed(26 downto 0) -- Q channel after FFT block
		 );
end in_mem;

architecture Behavioral of in_mem is

-- Array of input signal after FFT
type symbol_freq_type is array (0 to Ts_samples - 1) of signed(26 downto 0);
signal symb_freq_re, symb_freq_im  : symbol_freq_type;


begin


-- Write input signal after FFT into memory
process (clk)
begin
   if rising_edge(clk) then
	if(rst = '0') then
      if (symb_freq_en_a = '1') then
         if (symb_freq_wr = '1') then
            symb_freq_re(to_integer(symb_freq_adr_wr)) <= signed(in_fft_re);
         end if;
      end if;
	end if;
   end if;
end process;
process (clk)
begin
   if rising_edge(clk) then
	if(rst = '0') then
      if (symb_freq_en_a = '1') then
         if (symb_freq_wr = '1') then
            symb_freq_im(to_integer(symb_freq_adr_wr)) <= signed(in_fft_im);
         end if;
      end if;
	end if;
   end if;
end process;
-- Read input signal after FFT from memory
process (clk)
begin
   if rising_edge(clk) then
	if(rst = '0') then
      if (symb_freq_en_b = '1') then
         data_fft_re <= symb_freq_re(to_integer(symb_freq_adr_rd));
      end if;
	end if;
   end if;
end process;
process (clk)
begin
   if rising_edge(clk) then
	if(rst = '0') then
      if (symb_freq_en_b = '1') then
         data_fft_im <= symb_freq_im(to_integer(symb_freq_adr_rd));
      end if;
	end if;
   end if;
end process;

end Behavioral;

