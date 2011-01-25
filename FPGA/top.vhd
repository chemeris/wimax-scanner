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
--	scale_sch: IN std_logic_VECTOR(9 downto 0);
--	scale_sch_we: IN std_logic;
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



-- Input from ADC
type symbol_buf_type is array (0 to Ts_samples - 1) of std_ulogic_vector(15 downto 0);
signal in_buf_re, in_buf_im : symbol_buf_type;

-- FFT
signal start, fwd_inv, fwd_inv_we, scale_sch_we, rfd, busy, edone, done, dv  : std_logic;
signal scale_sch, xn_index, xk_index : std_logic_VECTOR(9 downto 0);
signal xk_re, xk_im : std_logic_VECTOR(26 downto 0);
signal sclr: std_logic;

signal in_buf_freq  : symbol_buf_type;
signal in_buf_freq_en_a, in_buf_freq_wr, in_buf_freq_en_b : std_logic;
signal in_buf_freq_adr_wr, in_buf_freq_adr_rd, count  : std_logic_VECTOR(10 downto 0):="00000000000";
signal data_fft : std_logic_vector(31 downto 0);
signal xn_re: std_logic_VECTOR(adc_width - 1 downto 0);
signal xn_im: std_logic_VECTOR(adc_width - 1 downto 0);
--signal start_fft : std_logic;
signal takt : integer  := 0;
signal count_cp_pos : integer:=0; -- must be range (fft_len - 1) to 0

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
--			scale_sch => scale_sch,
--			scale_sch_we => scale_sch_we,
			rfd => rfd,
			xn_index => xn_index,
			busy => busy,
			edone => edone,
			done => done,
			dv => dv,
			xk_index => xk_index,
			xk_re => xk_re,
			xk_im => xk_im);



process (adc_clk)
begin
   if rising_edge(adc_clk) then
	if(rst = '0') then
      if (in_buf_freq_en_a = '1') then
         if (in_buf_freq_wr = '1') then
            in_buf_freq(conv_integer(in_buf_freq_adr_wr)) <= To_StdULogicVector(xk_re & xk_im);
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
         data_fft <= To_StdLogicVector(in_buf_freq(conv_integer(in_buf_freq_adr_rd)));
      end if;
	end if;
   end if;
end process;


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
		
		
--	if(done = '1') then 
--		in_buf_freq_en_a <= '1'; in_buf_freq_wr <= '1';
--	else
--		in_buf_freq_en_a <= '0'; in_buf_freq_wr <= '0';
--	end if;
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
		scale_sch <=  "0110001110";
		scale_sch_we <= '0';
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
			scale_sch <=  "1010101011";
			scale_sch_we <= '1';
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

end Behavioral;

