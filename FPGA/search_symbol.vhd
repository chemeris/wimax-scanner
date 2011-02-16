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

entity search_symbol is
Port 	 ( clk : in  STD_LOGIC;				-- global clock
			adc_clk : in STD_LOGIC;			-- clock of ADC
			rst: IN std_logic;
			adc_re : in  std_logic_vector (adc_width - 1 downto 0);    -- I input from ADC
			adc_im : in  std_logic_vector (adc_width - 1 downto 0);	  -- Q input from ADC
			dv_fft: OUT std_logic;
			xk_index: OUT std_logic_vector(9 downto 0);
         xk_re: OUT std_logic_vector(26 downto 0);
			xk_im: OUT std_logic_vector(26 downto 0)
			);
end search_symbol;

architecture Behavioral of search_symbol is

component in_mem
Port 	 ( clk : in  STD_LOGIC;				  -- global clock
			in_RAM_en : in  STD_LOGIC; -- enable signal for RAM
			in_RAM_wr : in  STD_LOGIC;   -- enable for write data
 			in_RAM_adr_wr : in unsigned(9 downto 0); -- address for write port
			in_RAM_adr_rd_a : in unsigned(9 downto 0); -- address for read port for convolution
			in_RAM_adr_rd_b : in unsigned(9 downto 0); -- address for read port for loading data into FFT block
			adc_re : in  std_logic_vector (adc_width - 1 downto 0);    -- I input from ADC
			adc_im : in  std_logic_vector (adc_width - 1 downto 0);	  -- Q input from ADC
			in_RAM_re_out_a, in_RAM_im_out_a : out std_logic_vector (adc_width - 1 downto 0); -- I and Q channel for convolution
			in_RAM_re_out_b, in_RAM_im_out_b : out std_logic_vector (adc_width - 1 downto 0) -- I and Q channel for loading data into FFT block
		 );
end component;

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


-- FFT
signal start, fwd_inv, fwd_inv_we, rfd, busy, edone, done  : std_logic;
signal xn_index : std_logic_vector(9 downto 0);
signal sclr: std_logic;
signal xn_re: std_logic_vector(adc_width - 1 downto 0);
signal xn_im: std_logic_vector(adc_width - 1 downto 0);

-- Find frame
--   Convolution calculation
type conv_mult_cp_type is array (0 to cp_max) of signed(adc_max_bit_bdl downto 0);
signal conv_mult_re, conv_mult_im : conv_mult_cp_type;
signal conv_sum : signed(adc_max_bit_bdl+cp_max_log downto 0);
--   Maximum search
signal count_point, count_point_old : unsigned(15 downto 0):=x"0000";
signal conv_sum_max : signed(adc_max_bit_bdl+cp_max_log downto 0);

-- Input from ADC
signal in_RAM_en : std_logic;
signal in_RAM_wr : std_logic;
signal in_RAM_adr_wr : unsigned(9 downto 0);
signal in_RAM_adr_rd_a : unsigned(9 downto 0);
signal in_RAM_adr_rd_b : unsigned(9 downto 0);
signal in_RAM_re_out_a, in_RAM_re_out_b : std_logic_vector (adc_width - 1 downto 0);
signal in_RAM_im_out_a, in_RAM_im_out_b : std_logic_vector (adc_width - 1 downto 0);

type stage_type is (INIT,WORK);
signal stage : stage_type := INIT;

begin

in_mem_instance : in_mem
		port map (
		   clk => clk,
			in_RAM_en => in_RAM_en,
			in_RAM_wr => in_RAM_wr,
 			in_RAM_adr_wr => in_RAM_adr_wr,
			in_RAM_adr_rd_a => in_RAM_adr_rd_a,
			in_RAM_adr_rd_b => in_RAM_adr_rd_b,
			adc_re => adc_re,
			adc_im => adc_im,
			in_RAM_re_out_a => in_RAM_re_out_a,
			in_RAM_im_out_a => in_RAM_im_out_a, 
			in_RAM_re_out_b => in_RAM_re_out_b,
			in_RAM_im_out_b => in_RAM_im_out_b 
		 );

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
			dv => dv_fft,
			xk_index => xk_index,
			xk_re => xk_re,
			xk_im => xk_im);


process(adc_clk)
begin
if rising_edge(adc_clk) then
	if(rst = '1') then
	-- Do nothing if Reset is high.
		count_point <= (others => '0');
	--   Reset convolution calculation
	else
		-- Handle counter.
		if (To_integer(count_point) < 55999) then
			count_point <= count_point + 1;
		else
			count_point <= (others => '0');
		end if;
	end if;
end if;
end process;

process(clk)
variable conv_mult_re_var, conv_mult_im_var : signed(adc_max_bit_bdl downto 0);
begin
if rising_edge(clk) then
	if(rst = '1') then
		-- Do nothing if Reset is high.
		in_RAM_en <= '0';
		in_RAM_wr <= '0';
		in_RAM_adr_wr <= (others => '0');
		in_RAM_adr_rd_a <= TO_UNSIGNED(1,10);
		--   Reset convolution calculation
		conv_mult_re_var := (others => '0');
		conv_mult_im_var := (others => '0');
		conv_sum <= (others => '0');
		for i in 0 to cp_max loop
			conv_mult_re(i)<=(others => '0');
			conv_mult_im(i)<=(others => '0');
		end loop;

		in_RAM_en <= '1';
		stage <= INIT;
	else
	case stage is
		when INIT => 
							if (count_point_old /= count_point) then
								count_point_old <= count_point;
								in_RAM_wr <= '1';
								in_RAM_adr_wr <= in_RAM_adr_wr + 1;
								in_RAM_adr_rd_a <= in_RAM_adr_wr + 2;
								stage <= WORK;
							end if;
		when WORK =>	stage <= INIT;
							in_RAM_wr <= '0';
			
							-- Update convolution
							conv_mult_re_var := signed(adc_re)*signed(in_RAM_re_out_a);
							conv_mult_im_var := signed(adc_im)*signed(in_RAM_im_out_a);

							conv_sum <= conv_sum - conv_mult_re(0) - conv_mult_im(0)
										+ conv_mult_re_var + conv_mult_im_var;
			
							conv_mult_re(cp_max) <= conv_mult_re_var;
							conv_mult_im(cp_max) <= conv_mult_im_var;
							for i in 0 to cp_max-1 loop
								conv_mult_re(i)<=conv_mult_re(i+1);
								conv_mult_im(i)<=conv_mult_im(i+1);
							end loop;
		
		when others => null;
	end case;
	
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
		in_RAM_adr_rd_b <= (others => '0');
		conv_sum_max <= (others => '0');
	else

	-- Find maximum in convolution values and start calculating FFT
		if (conv_sum > conv_sum_max) then
			conv_sum_max <= conv_sum;
								
			sclr <= '1';
			start <= '1'; -- start signal for calculate FFT
			fwd_inv_we <= '1';
			fwd_inv <= '1'; --  '1' - FFT, '0' - IFFT
			in_RAM_adr_rd_b <= in_RAM_adr_rd_a;
		
		else
			sclr <= '0';
			-- load data into fft block
			in_RAM_adr_rd_b <= in_RAM_adr_rd_b + 1;
			xn_re <= in_RAM_re_out_b; --load I point of symbol into fft block
			xn_im <= in_RAM_im_out_b; --load Q point of symbol into fft block
			if (rfd = '1') then start <= '0'; end if;
		end if;

	end if;
   end if;
end process;

end Behavioral;

