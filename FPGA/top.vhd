----------------------------------------------------------------------------------
-- Searching first symbol of preamble for 802.16e.
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

use work.params.All;

entity top is
Port 	 ( clk : in  STD_LOGIC;				-- global clock
			adc_clk : in STD_LOGIC;			-- clock of ADC
			rst: IN std_logic;
			adc_re : in  STD_LOGIC_VECTOR (adc_width - 1 downto 0);    -- I input from ADC
			adc_im : in  STD_LOGIC_VECTOR (adc_width - 1 downto 0);	  -- Q input from ADC
         data : out  STD_LOGIC_VECTOR (7 downto 0)
			);
end top;

architecture Behavioral of top is

component ifft
	port (
	clk: IN std_logic;
	sclr: IN std_logic;
	start: IN std_logic;
	xn_re: IN std_logic_VECTOR(adc_width - 1 downto 0);
	xn_im: IN std_logic_VECTOR(adc_width - 1 downto 0);
	fwd_inv: IN std_logic;
	fwd_inv_we: IN std_logic;
	rfd: OUT std_logic;
	xn_index: OUT std_logic_VECTOR(9 downto 0);
	busy: OUT std_logic;
	edone: OUT std_logic;
	done: OUT std_logic;
	dv: OUT std_logic;
	xk_index: OUT std_logic_VECTOR(9 downto 0);
	xk_re: OUT std_logic_VECTOR(26 downto 0);
	xk_im: OUT std_logic_VECTOR(26 downto 0));
end component;

-- Various constants
constant cp_max : integer := cp_len-1;
constant cp_max_log : integer := 7;
constant adc_max_bit : integer := adc_width-1;
constant adc_max_bit_bdl : integer := 2*adc_width-1;
constant Ts_samples : integer := fft_len + cp_len;  --full OFDMA symbol time, samples
constant preamble_count: integer := 114; -- number of preambles


-- Input from ADC
type symbol_buf_type is array (0 to Ts_samples - 1) of std_ulogic_vector(15 downto 0);
signal in_buf_re, in_buf_im : symbol_buf_type;

-- FFT
signal start, fwd_inv, fwd_inv_we, rfd, busy, edone, done, dv  : std_logic;
signal xn_index, xk_index : std_logic_VECTOR(9 downto 0);
signal xk_re, xk_im : std_logic_VECTOR(26 downto 0);
signal sclr: std_logic;
signal xn_re: std_logic_VECTOR(adc_width - 1 downto 0);
signal xn_im: std_logic_VECTOR(adc_width - 1 downto 0);
signal takt : integer  := 0;
signal count_cp_pos : integer:=0; -- must be range (fft_len - 1) to 0

-- Array of input signal after FFT
type symbol_freq_type is array (0 to Ts_samples - 1) of std_ulogic_vector(26 downto 0);
signal symb_freq_re, symb_freq_im  : symbol_freq_type;
signal symb_freq_en_a, symb_freq_wr, symb_freq_en_b : std_logic;
signal symb_freq_adr_wr, symb_freq_adr_rd  : std_logic_VECTOR(9 downto 0):="0000000000";
signal data_fft_re, data_fft_im : std_ulogic_vector(26 downto 0);

type preamble_sum_type is array (0 to preamble_count - 1) of signed(36 downto 0);
signal preamble_sum_re, preamble_sum_im : preamble_sum_type;
signal preamble_nibble : std_logic_vector(3 downto 0); -- byte from array of preambles
signal preamble_adr : integer:=0; -- number of byte from array of preambles (from 0 to 4103)
signal preamble_N : integer:=0; -- preamble index (from 0 to 113)
signal preamble : std_logic_vector(3 downto 0); -- octet of preamble
signal count_shift : std_logic_vector(1 downto 0); -- counter of shift register for preamble
signal load_shift : std_logic; -- load enable for shift register
type preamble_stages_type is (INIT,to_31,to_63,to_95,seg0_96_113,seg1_96_113,seg2_96_113);
signal preamble_stages : preamble_stages_type:=INIT;
signal preamble_nibble_N : integer:=0; -- number of curent nibble;

-- Find frame
--   Convolution calculation
type conv_mult_cp_type is array (0 to cp_max) of signed(adc_max_bit_bdl downto 0);
signal conv_mult_re, conv_mult_im : conv_mult_cp_type;
signal conv_sum : signed(adc_max_bit_bdl+cp_max_log downto 0);
--   Maximum search
signal count_point, point_max, point_max_old : std_logic_VECTOR(15 downto 0):=x"0000";
signal conv_sum_max : signed(adc_max_bit_bdl+cp_max_log downto 0);


begin

ifft_instance : ifft
		port map (
			clk => clk,
			sclr => sclr,
			start => start,
			xn_re => xn_re,
			xn_im => xn_im,
			fwd_inv => fwd_inv,
			fwd_inv_we => fwd_inv_we,
			rfd => rfd,
			xn_index => xn_index,
			busy => busy,
			edone => edone,
			done => done,
			dv => dv,
			xk_index => xk_index,
			xk_re => xk_re,
			xk_im => xk_im);



process(adc_clk)
variable conv_mult_re_var, conv_mult_im_var : signed(adc_max_bit_bdl downto 0);
begin
  if rising_edge(adc_clk) then
	if(rst = '1') then
		-- Do nothing if Reset is high.
		--   Reset input from ADC
		for i in 0 to 1151 loop
			in_buf_re(i)<=(others => '0');
			in_buf_im(i)<=(others => '0');
		end loop;

		--   Reset convolution calculation
		conv_mult_re_var := (others => '0');
		conv_mult_im_var := (others => '0');
		conv_sum <= (others => '0');
		for i in 0 to cp_max loop
			conv_mult_re(i)<=(others => '0');
			conv_mult_im(i)<=(others => '0');
		end loop;
		count_point <= (others => '0');
		point_max <= (others => '0');
		conv_sum_max <= (others => '0');
	else
		-- Handle counter.
		if (conv_integer(count_point) < 55999) then
			count_point <= count_point + 1;
		else
			count_point <= (others => '0');
		end if;

		-- Read new data from ADC
		in_buf_re(Ts_samples - 1) <= To_StdULogicVector(adc_re);
		in_buf_im(Ts_samples - 1) <= To_StdULogicVector(adc_im);
		for i in 0 to (Ts_samples - 2) loop
			in_buf_re(i)<=in_buf_re(i+1);
			in_buf_im(i)<=in_buf_im(i+1);
		end loop;
		
		-- Find maximum in convolution values.
		if (conv_sum > conv_sum_max) then
			conv_sum_max <= conv_sum;
			
			-- FIXME:: This hardcoded delay MUST be somehow calculated or
			--         better described!
			point_max <= count_point - fft_len - 1;
			
		end if;

		-- Update convolution
		conv_mult_re_var := signed(in_buf_re(cp_max))*signed(in_buf_re(cp_max+fft_len));
		conv_mult_im_var := signed(in_buf_im(cp_max))*signed(in_buf_im(cp_max+fft_len));
		conv_mult_re(cp_max) <= conv_mult_re_var;
		conv_mult_im(cp_max) <= conv_mult_im_var;
		conv_sum <= conv_sum - conv_mult_re(0) - conv_mult_im(0)
 		          + conv_mult_re_var + conv_mult_im_var;
		for i in 0 to cp_max-1 loop
			conv_mult_re(i)<=conv_mult_re(i+1);
			conv_mult_im(i)<=conv_mult_im(i+1);
		end loop;

  end if;
  end if;
end process;


process (clk)

begin
   if rising_edge(clk) then
	if(rst = '1') then
		sclr <= '1';
		start <= '0';
		fwd_inv_we <= '0';
		fwd_inv <= '1'; --  '1' - FFT, '0' - IFFT
		xn_re <= (others => '0');
		xn_im <= (others => '0');
	else
				--  Start calculating FFT
      if (point_max /= point_max_old) then
			point_max_old <= point_max;
			sclr <= '1';
			start <= '1'; -- start for calculate FFT
			xn_re <= To_StdLogicVector(in_buf_re(cp_max-1)); --load firths I point of symbol into fft block
			xn_im <= To_StdLogicVector(in_buf_im(cp_max-1)); --load firths Q point of symbol into fft block
			count_cp_pos <= 1;
			fwd_inv_we <= '1';
			fwd_inv <= '1'; --  '1' - FFT, '0' - IFFT
		else
			sclr <= '0';
			if (rfd = '1') then start <= '0'; end if;-- end of calculate FFT
		end if;
		
		if (rfd = '1') then
			-- load data into fft block
			xn_re <= To_StdLogicVector(in_buf_re(cp_max-1 + count_cp_pos + 1)); --load I point of symbol into fft block
			xn_im <= To_StdLogicVector(in_buf_im(cp_max-1 + count_cp_pos + 1)); --load Q point of symbol into fft block
			
			-- Calculating position of next point	
			if (takt < (N_cycles - 1)) then
				takt <= takt + 1;
			else 
				takt <= 0;
			end if;
			if (takt /= 1) then count_cp_pos <= count_cp_pos + 1;	end if;
			
		else
			takt <= 0;
			count_cp_pos <= 0;
		end if;
		
	end if;
   end if;
end process;

-- Write input signal after FFT into memory
process (clk)
begin
   if rising_edge(clk) then
	if(rst = '0') then
      if (symb_freq_en_a = '1') then
         if (symb_freq_wr = '1') then
            symb_freq_re(conv_integer(symb_freq_adr_wr)) <= To_StdULogicVector(xk_re);
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
            symb_freq_im(conv_integer(symb_freq_adr_wr)) <= To_StdULogicVector(xk_im);
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
         data_fft_re <= symb_freq_re(conv_integer(symb_freq_adr_rd));
      end if;
	end if;
   end if;
end process;
process (clk)
begin
   if rising_edge(clk) then
	if(rst = '0') then
      if (symb_freq_en_b = '1') then
         data_fft_im <= symb_freq_im(conv_integer(symb_freq_adr_rd));
      end if;
	end if;
   end if;
end process;

symb_freq_en_a <= '1'; symb_freq_en_b <= '1';
symb_freq_wr <= dv;
symb_freq_adr_wr <= xk_index+512;

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
		for i in 0 to (preamble_count - 1) loop --count of preambles. must be in variables!
			preamble_sum_re(i) <= (others => '0');
		end loop;
	elsif(preamble_stages /= INIT) then
		if (symb_freq_adr_rd = 515 and preamble_stages=to_31) then
			null;
		else
			if (preamble(3) = '1') then
				preamble_sum_re(preamble_N) <= preamble_sum_re(preamble_N) - signed(data_fft_re);
			else
				preamble_sum_re(preamble_N) <= preamble_sum_re(preamble_N) + signed(data_fft_re);
			end if;
		end if;
	end if;
end if;
end process;

process (clk)
begin
if rising_edge(clk) then
	if(rst = '1') then
		for i in 0 to (preamble_count - 1) loop --count of preambles. must be in variables!
			preamble_sum_im(i) <= (others => '0');
		end loop;
	elsif(preamble_stages /= INIT) then
		if (symb_freq_adr_rd = 515 and preamble_stages=to_31) then
			null;
		else
			if (preamble(3) = '1') then
				preamble_sum_im(preamble_N) <= preamble_sum_im(preamble_N) - signed(data_fft_im);
			else
				preamble_sum_im(preamble_N) <= preamble_sum_im(preamble_N) + signed(data_fft_im);
			end if;
		end if;
	end if;
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

process (clk)
begin
if rising_edge(clk) then
	if(rst = '1') then
		load_shift <= '1';
		preamble_adr <= 0;
		symb_freq_adr_rd <= (others => '0');
	else
		case (preamble_stages) is
			when INIT => if(dv = '1' and symb_freq_adr_wr = 430) then
								preamble_stages <= to_31;
								symb_freq_adr_rd <= symb_freq_adr_rd + 3;
								load_shift<= '0';	
 							 else
								load_shift<= '1';
								symb_freq_adr_rd <= conv_std_logic_vector(86,10);
								preamble_adr <= 0;
								preamble_nibble_N <= 0;
								preamble_N <= 0;
							 end if;
			when to_31 =>  
							if (count_shift = "01") then
								preamble_nibble_N <= preamble_nibble_N + 1;
								preamble_adr <= preamble_adr + 1;
								
							end if;
							if(count_shift = "11" and preamble_nibble_N = 71) then 
									preamble_N <= preamble_N + 1;--if () then
									preamble_nibble_N <= 0;
							end if;
							if (count_shift = "10") then
								load_shift<= '1';
							else
								load_shift<= '0';
							end if;
							if(preamble_nibble_N = 71 and count_shift = "10") then
								symb_freq_adr_rd <= conv_std_logic_vector(86,10);
							else
								symb_freq_adr_rd <= symb_freq_adr_rd + 3;
							end if;
								
							if(preamble_N=31 and preamble_adr=70 and count_shift = "11") then preamble_stages <= to_63; end if;
			when to_63 => 
			when to_95 =>
			when seg0_96_113 => 	
			when seg1_96_113 => 
			when seg2_96_113 => 			
			when others => null;
		end case;
	end if;
end if;
end process;

end Behavioral;

