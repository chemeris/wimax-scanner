----------------------------------------------------------------------------------
-- Top file for 802.16e project.
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

component search_symbol
Port 	 ( clk : in  STD_LOGIC;				-- global clock
			adc_clk : in STD_LOGIC;			-- clock of ADC
			rst: IN std_logic;
			adc_re : in  STD_LOGIC_VECTOR (adc_width - 1 downto 0);    -- I input from ADC
			adc_im : in  STD_LOGIC_VECTOR (adc_width - 1 downto 0);	  -- Q input from ADC
			dv_fft: OUT std_logic;
			xk_index: OUT std_logic_VECTOR(9 downto 0);
         xk_re: OUT std_logic_VECTOR(26 downto 0);
			xk_im: OUT std_logic_VECTOR(26 downto 0)
			);
end component;


	COMPONENT in_mem
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		symb_freq_en_a : IN std_logic;
		symb_freq_wr : IN std_logic;
		in_fft_re : IN std_logic_vector(26 downto 0);
		in_fft_im : IN std_logic_vector(26 downto 0);
		symb_freq_en_b : IN std_logic;
		symb_freq_adr_rd : IN unsigned(9 downto 0);          
		symb_freq_adr_wr : IN unsigned(9 downto 0);
		data_fft_re : OUT signed(26 downto 0);
		data_fft_im : OUT signed(26 downto 0)
		);
	END COMPONENT;
	
	COMPONENT search_preamble
	Port(
		clk : in  STD_LOGIC;				  -- global clock
		rst : in  STD_LOGIC;				  -- reset signal
		dv_fft: in std_logic;
		preamble_N : out unsigned(6 downto 0); -- preamble of current frame
		symb_freq_adr_rd : inout unsigned(9 downto 0):="0000000000"; -- address for read port
		symb_freq_adr_wr : in unsigned(9 downto 0):="0000000000"; -- address for write port
		data_fft_re : in signed(26 downto 0);
		data_fft_im : in signed(26 downto 0)
		);
	END COMPONENT;
	
-- FFT
signal dv_fft: std_logic;
signal xk_index : std_logic_VECTOR(9 downto 0);
signal xk_re, xk_im : std_logic_VECTOR(26 downto 0);

-- Array of input signal after FFT

signal symb_freq_en_a, symb_freq_wr, symb_freq_en_b : std_logic;
signal symb_freq_adr_wr, symb_freq_adr_rd  : unsigned(9 downto 0):="0000000000";
signal data_fft_re, data_fft_im : signed(26 downto 0);

-- Searching correct preamble
signal preamble_N : unsigned(6 downto 0); -- preamble of current frame


begin

search_symbol_instance : search_symbol
port map (
			clk => clk,				-- global clock
			rst => rst,
			adc_clk => adc_clk,	-- clock of ADC
			adc_re => adc_re,     -- I input from ADC
			adc_im => adc_im,	  -- Q input from ADC
			dv_fft => dv_fft,
			xk_index => xk_index,
         xk_re => xk_re,
			xk_im => xk_im

);

	Inst_in_mem: in_mem PORT MAP(
		clk => clk,
		rst => rst,
		symb_freq_en_a => symb_freq_en_a,
		symb_freq_wr => symb_freq_wr,
		symb_freq_adr_wr => symb_freq_adr_wr,
		in_fft_re => xk_re,
		in_fft_im => xk_im,
		symb_freq_en_b => symb_freq_en_b,
		symb_freq_adr_rd => symb_freq_adr_rd,
		data_fft_re => data_fft_re,
		data_fft_im => data_fft_im
	);

Inst_search_preamble: search_preamble PORT MAP(
		clk => clk,
		rst => rst, 
		dv_fft => dv_fft,
		preamble_N => preamble_N,
		symb_freq_adr_rd => symb_freq_adr_rd, 
		symb_freq_adr_wr => symb_freq_adr_wr, 
		data_fft_re => data_fft_re,
		data_fft_im => data_fft_im
	);

symb_freq_en_a <= '1'; symb_freq_en_b <= '1';
symb_freq_wr <= dv_fft;
symb_freq_adr_wr <= unsigned(xk_index)+512;



end Behavioral;

