----------------------------------------------------------------------------------
-- Searching preamble for 802.16e.
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
library work;
use work.params.All;

entity search_preamble is
Port 	 ( clk : in  STD_LOGIC;				  -- global clock
			rst : in  STD_LOGIC;				  -- reset signal
			dv_fft: in std_logic;			  -- data valid signal from FFT block
			preamble_N : out std_logic_VECTOR(6 downto 0); -- preamble of current frame
			symb_freq_adr_rd : inout std_logic_VECTOR(9 downto 0):=(others => '0'); -- address for read port
			symb_freq_adr_wr : in std_logic_VECTOR(9 downto 0):=(others => '0'); -- address for write port
			data_fft_re : in std_ulogic_vector(26 downto 0);
			data_fft_im : in std_ulogic_vector(26 downto 0)
		 );
end search_preamble;

architecture Behavioral of search_preamble is

--type preamble_sum_type is array (0 to preamble_count - 1) of signed(36 downto 0);
signal preamble_sum_re, preamble_sum_im : signed(36 downto 0);
signal preamble_sum_re_buf, preamble_sum_im_buf : signed(72 downto 0):=CONV_SIGNED(0,73);
signal preamble_nibble : std_logic_vector(3 downto 0); -- byte from array of preambles
signal preamble_adr : integer:=0; -- number of byte from array of preambles (from 0 to 4103)
signal preamble_N_buf : integer:=0; -- preamble index (from 0 to 113)
signal preamble : std_logic_vector(3 downto 0); -- octet of preamble
signal count_shift : std_logic_vector(1 downto 0); -- counter of shift register for preamble
signal load_shift : std_logic; -- load enable for shift register
type preamble_stages_type is (INIT,WORK);
signal preamble_stages : preamble_stages_type:=INIT;
signal preamble_nibble_N : integer:=0; -- number of curent nibble;
signal preamble_A : signed(73 downto 0);

begin

process (clk)
begin
if rising_edge(clk) then
	preamble_nibble <= preambles_rom(conv_integer(preamble_adr));
end if;
end process;

process (clk)
begin
if rising_edge(clk) then
	if(rst = '1') then
		count_shift <= (others => '0');
		preamble <= (others => '0');
	else
		if (load_shift = '1') then
			-- load register
				preamble <= preamble_nibble (3 downto 0);
				count_shift <=(others => '0');
		else
			-- shift register
			preamble <= preamble(2 downto 0) & '0';
			count_shift <=  count_shift + 1;
		end if;
		
	end if;
end if;
end process;

-- Searching correct preamble
process (clk)
begin
if rising_edge(clk) then
	if(rst = '1') then
		load_shift <= '1';
		preamble_adr <= 0;
		symb_freq_adr_rd <= (others => '0');

		preamble_sum_re <= CONV_SIGNED(0,37);
		preamble_sum_im <= CONV_SIGNED(0,37);
		preamble_A <= CONV_SIGNED(0,74);

	else
		case (preamble_stages) is
			when INIT => if(dv_fft = '1' and symb_freq_adr_wr = 430) then --need to add start signal for searching preambles from top level file
								preamble_stages <= WORK;
								symb_freq_adr_rd <= symb_freq_adr_rd + 3;
								load_shift<= '0';	
 							 else
								load_shift<= '1';
								symb_freq_adr_rd <= conv_std_logic_vector(86,10);
								preamble_adr <= 0;
								preamble_nibble_N <= 0;
								preamble_N_buf <= 0;
								
								if (preamble_A < (preamble_sum_re_buf + preamble_sum_im_buf)) then
									preamble_A <= preamble_sum_re_buf + preamble_sum_im_buf;
									preamble_N <= conv_std_logic_vector(preamble_N_buf - 1,7);
								end if;
							 end if;
			when WORK =>
							-- Convolution with current preamble defined by preamble_N_buf signal
							if(preamble_nibble_N = 71 and count_shift = "11") then
								preamble_sum_re <= CONV_SIGNED(0,37);
								preamble_sum_im <= CONV_SIGNED(0,37);
								if (preamble(3) = '1') then
									preamble_sum_re_buf <= (preamble_sum_re - signed(data_fft_re))*(preamble_sum_re - signed(data_fft_re));
									preamble_sum_im_buf <= (preamble_sum_im - signed(data_fft_im))*(preamble_sum_im - signed(data_fft_im));
								else
									preamble_sum_re_buf <= (preamble_sum_re + signed(data_fft_re))*(preamble_sum_re + signed(data_fft_re));
									preamble_sum_im_buf <= (preamble_sum_im + signed(data_fft_im))*(preamble_sum_im + signed(data_fft_im));
								end if;
							else
								if (symb_freq_adr_rd = 515) then
									null;
								else
									if (preamble(3) = '1') then
										preamble_sum_re <= preamble_sum_re - signed(data_fft_re);
										preamble_sum_im <= preamble_sum_im - signed(data_fft_im);
									else
										preamble_sum_re <= preamble_sum_re + signed(data_fft_re);
										preamble_sum_im <= preamble_sum_im + signed(data_fft_im);
									end if;
								end if;			
							end if;
							-- loading data into shift register and controling convolution
							case (count_shift) is
								when "00" => symb_freq_adr_rd <= symb_freq_adr_rd + 3;
												if(preamble_nibble_N = 0) then 
													if (preamble_A < (preamble_sum_re_buf + preamble_sum_im_buf)) then
														preamble_A <= preamble_sum_re_buf + preamble_sum_im_buf;
														preamble_N <= conv_std_logic_vector(preamble_N_buf - 1,7);
													end if;
												end if;								
								
								when "01" => symb_freq_adr_rd <= symb_freq_adr_rd + 3;
												preamble_nibble_N <= preamble_nibble_N + 1;
												if (preamble_adr < 8093) then
													preamble_adr <= preamble_adr + 1;
												else
													preamble_adr <= 0;
												end if;
								when "10" => load_shift<= '1';
												if(preamble_nibble_N = 71) then
													case (preamble_N_buf) is
														when 0 to 30  => symb_freq_adr_rd <= conv_std_logic_vector(86,10);
														when 31 to 62 => symb_freq_adr_rd <= conv_std_logic_vector(87,10);
														when 63 to 94 => symb_freq_adr_rd <= conv_std_logic_vector(88,10);
														when 95 | 98 | 101 | 104 | 107 | 110 => symb_freq_adr_rd <= conv_std_logic_vector(86,10);
														when 96 | 99 | 102 | 105 | 108 | 111 => symb_freq_adr_rd <= conv_std_logic_vector(87,10);
														when 97 | 100 | 103 | 106 | 109 | 112 => symb_freq_adr_rd <= conv_std_logic_vector(88,10);
														when others => null;
													end case;
												else symb_freq_adr_rd <= symb_freq_adr_rd + 3; end if;
								when "11" => load_shift<= '0';
												 symb_freq_adr_rd <= symb_freq_adr_rd + 3;
												 if(preamble_nibble_N = 71) then									 
													preamble_N_buf <= preamble_N_buf + 1;
													preamble_nibble_N <= 0;
													if(preamble_N_buf=113) then preamble_stages <= INIT; end if;
												 end if;
								when others => null;
							end case;
		
			when others => null;
		end case;
	end if;
end if;
end process;

end Behavioral;

