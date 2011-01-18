----------------------------------------------------------------------------------
-- Searching preamble symbol for 802.16e.
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

entity top is
Port 	 ( clk : in  STD_LOGIC;
			adc_clk : in STD_LOGIC;
			rst: IN std_logic;
			adc_re : in  STD_LOGIC_VECTOR (15 downto 0);
			adc_im : in  STD_LOGIC_VECTOR (15 downto 0);
         data : out  STD_LOGIC_VECTOR (7 downto 0)
			);
end top;

architecture Behavioral of top is

component ifft
	port (
	clk: IN std_logic;
	start: IN std_logic;
	xn_re: IN std_logic_VECTOR(15 downto 0);
	xn_im: IN std_logic_VECTOR(15 downto 0);
	fwd_inv: IN std_logic;
	fwd_inv_we: IN std_logic;
	scale_sch: IN std_logic_VECTOR(9 downto 0);
	scale_sch_we: IN std_logic;
	rfd: OUT std_logic;
	xn_index: OUT std_logic_VECTOR(9 downto 0);
	busy: OUT std_logic;
	edone: OUT std_logic;
	done: OUT std_logic;
	dv: OUT std_logic;
	xk_index: OUT std_logic_VECTOR(9 downto 0);
	xk_re: OUT std_logic_VECTOR(15 downto 0);
	xk_im: OUT std_logic_VECTOR(15 downto 0));
end component;

signal start, fwd_inv, fwd_inv_we, scale_sch_we, rfd, busy, edone, done, dv  : std_logic;
signal scale_sch, xn_index, xk_index : std_logic_VECTOR(9 downto 0);
signal xk_re, xk_im : std_logic_VECTOR(15 downto 0);

type sumbol_buf_type is array (0 to 1151) of std_logic_vector(31 downto 0);
signal in_buf_t, in_buf_freq  : sumbol_buf_type;
signal in_buf_freq_en_a, in_buf_freq_wr, in_buf_freq_en_b : std_logic;
signal in_buf_freq_adr_wr, in_buf_freq_adr_rd, count  : std_logic_VECTOR(10 downto 0):="00000000000";
signal data_fft : std_logic_vector(31 downto 0);
signal find_symbol : std_logic;

type re_im_mux_type is array (0 to 25) of std_logic_vector(15 downto 0);
type out_mux_type is array (0 to 25) of std_logic_vector(31 downto 0);
signal re_mux_a, re_mux_b, im_mux_a, im_mux_b  : re_im_mux_type;
signal out_mux_re, out_mux_im  : out_mux_type;
signal sum_re, sum_im, sum_re_buf, sum_im_buf  : std_logic_vector(36 downto 0);
signal conveyer : integer range 0 to 5;
--signal	crc_en : std_logic;
--signal	rst : std_logic;
--signal	crc_out : std_logic_vector(31 downto 0);
--signal	data_buf : std_logic_vector(7 downto 0);
--signal	calc,	reset, d_valid : std_logic;
--signal	crc_reg : std_logic_vector(31 downto 0);
--signal	crc : std_logic_vector(7 downto 0);

--COMPONENT lfsr
--	PORT(
--		d : IN std_logic_vector(7 downto 0);
--		calc : IN std_logic;
--		init : IN std_logic;
--		d_valid : IN std_logic;
--		clk : IN std_logic;
--		reset : IN std_logic;
--		crc_reg : OUT std_logic_vector(31 downto 0);
--		crc : OUT std_logic_vector(7 downto 0)
--		);
--	END COMPONENT;

begin

ifft_instance : ifft
		port map (
			clk => adc_clk,
			start => start,
			xn_re => adc_re,
			xn_im => adc_im,
			fwd_inv => fwd_inv,
			fwd_inv_we => fwd_inv_we,
			scale_sch => scale_sch,
			scale_sch_we => scale_sch_we,
			rfd => rfd,
			xn_index => xn_index,
			busy => busy,
			edone => edone,
			done => done,
			dv => dv,
			xk_index => xk_index,
			xk_re => xk_re,
			xk_im => xk_im);
			
--	Inst_lfsr: lfsr PORT MAP(
--		crc_reg => crc_reg,
--		crc => crc,
--		d => data_buf,
--		calc => crc_en,
--		init => rst,
--		d_valid => d_valid,
--		clk => clk,
--		reset => reset
--	);

fwd_inv_we <= '1';
fwd_inv <= '1'; --  '1' - FFT, '0' - IFFT
scale_sch <=  "0110001110";
scale_sch_we <= '1';
start <= '1';
find_symbol <= '1';

process (adc_clk)
begin
   if rising_edge(adc_clk) then
	if(rst = '0') then
      if (in_buf_freq_en_a = '1') then
         if (in_buf_freq_wr = '1') then
            in_buf_freq(conv_integer(in_buf_freq_adr_wr)) <= xk_re & xk_im;
         end if;
      end if;
	end if;
   end if;
end process;

process (clk)
begin
   if rising_edge(clk) then
	if(rst = '0') then
      if (in_buf_freq_en_b = '1') then
         data_fft <= in_buf_freq(conv_integer(in_buf_freq_adr_rd));
      end if;
	end if;
   end if;
end process;


process(adc_clk)
begin
  if rising_edge(adc_clk) then
	if(rst = '1') then
		for i in 0 to 1151 loop
			in_buf_t(i)<=(others => '0');
		end loop;
	else
		in_buf_t(1151) <= adc_re & adc_im;
		for i in 1 to 1151 loop
			in_buf_t(i-1)<=in_buf_t(i);
		end loop;
		
--	in_buf_t(conv_integer(count)) <= adc_re & adc_im;
--	if (conv_integer(count) < 1151) then
--		count <= count + 1;
--	else
--		count <= (others => '0');
--	end if;
--  
--	if(done = '1') then 
--		in_buf_freq_en_a <= '1'; in_buf_freq_wr <= '1';
--	else
--		in_buf_freq_en_a <= '0'; in_buf_freq_wr <= '0';
--	end if;
  end if;
  end if;
end process;

process(re_mux_a,re_mux_b, im_mux_a, im_mux_b)
begin
for i in 0 to 25 loop
	out_mux_re(i)<=re_mux_a(i)(15 downto 0) * re_mux_b(i)(15 downto 0);
	out_mux_im(i)<=im_mux_a(i)(15 downto 0) * im_mux_b(i)(15 downto 0);
end loop;
end process;

process(clk)
begin
  if rising_edge(clk) then
  if(rst = '1') then
		for i in 0 to 25 loop
			re_mux_a(i)<=(others => '0');
			re_mux_b(i)<=(others => '0');
			im_mux_a(i)<=(others => '0');
			im_mux_b(i)<=(others => '0');
		end loop;
		sum_re_buf <= (others => '0');
		sum_im_buf <= (others => '0');
  else
	if(find_symbol='1') then
	case conveyer is
		when 0 => conveyer <= conveyer + 1;
					for i in 0 to 25 loop
						re_mux_a(i)<=in_buf_t(i)(31 downto 16);
						re_mux_b(i)<=in_buf_t(1151-i)(31 downto 16);
		
						im_mux_a(i)<=in_buf_t(i)(15 downto 0);
						im_mux_b(i)<=in_buf_t(1151-i)(15 downto 0);
					end loop;
		when 1 => conveyer <= conveyer + 1;
					for i in 0 to 25 loop
						re_mux_a(i)<=in_buf_t(i+1*26)(31 downto 16);
						re_mux_b(i)<=in_buf_t(1151-i-1*26)(31 downto 16);
		
						im_mux_a(i)<=in_buf_t(i+1*26)(15 downto 0);
						im_mux_b(i)<=in_buf_t(1151-i-1*26)(15 downto 0);
					end loop;
					
		when 2 => conveyer <= conveyer + 1;
					for i in 0 to 25 loop
						re_mux_a(i)<=in_buf_t(i+2*26)(31 downto 16);
						re_mux_b(i)<=in_buf_t(1151-i-2*26)(31 downto 16);
		
						im_mux_a(i)<=in_buf_t(i+3*26)(15 downto 0);
						im_mux_b(i)<=in_buf_t(1151-i-2*26)(15 downto 0);
					end loop;
		when 3 => conveyer <= conveyer + 1;
					for i in 0 to 25 loop
						re_mux_a(i)<=in_buf_t(i+3*26)(31 downto 16);
						re_mux_b(i)<=in_buf_t(1151-i-3*26)(31 downto 16);
		
						im_mux_a(i)<=in_buf_t(i+3*26)(15 downto 0);
						im_mux_b(i)<=in_buf_t(1151-i-3*26)(15 downto 0);
					end loop;
		when 4 => 
					for i in 0 to 23 loop
						re_mux_a(i)<=in_buf_t(i+4*26)(31 downto 16);
						re_mux_b(i)<=in_buf_t(1151-i-4*26)(31 downto 16);
		
						im_mux_a(i)<=in_buf_t(i+4*26)(15 downto 0);
						im_mux_b(i)<=in_buf_t(1151-i-4*26)(15 downto 0);
					end loop;
					conveyer <= 0;
		when others => null;
	end case;
	if(conveyer = 1) then
		sum_re <= sum_re_buf;
		sum_im <= sum_im_buf;
		
		sum_re_buf <= out_mux_re(0)+out_mux_re(1)+out_mux_re(2)+out_mux_re(3)+out_mux_re(4)+out_mux_re(5)+
				out_mux_re(6)+out_mux_re(7)+out_mux_re(8)+out_mux_re(9)+
				out_mux_re(10)+out_mux_re(11)+out_mux_re(12)+out_mux_re(13)+out_mux_re(14)+out_mux_re(15)+
				out_mux_re(16)+out_mux_re(17)+out_mux_re(18)+out_mux_re(19)+
				out_mux_re(20)+out_mux_re(21)+out_mux_re(22)+out_mux_re(23)+out_mux_re(24)+out_mux_re(25);
		sum_im_buf <= out_mux_im(0)+out_mux_im(1)+out_mux_im(2)+out_mux_im(3)+out_mux_im(4)+out_mux_im(5)+
				out_mux_im(6)+out_mux_im(7)+out_mux_im(8)+out_mux_im(9)+
				out_mux_im(10)+out_mux_im(11)+out_mux_im(12)+out_mux_im(13)+out_mux_im(14)+out_mux_im(15)+
				out_mux_im(16)+out_mux_im(17)+out_mux_im(18)+out_mux_im(19)+
				out_mux_im(20)+out_mux_im(21)+out_mux_im(22)+out_mux_im(23)+out_mux_im(24)+out_mux_im(25);
	else
		sum_re_buf <= sum_re_buf + out_mux_re(0)+out_mux_re(1)+out_mux_re(2)+out_mux_re(3)+out_mux_re(4)+out_mux_re(5)+
				out_mux_re(6)+out_mux_re(7)+out_mux_re(8)+out_mux_re(9)+
				out_mux_re(10)+out_mux_re(11)+out_mux_re(12)+out_mux_re(13)+out_mux_re(14)+out_mux_re(15)+
				out_mux_re(16)+out_mux_re(17)+out_mux_re(18)+out_mux_re(19)+
				out_mux_re(20)+out_mux_re(21)+out_mux_re(22)+out_mux_re(23)+out_mux_re(24)+out_mux_re(25);
		sum_im_buf <=sum_im_buf + out_mux_im(0)+out_mux_im(1)+out_mux_im(2)+out_mux_im(3)+out_mux_im(4)+out_mux_im(5)+
				out_mux_im(6)+out_mux_im(7)+out_mux_im(8)+out_mux_im(9)+
				out_mux_im(10)+out_mux_im(11)+out_mux_im(12)+out_mux_im(13)+out_mux_im(14)+out_mux_im(15)+
				out_mux_im(16)+out_mux_im(17)+out_mux_im(18)+out_mux_im(19)+
				out_mux_im(20)+out_mux_im(21)+out_mux_im(22)+out_mux_im(23)+out_mux_im(24)+out_mux_im(25);
	end if;
--		for i in 0 to 25 loop
--			re_mux_a(i)<=in_buf_t(conv_integer(count))(31 downto 16);
--			re_mux_b(i)<=in_buf_t(conv_integer(count))(31 downto 16);
--		
--			im_mux_a(i)<=in_buf_t(conv_integer(count))(15 downto 0);
--			im_mux_b(i)<=in_buf_t(conv_integer(count))(15 downto 0);
--		end loop;
	end if;
  end if;  
  end if;
end process;

end Behavioral;

