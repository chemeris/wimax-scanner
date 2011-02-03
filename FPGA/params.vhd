----------------------------------------------------------------------------------
-- Package File Template
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
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
use IEEE.STD_LOGIC_1164.all;

package params is

  
constant  cp_len : integer := 128;    -- cyclic prefix length, samples
constant  fft_len : integer := 1024;  -- size of the FFT
constant  adc_width : integer := 16;   -- ADC resolution
constant  N_cycles  : integer := 5;   -- FPGA frequency divided by ADC frequency

-- ROM with preambles
type rom_type is array (0 to 8093) of std_logic_vector (3 downto 0);                 
signal preambles_rom : rom_type:= (                       
-- IDcell 0   Segment 0
x"A",x"6",x"F",x"2",x"9",x"4",x"5",x"3",x"7",x"B",x"2",x"8",x"5",x"E",x"1",x"8",x"4",x"4",x"6",x"7",x"7",x"D",x"1",x"3",x"3",x"E",x"4",x"D",x"5",x"3",x"C",x"C",x"B",x"1",x"F",x"1",
x"8",x"2",x"D",x"E",x"0",x"0",x"4",x"8",x"9",x"E",x"5",x"3",x"E",x"6",x"B",x"6",x"E",x"7",x"7",x"0",x"6",x"5",x"C",x"7",x"E",x"E",x"7",x"D",x"0",x"A",x"D",x"B",x"E",x"A",x"F",
-- IDcell 1   Segment 0
x"6",x"6",x"8",x"3",x"2",x"1",x"C",x"B",x"B",x"E",x"7",x"F",x"4",x"6",x"2",x"E",x"6",x"C",x"2",x"A",x"0",x"7",x"E",x"8",x"B",x"B",x"D",x"A",x"2",x"C",x"7",x"F",x"7",x"9",x"4",x"6",
x"D",x"5",x"F",x"6",x"9",x"E",x"3",x"5",x"A",x"C",x"8",x"A",x"C",x"F",x"7",x"D",x"6",x"4",x"A",x"B",x"4",x"A",x"3",x"3",x"C",x"4",x"6",x"7",x"0",x"0",x"1",x"F",x"3",x"B",x"2",
-- IDcell 2   Segment 0
x"1",x"C",x"7",x"5",x"D",x"3",x"0",x"B",x"2",x"D",x"F",x"7",x"2",x"C",x"E",x"C",x"9",x"1",x"1",x"7",x"A",x"0",x"B",x"D",x"8",x"E",x"A",x"F",x"8",x"E",x"0",x"5",x"0",x"2",x"4",x"6",
x"1",x"F",x"C",x"0",x"7",x"4",x"5",x"6",x"A",x"C",x"9",x"0",x"6",x"A",x"D",x"E",x"0",x"3",x"E",x"9",x"B",x"5",x"A",x"B",x"5",x"E",x"1",x"D",x"3",x"F",x"9",x"8",x"C",x"6",x"E",
-- IDcell 3   Segment 0
x"5",x"F",x"9",x"A",x"2",x"E",x"5",x"C",x"A",x"7",x"C",x"C",x"6",x"9",x"A",x"5",x"2",x"2",x"7",x"1",x"0",x"4",x"F",x"B",x"1",x"C",x"C",x"2",x"2",x"6",x"2",x"8",x"0",x"9",x"F",x"3",
x"B",x"1",x"0",x"D",x"0",x"5",x"4",x"2",x"B",x"9",x"B",x"D",x"F",x"D",x"A",x"4",x"A",x"7",x"3",x"A",x"7",x"0",x"4",x"6",x"0",x"9",x"6",x"D",x"F",x"0",x"E",x"8",x"D",x"3",x"D",
-- IDcell 4   Segment 0
x"8",x"2",x"F",x"8",x"A",x"0",x"A",x"B",x"9",x"1",x"8",x"1",x"3",x"8",x"D",x"8",x"4",x"B",x"B",x"8",x"6",x"2",x"2",x"4",x"F",x"6",x"C",x"3",x"4",x"2",x"D",x"8",x"1",x"B",x"C",x"8",
x"B",x"F",x"E",x"7",x"9",x"1",x"C",x"A",x"9",x"E",x"B",x"5",x"4",x"0",x"9",x"6",x"1",x"5",x"9",x"D",x"6",x"7",x"2",x"E",x"9",x"1",x"C",x"6",x"E",x"1",x"3",x"0",x"3",x"2",x"F",
-- IDcell 5   Segment 0
x"E",x"E",x"2",x"7",x"E",x"5",x"9",x"B",x"8",x"4",x"C",x"C",x"F",x"1",x"5",x"B",x"B",x"1",x"5",x"6",x"5",x"E",x"F",x"9",x"0",x"D",x"4",x"7",x"8",x"C",x"D",x"2",x"C",x"4",x"9",x"E",
x"E",x"8",x"A",x"7",x"0",x"D",x"E",x"3",x"6",x"8",x"E",x"E",x"D",x"7",x"C",x"9",x"4",x"2",x"0",x"B",x"0",x"C",x"6",x"F",x"F",x"A",x"F",x"9",x"A",x"F",x"0",x"3",x"5",x"F",x"C",
-- IDcell 6   Segment 0
x"C",x"1",x"D",x"F",x"5",x"A",x"E",x"2",x"8",x"D",x"1",x"C",x"A",x"6",x"A",x"8",x"9",x"1",x"7",x"B",x"C",x"D",x"A",x"F",x"4",x"E",x"7",x"3",x"B",x"D",x"9",x"3",x"F",x"9",x"3",x"1",
x"C",x"4",x"4",x"F",x"9",x"3",x"C",x"3",x"F",x"1",x"2",x"F",x"0",x"1",x"3",x"2",x"F",x"B",x"6",x"4",x"3",x"E",x"F",x"D",x"5",x"8",x"8",x"5",x"C",x"8",x"B",x"2",x"B",x"C",x"B",
-- IDcell 7   Segment 0
x"F",x"C",x"A",x"3",x"6",x"C",x"C",x"C",x"F",x"7",x"F",x"3",x"E",x"0",x"6",x"0",x"2",x"6",x"9",x"6",x"D",x"F",x"7",x"4",x"5",x"A",x"6",x"8",x"D",x"B",x"9",x"4",x"8",x"C",x"5",x"7",
x"D",x"F",x"A",x"9",x"5",x"7",x"5",x"B",x"E",x"A",x"1",x"F",x"0",x"5",x"7",x"2",x"5",x"C",x"4",x"2",x"1",x"5",x"5",x"8",x"9",x"8",x"F",x"0",x"A",x"6",x"3",x"A",x"2",x"4",x"8",
-- IDcell 8   Segment 0
x"0",x"2",x"4",x"B",x"0",x"7",x"1",x"8",x"D",x"E",x"6",x"4",x"7",x"4",x"4",x"7",x"3",x"A",x"0",x"8",x"C",x"8",x"B",x"1",x"5",x"1",x"A",x"E",x"D",x"1",x"2",x"4",x"7",x"9",x"8",x"F",
x"1",x"5",x"D",x"1",x"F",x"F",x"C",x"C",x"D",x"0",x"D",x"E",x"5",x"7",x"4",x"C",x"5",x"D",x"2",x"C",x"5",x"2",x"A",x"4",x"2",x"E",x"E",x"F",x"8",x"5",x"8",x"D",x"B",x"A",x"5",
-- IDcell 9   Segment 0
x"D",x"4",x"E",x"B",x"F",x"C",x"C",x"3",x"F",x"5",x"A",x"0",x"3",x"3",x"2",x"B",x"E",x"A",x"5",x"B",x"3",x"0",x"9",x"A",x"C",x"B",x"0",x"4",x"6",x"8",x"5",x"B",x"8",x"D",x"1",x"B",
x"B",x"4",x"C",x"B",x"4",x"9",x"F",x"9",x"2",x"5",x"1",x"4",x"6",x"1",x"B",x"4",x"A",x"B",x"A",x"2",x"5",x"5",x"8",x"9",x"7",x"1",x"4",x"8",x"F",x"0",x"F",x"F",x"2",x"3",x"8",
-- IDcell 10   Segment 0
x"E",x"E",x"A",x"2",x"1",x"3",x"F",x"4",x"2",x"9",x"E",x"B",x"9",x"2",x"6",x"D",x"1",x"B",x"D",x"E",x"C",x"0",x"3",x"A",x"B",x"B",x"6",x"7",x"D",x"1",x"D",x"E",x"4",x"7",x"B",x"4",
x"7",x"3",x"8",x"F",x"3",x"E",x"9",x"2",x"9",x"8",x"5",x"4",x"F",x"8",x"3",x"D",x"1",x"8",x"B",x"2",x"1",x"6",x"0",x"9",x"5",x"E",x"6",x"F",x"5",x"4",x"6",x"D",x"A",x"D",x"E",
-- IDcell 11   Segment 0
x"C",x"0",x"3",x"0",x"3",x"6",x"F",x"A",x"9",x"F",x"2",x"5",x"3",x"0",x"4",x"5",x"D",x"F",x"6",x"C",x"0",x"8",x"8",x"9",x"A",x"8",x"B",x"8",x"3",x"B",x"A",x"E",x"F",x"C",x"F",x"9",
x"0",x"E",x"B",x"9",x"9",x"3",x"C",x"2",x"D",x"7",x"9",x"B",x"D",x"9",x"1",x"1",x"C",x"A",x"8",x"4",x"0",x"7",x"5",x"0",x"6",x"1",x"A",x"A",x"4",x"3",x"D",x"A",x"4",x"7",x"1",
-- IDcell 12   Segment 0
x"1",x"E",x"6",x"8",x"E",x"C",x"2",x"2",x"E",x"5",x"E",x"2",x"9",x"4",x"7",x"F",x"B",x"0",x"A",x"2",x"9",x"E",x"4",x"C",x"C",x"7",x"0",x"5",x"9",x"7",x"2",x"5",x"4",x"B",x"3",x"6",
x"C",x"6",x"0",x"3",x"3",x"1",x"E",x"A",x"C",x"F",x"7",x"7",x"9",x"F",x"E",x"7",x"5",x"2",x"D",x"3",x"F",x"5",x"5",x"D",x"C",x"4",x"1",x"A",x"B",x"F",x"C",x"7",x"D",x"C",x"9",
-- IDcell 13   Segment 0
x"6",x"3",x"A",x"5",x"7",x"E",x"7",x"5",x"A",x"0",x"4",x"3",x"4",x"F",x"0",x"3",x"5",x"A",x"A",x"C",x"4",x"5",x"0",x"4",x"B",x"2",x"6",x"5",x"0",x"8",x"1",x"D",x"4",x"9",x"7",x"F",
x"1",x"0",x"C",x"7",x"7",x"9",x"2",x"8",x"B",x"7",x"1",x"7",x"9",x"7",x"C",x"5",x"D",x"6",x"C",x"6",x"8",x"2",x"4",x"D",x"C",x"0",x"F",x"2",x"3",x"B",x"E",x"3",x"4",x"E",x"E",
-- IDcell 14   Segment 0
x"C",x"5",x"7",x"C",x"4",x"6",x"1",x"2",x"8",x"1",x"6",x"D",x"E",x"9",x"8",x"1",x"C",x"5",x"8",x"F",x"D",x"6",x"F",x"8",x"D",x"E",x"9",x"D",x"D",x"4",x"1",x"F",x"2",x"4",x"2",x"2",
x"A",x"D",x"B",x"C",x"5",x"2",x"2",x"B",x"0",x"C",x"E",x"3",x"1",x"F",x"9",x"A",x"6",x"D",x"5",x"F",x"2",x"A",x"1",x"2",x"6",x"D",x"C",x"0",x"8",x"F",x"6",x"9",x"F",x"B",x"1",
-- IDcell 15   Segment 0
x"9",x"7",x"8",x"2",x"5",x"6",x"A",x"F",x"1",x"8",x"4",x"E",x"7",x"E",x"D",x"1",x"7",x"7",x"8",x"9",x"B",x"3",x"3",x"D",x"3",x"2",x"4",x"C",x"7",x"1",x"1",x"B",x"3",x"6",x"B",x"F",
x"B",x"C",x"C",x"E",x"5",x"4",x"4",x"6",x"E",x"B",x"0",x"3",x"6",x"8",x"7",x"E",x"9",x"A",x"0",x"A",x"8",x"3",x"9",x"C",x"7",x"C",x"E",x"1",x"5",x"6",x"1",x"0",x"4",x"D",x"2",
-- IDcell 16   Segment 0
x"0",x"1",x"1",x"E",x"C",x"8",x"2",x"3",x"1",x"5",x"7",x"D",x"D",x"7",x"3",x"1",x"5",x"0",x"6",x"4",x"0",x"C",x"E",x"B",x"7",x"D",x"D",x"B",x"0",x"A",x"1",x"F",x"8",x"F",x"9",x"1",
x"E",x"0",x"9",x"5",x"9",x"9",x"A",x"8",x"5",x"1",x"D",x"5",x"C",x"7",x"C",x"A",x"F",x"6",x"8",x"7",x"C",x"F",x"B",x"7",x"5",x"2",x"D",x"2",x"9",x"7",x"D",x"8",x"2",x"F",x"C",
-- IDcell 17   Segment 0
x"C",x"6",x"D",x"E",x"8",x"2",x"B",x"E",x"B",x"7",x"F",x"5",x"7",x"B",x"9",x"1",x"2",x"0",x"E",x"8",x"A",x"3",x"7",x"6",x"D",x"8",x"5",x"C",x"8",x"F",x"7",x"0",x"F",x"D",x"C",x"6",
x"5",x"B",x"C",x"6",x"6",x"0",x"4",x"0",x"2",x"D",x"A",x"C",x"4",x"A",x"E",x"6",x"0",x"0",x"2",x"E",x"A",x"2",x"7",x"4",x"0",x"C",x"4",x"F",x"9",x"E",x"5",x"9",x"7",x"3",x"C",
-- IDcell 18   Segment 0
x"4",x"C",x"7",x"4",x"9",x"2",x"9",x"D",x"6",x"F",x"9",x"F",x"A",x"B",x"9",x"E",x"5",x"B",x"B",x"7",x"6",x"1",x"0",x"2",x"6",x"0",x"3",x"8",x"E",x"0",x"7",x"6",x"F",x"6",x"8",x"2",
x"4",x"2",x"9",x"5",x"E",x"0",x"A",x"F",x"3",x"9",x"7",x"8",x"0",x"6",x"E",x"C",x"E",x"B",x"C",x"6",x"D",x"C",x"7",x"1",x"3",x"F",x"0",x"3",x"A",x"C",x"D",x"C",x"2",x"7",x"C",
-- IDcell 19   Segment 0
x"1",x"3",x"E",x"1",x"E",x"8",x"5",x"C",x"2",x"2",x"3",x"4",x"D",x"0",x"F",x"3",x"4",x"1",x"8",x"0",x"0",x"1",x"A",x"3",x"5",x"F",x"1",x"3",x"5",x"E",x"1",x"0",x"C",x"6",x"C",x"9",
x"1",x"8",x"C",x"3",x"6",x"B",x"C",x"6",x"5",x"9",x"F",x"D",x"A",x"9",x"D",x"6",x"5",x"5",x"D",x"2",x"8",x"8",x"A",x"0",x"B",x"D",x"A",x"A",x"8",x"B",x"F",x"4",x"8",x"9",x"D",
-- IDcell 20   Segment 0
x"F",x"D",x"4",x"A",x"F",x"2",x"D",x"8",x"F",x"4",x"F",x"0",x"8",x"F",x"1",x"A",x"7",x"D",x"F",x"5",x"9",x"2",x"9",x"1",x"C",x"9",x"A",x"E",x"E",x"7",x"8",x"8",x"F",x"6",x"4",x"1",
x"B",x"8",x"2",x"3",x"1",x"C",x"F",x"B",x"8",x"1",x"3",x"3",x"7",x"6",x"E",x"0",x"B",x"E",x"B",x"6",x"8",x"D",x"F",x"C",x"F",x"C",x"B",x"B",x"E",x"5",x"5",x"2",x"4",x"4",x"5",
-- IDcell 21   Segment 0
x"E",x"B",x"B",x"C",x"7",x"7",x"A",x"4",x"9",x"3",x"A",x"A",x"0",x"C",x"6",x"2",x"C",x"6",x"2",x"F",x"2",x"5",x"E",x"E",x"5",x"E",x"8",x"D",x"0",x"7",x"0",x"1",x"F",x"5",x"0",x"3",
x"8",x"6",x"F",x"4",x"9",x"0",x"2",x"6",x"F",x"A",x"3",x"1",x"4",x"8",x"7",x"C",x"9",x"F",x"D",x"5",x"C",x"5",x"2",x"0",x"6",x"C",x"E",x"4",x"E",x"B",x"0",x"0",x"5",x"7",x"6",
-- IDcell 22   Segment 0
x"1",x"3",x"4",x"F",x"9",x"3",x"6",x"F",x"9",x"E",x"8",x"7",x"5",x"8",x"4",x"2",x"5",x"8",x"7",x"A",x"D",x"C",x"A",x"9",x"2",x"1",x"8",x"7",x"F",x"2",x"F",x"C",x"6",x"D",x"6",x"2",
x"F",x"F",x"C",x"3",x"A",x"8",x"3",x"3",x"D",x"8",x"C",x"D",x"E",x"4",x"6",x"5",x"F",x"9",x"9",x"7",x"2",x"A",x"B",x"A",x"A",x"8",x"3",x"7",x"6",x"3",x"A",x"A",x"E",x"B",x"7",
-- IDcell 23   Segment 0
x"3",x"C",x"D",x"1",x"D",x"A",x"7",x"0",x"6",x"7",x"0",x"B",x"C",x"7",x"3",x"3",x"6",x"3",x"D",x"1",x"B",x"4",x"A",x"6",x"6",x"D",x"2",x"8",x"0",x"F",x"F",x"6",x"A",x"A",x"7",x"6",
x"3",x"6",x"D",x"0",x"7",x"E",x"C",x"F",x"3",x"2",x"B",x"A",x"2",x"6",x"1",x"0",x"1",x"E",x"5",x"E",x"B",x"A",x"1",x"5",x"9",x"4",x"F",x"B",x"8",x"A",x"0",x"4",x"2",x"0",x"A",
-- IDcell 24   Segment 0
x"9",x"1",x"8",x"2",x"9",x"6",x"B",x"2",x"9",x"3",x"7",x"C",x"2",x"B",x"6",x"F",x"7",x"3",x"C",x"F",x"9",x"8",x"F",x"8",x"5",x"A",x"8",x"1",x"B",x"7",x"2",x"3",x"D",x"1",x"C",x"6",
x"9",x"D",x"B",x"D",x"F",x"3",x"E",x"0",x"1",x"9",x"7",x"4",x"9",x"C",x"5",x"8",x"2",x"D",x"A",x"2",x"2",x"E",x"7",x"8",x"9",x"5",x"6",x"2",x"7",x"2",x"9",x"D",x"4",x"7",x"5",
-- IDcell 25   Segment 0
x"C",x"3",x"2",x"3",x"9",x"8",x"1",x"B",x"8",x"B",x"2",x"2",x"4",x"0",x"8",x"6",x"5",x"F",x"4",x"8",x"D",x"6",x"1",x"A",x"E",x"1",x"B",x"3",x"B",x"6",x"1",x"D",x"8",x"8",x"5",x"2",
x"2",x"B",x"7",x"3",x"5",x"8",x"9",x"5",x"2",x"F",x"9",x"4",x"9",x"D",x"4",x"3",x"0",x"8",x"C",x"A",x"1",x"5",x"D",x"1",x"E",x"E",x"8",x"F",x"D",x"F",x"A",x"6",x"8",x"3",x"F",
-- IDcell 26   Segment 0
x"7",x"5",x"1",x"4",x"A",x"6",x"F",x"A",x"5",x"F",x"B",x"B",x"2",x"5",x"0",x"C",x"5",x"C",x"8",x"C",x"E",x"9",x"6",x"F",x"7",x"9",x"1",x"D",x"6",x"7",x"6",x"0",x"3",x"6",x"C",x"3",
x"4",x"4",x"A",x"4",x"4",x"B",x"2",x"4",x"2",x"8",x"4",x"4",x"7",x"7",x"B",x"4",x"4",x"C",x"B",x"3",x"E",x"7",x"5",x"8",x"F",x"8",x"B",x"C",x"D",x"5",x"8",x"F",x"0",x"5",x"B",
-- IDcell 27   Segment 0
x"8",x"4",x"C",x"7",x"F",x"E",x"C",x"6",x"E",x"9",x"7",x"7",x"F",x"A",x"1",x"E",x"C",x"0",x"C",x"7",x"C",x"C",x"9",x"E",x"0",x"D",x"0",x"6",x"7",x"C",x"7",x"3",x"D",x"8",x"F",x"8",
x"4",x"6",x"F",x"8",x"2",x"A",x"B",x"B",x"3",x"4",x"5",x"6",x"D",x"2",x"1",x"0",x"4",x"E",x"1",x"4",x"4",x"8",x"D",x"5",x"A",x"5",x"8",x"D",x"5",x"9",x"7",x"5",x"1",x"5",x"2",
-- IDcell 28   Segment 0
x"4",x"8",x"4",x"1",x"A",x"F",x"C",x"2",x"7",x"7",x"B",x"8",x"6",x"A",x"0",x"E",x"0",x"6",x"7",x"A",x"F",x"3",x"1",x"9",x"4",x"2",x"2",x"F",x"5",x"0",x"1",x"C",x"8",x"7",x"A",x"C",
x"B",x"F",x"B",x"D",x"D",x"6",x"6",x"B",x"F",x"E",x"A",x"3",x"6",x"4",x"4",x"F",x"8",x"7",x"9",x"A",x"E",x"9",x"8",x"B",x"A",x"8",x"C",x"5",x"D",x"6",x"0",x"5",x"1",x"2",x"3",
-- IDcell 29   Segment 0
x"F",x"3",x"5",x"E",x"A",x"8",x"7",x"3",x"1",x"8",x"E",x"4",x"5",x"9",x"1",x"3",x"8",x"A",x"2",x"C",x"E",x"6",x"9",x"1",x"6",x"9",x"A",x"D",x"5",x"F",x"D",x"9",x"F",x"3",x"0",x"B",
x"6",x"2",x"D",x"A",x"0",x"4",x"E",x"D",x"2",x"1",x"3",x"2",x"0",x"A",x"9",x"F",x"5",x"9",x"8",x"9",x"3",x"F",x"0",x"D",x"1",x"7",x"6",x"7",x"5",x"2",x"1",x"5",x"2",x"F",x"D",
-- IDcell 30   Segment 0
x"A",x"0",x"C",x"5",x"F",x"3",x"5",x"C",x"5",x"9",x"7",x"1",x"C",x"D",x"3",x"D",x"C",x"5",x"5",x"D",x"7",x"D",x"2",x"B",x"9",x"F",x"D",x"2",x"7",x"A",x"A",x"1",x"7",x"A",x"1",x"9",
x"8",x"5",x"8",x"3",x"F",x"5",x"8",x"0",x"E",x"B",x"0",x"8",x"0",x"0",x"7",x"4",x"4",x"E",x"E",x"5",x"B",x"6",x"B",x"3",x"6",x"4",x"8",x"D",x"E",x"A",x"9",x"5",x"8",x"4",x"0",
-- IDcell 31   Segment 0
x"A",x"6",x"D",x"3",x"D",x"3",x"3",x"A",x"D",x"9",x"B",x"5",x"6",x"8",x"6",x"2",x"D",x"B",x"F",x"0",x"7",x"6",x"E",x"3",x"A",x"C",x"E",x"6",x"A",x"3",x"1",x"5",x"0",x"5",x"1",x"0",
x"C",x"C",x"C",x"8",x"B",x"E",x"7",x"7",x"D",x"E",x"4",x"E",x"6",x"E",x"1",x"0",x"E",x"B",x"5",x"F",x"E",x"1",x"6",x"3",x"7",x"6",x"5",x"6",x"4",x"7",x"D",x"0",x"7",x"D",x"F",
-- IDcell 0   Segment 1
x"5",x"2",x"8",x"4",x"9",x"D",x"8",x"F",x"0",x"2",x"0",x"E",x"A",x"6",x"5",x"8",x"3",x"0",x"3",x"2",x"9",x"1",x"7",x"F",x"3",x"6",x"E",x"8",x"B",x"6",x"2",x"D",x"F",x"D",x"1",x"8",
x"A",x"D",x"4",x"D",x"7",x"7",x"A",x"7",x"D",x"2",x"D",x"8",x"E",x"C",x"2",x"D",x"4",x"F",x"2",x"0",x"C",x"C",x"0",x"C",x"7",x"5",x"B",x"7",x"D",x"4",x"D",x"F",x"7",x"0",x"8",
-- IDcell 1   Segment 1
x"C",x"C",x"5",x"3",x"A",x"1",x"5",x"2",x"2",x"0",x"9",x"D",x"E",x"C",x"7",x"E",x"6",x"1",x"A",x"0",x"6",x"1",x"9",x"5",x"E",x"3",x"F",x"A",x"6",x"3",x"3",x"0",x"7",x"6",x"F",x"7",
x"A",x"E",x"1",x"B",x"A",x"F",x"F",x"E",x"8",x"3",x"C",x"E",x"5",x"6",x"5",x"0",x"8",x"7",x"C",x"0",x"5",x"0",x"7",x"B",x"A",x"5",x"9",x"6",x"E",x"0",x"B",x"D",x"9",x"9",x"0",
-- IDcell 2   Segment 1
x"1",x"7",x"D",x"9",x"8",x"A",x"7",x"E",x"3",x"2",x"C",x"C",x"A",x"9",x"B",x"1",x"4",x"2",x"F",x"E",x"3",x"2",x"D",x"B",x"3",x"7",x"B",x"2",x"B",x"F",x"7",x"2",x"6",x"E",x"2",x"5",
x"A",x"A",x"7",x"A",x"5",x"5",x"7",x"F",x"F",x"B",x"5",x"C",x"4",x"0",x"0",x"B",x"4",x"7",x"A",x"3",x"8",x"B",x"1",x"6",x"C",x"F",x"1",x"8",x"E",x"1",x"E",x"D",x"E",x"6",x"3",
-- IDcell 3   Segment 1
x"A",x"5",x"B",x"A",x"8",x"C",x"7",x"E",x"2",x"C",x"7",x"9",x"5",x"C",x"9",x"F",x"8",x"4",x"E",x"B",x"B",x"D",x"4",x"2",x"5",x"9",x"9",x"2",x"7",x"6",x"6",x"B",x"D",x"E",x"5",x"5",
x"4",x"9",x"A",x"7",x"A",x"9",x"F",x"7",x"E",x"F",x"7",x"E",x"4",x"4",x"A",x"F",x"D",x"9",x"4",x"1",x"C",x"6",x"0",x"8",x"4",x"5",x"6",x"8",x"6",x"3",x"8",x"F",x"E",x"8",x"4",
-- IDcell 4   Segment 1
x"3",x"3",x"E",x"5",x"7",x"E",x"7",x"8",x"A",x"5",x"6",x"9",x"6",x"2",x"5",x"5",x"C",x"A",x"6",x"1",x"A",x"E",x"3",x"6",x"0",x"2",x"7",x"0",x"3",x"6",x"D",x"A",x"6",x"1",x"9",x"E",
x"4",x"9",x"3",x"A",x"0",x"A",x"8",x"F",x"9",x"5",x"D",x"9",x"9",x"1",x"5",x"C",x"6",x"E",x"6",x"1",x"F",x"3",x"0",x"0",x"6",x"C",x"B",x"9",x"7",x"0",x"6",x"B",x"E",x"B",x"A",
-- IDcell 5   Segment 1
x"0",x"9",x"9",x"6",x"1",x"E",x"7",x"3",x"0",x"9",x"A",x"9",x"B",x"7",x"F",x"3",x"9",x"2",x"9",x"C",x"3",x"7",x"0",x"C",x"5",x"1",x"9",x"1",x"0",x"E",x"B",x"A",x"B",x"1",x"B",x"4",
x"F",x"4",x"0",x"9",x"F",x"A",x"9",x"7",x"6",x"A",x"E",x"8",x"6",x"7",x"9",x"F",x"3",x"5",x"4",x"C",x"8",x"4",x"C",x"4",x"0",x"5",x"1",x"F",x"3",x"7",x"1",x"F",x"9",x"0",x"2",
-- IDcell 6   Segment 1
x"5",x"0",x"8",x"A",x"9",x"E",x"B",x"A",x"E",x"F",x"3",x"C",x"7",x"E",x"0",x"9",x"C",x"F",x"C",x"F",x"C",x"0",x"B",x"6",x"F",x"4",x"4",x"4",x"A",x"0",x"9",x"B",x"4",x"5",x"A",x"1",
x"3",x"0",x"E",x"F",x"C",x"8",x"C",x"5",x"B",x"2",x"2",x"B",x"C",x"E",x"8",x"7",x"2",x"1",x"3",x"8",x"5",x"4",x"E",x"7",x"C",x"9",x"D",x"3",x"2",x"9",x"C",x"9",x"A",x"D",x"C",
-- IDcell 7   Segment 1
x"A",x"A",x"C",x"E",x"E",x"F",x"9",x"B",x"C",x"D",x"C",x"8",x"2",x"E",x"4",x"A",x"D",x"5",x"2",x"5",x"1",x"8",x"5",x"B",x"0",x"7",x"C",x"B",x"A",x"B",x"C",x"B",x"7",x"4",x"8",x"6",
x"1",x"D",x"1",x"6",x"F",x"7",x"C",x"2",x"5",x"C",x"F",x"B",x"A",x"9",x"1",x"7",x"B",x"0",x"5",x"4",x"6",x"3",x"A",x"D",x"6",x"5",x"3",x"9",x"1",x"A",x"F",x"8",x"4",x"0",x"D",
-- IDcell 8   Segment 1
x"2",x"3",x"0",x"6",x"0",x"A",x"C",x"C",x"5",x"A",x"1",x"2",x"5",x"D",x"A",x"B",x"2",x"0",x"7",x"E",x"E",x"E",x"E",x"4",x"7",x"B",x"4",x"E",x"E",x"E",x"1",x"E",x"8",x"4",x"6",x"6",
x"B",x"D",x"1",x"7",x"D",x"D",x"A",x"2",x"E",x"B",x"3",x"C",x"D",x"9",x"0",x"D",x"2",x"A",x"B",x"7",x"A",x"7",x"5",x"8",x"C",x"2",x"1",x"3",x"E",x"6",x"D",x"7",x"F",x"E",x"5",
-- IDcell 9   Segment 1
x"C",x"A",x"5",x"5",x"5",x"2",x"1",x"6",x"6",x"7",x"B",x"D",x"A",x"8",x"B",x"6",x"F",x"1",x"B",x"2",x"0",x"5",x"2",x"0",x"1",x"A",x"5",x"1",x"B",x"3",x"A",x"0",x"C",x"0",x"5",x"D",
x"E",x"9",x"E",x"A",x"0",x"6",x"B",x"C",x"7",x"3",x"2",x"6",x"8",x"7",x"3",x"0",x"A",x"8",x"1",x"A",x"9",x"9",x"2",x"7",x"7",x"7",x"0",x"2",x"1",x"F",x"4",x"6",x"0",x"5",x"5",
-- IDcell 10   Segment 1
x"0",x"5",x"A",x"D",x"F",x"C",x"A",x"2",x"F",x"8",x"2",x"0",x"7",x"D",x"C",x"6",x"F",x"F",x"8",x"D",x"1",x"A",x"8",x"5",x"A",x"1",x"D",x"D",x"4",x"6",x"9",x"4",x"D",x"4",x"C",x"4",
x"8",x"A",x"8",x"3",x"8",x"C",x"4",x"F",x"8",x"3",x"3",x"C",x"5",x"3",x"2",x"7",x"1",x"0",x"0",x"2",x"1",x"A",x"C",x"4",x"4",x"8",x"A",x"7",x"B",x"6",x"2",x"B",x"8",x"D",x"D",
-- IDcell 11   Segment 1
x"2",x"1",x"8",x"C",x"9",x"5",x"1",x"2",x"2",x"3",x"D",x"7",x"B",x"7",x"1",x"2",x"D",x"C",x"9",x"8",x"F",x"8",x"B",x"5",x"2",x"1",x"7",x"3",x"8",x"8",x"A",x"8",x"3",x"0",x"0",x"0",
x"3",x"C",x"5",x"F",x"2",x"A",x"0",x"0",x"F",x"2",x"3",x"2",x"D",x"D",x"3",x"4",x"7",x"5",x"D",x"2",x"F",x"C",x"7",x"8",x"C",x"2",x"5",x"B",x"8",x"D",x"8",x"8",x"F",x"F",x"9",
-- IDcell 12   Segment 1
x"7",x"9",x"B",x"9",x"4",x"D",x"2",x"4",x"D",x"7",x"2",x"1",x"1",x"2",x"1",x"E",x"F",x"6",x"7",x"8",x"B",x"7",x"1",x"5",x"6",x"F",x"8",x"D",x"2",x"6",x"6",x"6",x"D",x"E",x"7",x"1",
x"2",x"B",x"B",x"F",x"3",x"8",x"3",x"7",x"C",x"8",x"5",x"A",x"9",x"5",x"1",x"8",x"7",x"8",x"1",x"9",x"0",x"3",x"1",x"4",x"6",x"A",x"7",x"B",x"4",x"D",x"4",x"2",x"A",x"2",x"8",
-- IDcell 13   Segment 1
x"5",x"8",x"A",x"A",x"B",x"E",x"F",x"6",x"A",x"6",x"B",x"D",x"E",x"4",x"0",x"1",x"1",x"C",x"A",x"C",x"5",x"8",x"3",x"C",x"5",x"1",x"0",x"4",x"B",x"2",x"C",x"6",x"F",x"C",x"5",x"A",
x"2",x"9",x"8",x"0",x"F",x"8",x"5",x"6",x"3",x"7",x"3",x"E",x"5",x"9",x"3",x"1",x"A",x"3",x"C",x"6",x"9",x"0",x"2",x"4",x"5",x"3",x"2",x"7",x"5",x"8",x"1",x"F",x"A",x"1",x"3",
-- IDcell 14   Segment 1
x"4",x"2",x"7",x"D",x"1",x"A",x"D",x"1",x"8",x"E",x"3",x"3",x"8",x"E",x"1",x"6",x"F",x"C",x"E",x"6",x"E",x"2",x"3",x"B",x"4",x"A",x"D",x"6",x"D",x"8",x"2",x"A",x"2",x"1",x"4",x"4",
x"D",x"5",x"3",x"0",x"4",x"8",x"F",x"2",x"6",x"6",x"5",x"A",x"A",x"9",x"4",x"5",x"7",x"7",x"A",x"F",x"A",x"B",x"D",x"2",x"6",x"8",x"8",x"9",x"F",x"C",x"B",x"1",x"F",x"9",x"F",
-- IDcell 15   Segment 1
x"3",x"3",x"7",x"F",x"E",x"0",x"E",x"4",x"C",x"1",x"5",x"A",x"2",x"2",x"4",x"7",x"1",x"A",x"E",x"0",x"F",x"6",x"B",x"6",x"F",x"9",x"1",x"1",x"6",x"1",x"A",x"7",x"D",x"E",x"2",x"E",
x"1",x"4",x"0",x"3",x"D",x"7",x"3",x"5",x"8",x"7",x"D",x"5",x"C",x"8",x"3",x"5",x"5",x"1",x"0",x"5",x"D",x"2",x"F",x"7",x"0",x"6",x"4",x"2",x"B",x"2",x"C",x"E",x"4",x"2",x"5",
-- IDcell 16   Segment 1
x"A",x"3",x"F",x"C",x"A",x"A",x"3",x"1",x"1",x"B",x"5",x"3",x"6",x"A",x"C",x"9",x"D",x"B",x"3",x"9",x"F",x"E",x"D",x"9",x"F",x"4",x"E",x"9",x"9",x"6",x"5",x"0",x"6",x"B",x"3",x"1",
x"8",x"1",x"C",x"5",x"8",x"D",x"6",x"B",x"7",x"E",x"0",x"4",x"1",x"5",x"7",x"A",x"3",x"F",x"D",x"4",x"6",x"3",x"F",x"6",x"0",x"4",x"6",x"8",x"7",x"6",x"5",x"B",x"C",x"F",x"D",
-- IDcell 17   Segment 1
x"F",x"4",x"8",x"4",x"F",x"D",x"1",x"F",x"5",x"7",x"F",x"5",x"3",x"A",x"4",x"A",x"7",x"4",x"9",x"B",x"8",x"6",x"1",x"4",x"8",x"E",x"0",x"B",x"1",x"D",x"0",x"6",x"5",x"3",x"6",x"6",
x"7",x"C",x"E",x"1",x"3",x"9",x"3",x"1",x"9",x"8",x"8",x"7",x"5",x"D",x"D",x"B",x"0",x"A",x"E",x"9",x"1",x"7",x"9",x"B",x"B",x"B",x"D",x"A",x"A",x"D",x"5",x"3",x"A",x"1",x"1",
-- IDcell 18   Segment 1
x"A",x"3",x"E",x"9",x"E",x"C",x"F",x"1",x"E",x"6",x"0",x"4",x"8",x"5",x"6",x"2",x"B",x"C",x"8",x"9",x"D",x"B",x"6",x"1",x"6",x"8",x"E",x"7",x"0",x"8",x"8",x"5",x"5",x"F",x"0",x"D",
x"4",x"A",x"D",x"2",x"9",x"F",x"8",x"5",x"9",x"E",x"F",x"3",x"6",x"C",x"9",x"1",x"6",x"0",x"D",x"F",x"4",x"0",x"7",x"D",x"8",x"5",x"4",x"2",x"6",x"2",x"3",x"3",x"6",x"3",x"2",
-- IDcell 19   Segment 1
x"8",x"9",x"0",x"5",x"1",x"9",x"3",x"7",x"6",x"D",x"1",x"F",x"F",x"A",x"A",x"2",x"8",x"9",x"4",x"E",x"A",x"B",x"C",x"D",x"6",x"6",x"6",x"3",x"B",x"0",x"A",x"3",x"C",x"2",x"4",x"1",
x"1",x"9",x"8",x"2",x"C",x"1",x"7",x"B",x"0",x"1",x"2",x"7",x"0",x"E",x"0",x"F",x"B",x"0",x"B",x"2",x"8",x"9",x"D",x"4",x"B",x"C",x"8",x"C",x"3",x"B",x"8",x"3",x"D",x"A",x"9",
-- IDcell 20   Segment 1
x"0",x"9",x"8",x"4",x"7",x"B",x"6",x"1",x"8",x"7",x"B",x"B",x"5",x"F",x"6",x"F",x"6",x"7",x"2",x"8",x"B",x"4",x"E",x"D",x"6",x"1",x"0",x"0",x"8",x"8",x"F",x"A",x"D",x"9",x"D",x"A",
x"D",x"F",x"C",x"0",x"0",x"7",x"4",x"8",x"E",x"9",x"D",x"C",x"D",x"8",x"A",x"0",x"C",x"E",x"3",x"2",x"0",x"D",x"6",x"C",x"9",x"9",x"1",x"6",x"5",x"4",x"A",x"B",x"E",x"0",x"5",
-- IDcell 21   Segment 1
x"3",x"2",x"8",x"5",x"A",x"E",x"0",x"A",x"3",x"D",x"1",x"9",x"6",x"3",x"1",x"3",x"6",x"5",x"9",x"C",x"3",x"7",x"B",x"E",x"1",x"C",x"9",x"4",x"D",x"6",x"1",x"D",x"2",x"0",x"F",x"1",
x"1",x"F",x"D",x"4",x"9",x"D",x"9",x"F",x"D",x"F",x"9",x"D",x"1",x"0",x"2",x"6",x"F",x"F",x"5",x"7",x"6",x"3",x"F",x"0",x"2",x"C",x"B",x"7",x"8",x"A",x"E",x"1",x"3",x"5",x"C",
-- IDcell 22   Segment 1
x"0",x"0",x"6",x"9",x"D",x"3",x"F",x"3",x"4",x"D",x"0",x"D",x"4",x"5",x"5",x"A",x"F",x"B",x"4",x"5",x"F",x"E",x"F",x"D",x"F",x"7",x"1",x"6",x"3",x"3",x"3",x"B",x"7",x"8",x"5",x"C",
x"6",x"B",x"D",x"A",x"9",x"0",x"D",x"A",x"2",x"3",x"F",x"1",x"C",x"C",x"6",x"8",x"B",x"C",x"6",x"A",x"1",x"D",x"B",x"C",x"9",x"1",x"6",x"C",x"5",x"9",x"5",x"D",x"A",x"3",x"E",
-- IDcell 23   Segment 1
x"A",x"A",x"9",x"7",x"7",x"A",x"8",x"B",x"C",x"A",x"3",x"9",x"3",x"8",x"1",x"E",x"7",x"C",x"3",x"5",x"A",x"1",x"A",x"C",x"C",x"7",x"C",x"4",x"F",x"6",x"0",x"4",x"2",x"1",x"C",x"0",
x"8",x"6",x"2",x"B",x"F",x"D",x"6",x"1",x"0",x"6",x"C",x"7",x"C",x"0",x"2",x"5",x"B",x"0",x"6",x"7",x"6",x"E",x"A",x"0",x"E",x"F",x"6",x"8",x"9",x"7",x"2",x"D",x"D",x"8",x"F",
-- IDcell 24   Segment 1
x"F",x"3",x"1",x"0",x"7",x"4",x"5",x"C",x"4",x"9",x"7",x"0",x"9",x"4",x"A",x"B",x"E",x"5",x"6",x"E",x"0",x"4",x"9",x"0",x"C",x"0",x"8",x"0",x"0",x"3",x"1",x"9",x"D",x"B",x"E",x"2",
x"9",x"0",x"5",x"5",x"3",x"E",x"6",x"9",x"6",x"B",x"6",x"8",x"5",x"9",x"6",x"3",x"5",x"A",x"F",x"0",x"3",x"B",x"1",x"2",x"1",x"F",x"7",x"9",x"D",x"9",x"2",x"5",x"D",x"1",x"9",
-- IDcell 25   Segment 1
x"9",x"6",x"4",x"D",x"F",x"D",x"3",x"5",x"0",x"B",x"9",x"C",x"7",x"D",x"F",x"D",x"C",x"7",x"F",x"6",x"F",x"7",x"C",x"4",x"3",x"2",x"8",x"3",x"A",x"7",x"6",x"F",x"0",x"D",x"6",x"1",
x"3",x"E",x"4",x"8",x"A",x"5",x"5",x"2",x"0",x"D",x"1",x"D",x"A",x"F",x"7",x"6",x"1",x"C",x"6",x"F",x"4",x"7",x"E",x"3",x"8",x"9",x"B",x"4",x"3",x"A",x"0",x"2",x"3",x"F",x"5",
-- IDcell 26   Segment 1
x"6",x"D",x"7",x"6",x"7",x"B",x"8",x"8",x"D",x"2",x"8",x"A",x"4",x"5",x"5",x"C",x"C",x"3",x"B",x"5",x"6",x"C",x"9",x"4",x"2",x"B",x"A",x"F",x"D",x"8",x"E",x"4",x"6",x"5",x"A",x"5",
x"0",x"F",x"D",x"2",x"C",x"2",x"2",x"F",x"E",x"6",x"1",x"6",x"2",x"E",x"0",x"3",x"A",x"9",x"A",x"A",x"C",x"3",x"C",x"1",x"C",x"C",x"8",x"9",x"9",x"8",x"0",x"0",x"6",x"1",x"0",
-- IDcell 27   Segment 1
x"C",x"5",x"4",x"9",x"1",x"C",x"6",x"C",x"A",x"3",x"D",x"9",x"9",x"8",x"9",x"0",x"6",x"E",x"C",x"1",x"4",x"8",x"2",x"F",x"8",x"1",x"5",x"B",x"7",x"4",x"B",x"7",x"C",x"2",x"E",x"3",
x"8",x"1",x"6",x"B",x"6",x"8",x"2",x"A",x"C",x"C",x"6",x"0",x"0",x"9",x"A",x"B",x"7",x"E",x"F",x"F",x"3",x"4",x"B",x"F",x"0",x"E",x"9",x"C",x"E",x"5",x"9",x"C",x"7",x"5",x"4",
-- IDcell 28   Segment 1
x"6",x"D",x"8",x"E",x"E",x"3",x"2",x"D",x"3",x"0",x"E",x"1",x"9",x"D",x"9",x"3",x"A",x"0",x"E",x"5",x"A",x"D",x"8",x"2",x"2",x"6",x"B",x"A",x"E",x"9",x"C",x"F",x"6",x"F",x"C",x"B",
x"A",x"1",x"7",x"C",x"F",x"6",x"E",x"6",x"7",x"F",x"D",x"C",x"5",x"A",x"1",x"5",x"A",x"8",x"1",x"E",x"C",x"B",x"8",x"9",x"0",x"8",x"B",x"E",x"D",x"D",x"7",x"7",x"C",x"8",x"0",
-- IDcell 29   Segment 1
x"9",x"8",x"F",x"8",x"B",x"F",x"D",x"F",x"7",x"7",x"4",x"C",x"7",x"A",x"2",x"4",x"9",x"4",x"1",x"8",x"E",x"6",x"F",x"F",x"4",x"7",x"2",x"3",x"D",x"6",x"E",x"6",x"A",x"B",x"2",x"F",
x"0",x"9",x"1",x"C",x"D",x"E",x"4",x"D",x"E",x"1",x"C",x"E",x"1",x"1",x"D",x"3",x"B",x"D",x"4",x"6",x"3",x"B",x"5",x"0",x"9",x"F",x"B",x"7",x"1",x"6",x"9",x"4",x"0",x"F",x"D",
-- IDcell 30   Segment 1
x"6",x"5",x"3",x"0",x"0",x"B",x"A",x"D",x"8",x"F",x"F",x"A",x"2",x"1",x"B",x"C",x"7",x"D",x"C",x"2",x"C",x"1",x"F",x"7",x"9",x"F",x"A",x"9",x"7",x"A",x"9",x"F",x"4",x"6",x"9",x"C",
x"C",x"C",x"9",x"E",x"2",x"7",x"0",x"A",x"6",x"1",x"7",x"5",x"9",x"F",x"3",x"4",x"D",x"6",x"2",x"7",x"6",x"F",x"5",x"7",x"C",x"B",x"E",x"B",x"0",x"0",x"9",x"C",x"D",x"2",x"1",
-- IDcell 31   Segment 1
x"6",x"F",x"3",x"6",x"B",x"B",x"6",x"D",x"5",x"A",x"7",x"D",x"C",x"4",x"F",x"B",x"7",x"2",x"0",x"4",x"3",x"9",x"E",x"9",x"1",x"F",x"F",x"0",x"D",x"E",x"8",x"6",x"D",x"D",x"6",x"C",
x"4",x"B",x"9",x"3",x"C",x"F",x"C",x"4",x"2",x"7",x"1",x"F",x"2",x"B",x"C",x"C",x"6",x"1",x"6",x"9",x"6",x"1",x"6",x"E",x"3",x"A",x"E",x"A",x"A",x"1",x"9",x"E",x"3",x"6",x"0",
-- IDcell 0   Segment 2
x"D",x"2",x"7",x"B",x"0",x"0",x"C",x"7",x"0",x"A",x"8",x"A",x"A",x"2",x"C",x"0",x"3",x"6",x"A",x"D",x"D",x"4",x"E",x"9",x"9",x"D",x"0",x"4",x"7",x"A",x"3",x"7",x"6",x"B",x"3",x"6",
x"3",x"F",x"E",x"D",x"C",x"2",x"8",x"7",x"B",x"8",x"F",x"D",x"1",x"A",x"7",x"7",x"9",x"4",x"8",x"1",x"8",x"C",x"5",x"8",x"7",x"3",x"E",x"C",x"D",x"0",x"D",x"3",x"D",x"5",x"6",
-- IDcell 1   Segment 2
x"E",x"7",x"F",x"D",x"D",x"C",x"E",x"E",x"D",x"8",x"D",x"3",x"1",x"B",x"2",x"C",x"0",x"7",x"5",x"2",x"D",x"9",x"7",x"6",x"D",x"E",x"9",x"2",x"B",x"E",x"A",x"2",x"4",x"1",x"A",x"7",
x"1",x"3",x"C",x"F",x"8",x"1",x"8",x"C",x"2",x"7",x"4",x"A",x"A",x"1",x"C",x"2",x"E",x"3",x"8",x"6",x"2",x"C",x"7",x"E",x"B",x"7",x"0",x"2",x"3",x"A",x"F",x"3",x"5",x"D",x"4",
-- IDcell 2   Segment 2
x"8",x"7",x"B",x"F",x"4",x"9",x"5",x"4",x"0",x"2",x"2",x"D",x"3",x"0",x"5",x"4",x"9",x"D",x"F",x"7",x"3",x"4",x"8",x"4",x"7",x"7",x"E",x"A",x"C",x"B",x"9",x"7",x"A",x"C",x"3",x"5",
x"6",x"5",x"B",x"8",x"3",x"8",x"4",x"6",x"0",x"C",x"C",x"6",x"2",x"F",x"2",x"4",x"2",x"8",x"8",x"3",x"3",x"1",x"3",x"B",x"1",x"5",x"C",x"3",x"1",x"3",x"7",x"0",x"3",x"3",x"5",
-- IDcell 3   Segment 2
x"8",x"2",x"D",x"D",x"8",x"3",x"0",x"B",x"E",x"D",x"E",x"4",x"F",x"1",x"3",x"C",x"7",x"6",x"E",x"4",x"C",x"F",x"9",x"A",x"E",x"F",x"5",x"E",x"4",x"2",x"6",x"0",x"9",x"F",x"0",x"B",
x"D",x"D",x"C",x"B",x"0",x"0",x"0",x"A",x"7",x"4",x"2",x"B",x"6",x"3",x"7",x"2",x"D",x"D",x"5",x"2",x"2",x"5",x"B",x"0",x"C",x"3",x"1",x"1",x"4",x"4",x"9",x"4",x"7",x"4",x"6",
-- IDcell 4   Segment 2
x"4",x"E",x"0",x"6",x"E",x"4",x"C",x"F",x"4",x"6",x"E",x"1",x"F",x"5",x"6",x"9",x"1",x"9",x"3",x"8",x"D",x"7",x"F",x"4",x"0",x"1",x"7",x"9",x"D",x"8",x"F",x"7",x"9",x"A",x"8",x"5",
x"2",x"1",x"6",x"7",x"7",x"5",x"3",x"8",x"4",x"B",x"D",x"9",x"7",x"9",x"6",x"6",x"D",x"B",x"4",x"B",x"B",x"F",x"4",x"9",x"F",x"B",x"6",x"F",x"A",x"B",x"8",x"F",x"9",x"4",x"5",
-- IDcell 5   Segment 2
x"6",x"4",x"1",x"6",x"4",x"5",x"3",x"4",x"5",x"6",x"9",x"A",x"5",x"E",x"6",x"7",x"0",x"F",x"D",x"B",x"3",x"9",x"0",x"D",x"0",x"9",x"C",x"0",x"4",x"8",x"0",x"2",x"D",x"D",x"6",x"A",
x"1",x"6",x"B",x"0",x"2",x"2",x"C",x"A",x"D",x"C",x"7",x"7",x"E",x"D",x"D",x"7",x"4",x"6",x"4",x"A",x"F",x"E",x"D",x"4",x"3",x"C",x"7",x"7",x"3",x"A",x"8",x"D",x"C",x"7",x"6",
-- IDcell 6   Segment 2
x"F",x"B",x"8",x"7",x"6",x"9",x"A",x"8",x"1",x"A",x"A",x"9",x"D",x"B",x"6",x"0",x"7",x"F",x"1",x"4",x"A",x"6",x"A",x"9",x"5",x"9",x"4",x"8",x"4",x"0",x"1",x"F",x"8",x"3",x"0",x"5",
x"7",x"C",x"D",x"C",x"9",x"C",x"9",x"C",x"3",x"9",x"9",x"6",x"B",x"A",x"5",x"8",x"2",x"1",x"4",x"0",x"3",x"A",x"4",x"9",x"F",x"0",x"0",x"A",x"4",x"E",x"3",x"5",x"1",x"9",x"1",
-- IDcell 7   Segment 2
x"7",x"7",x"7",x"1",x"0",x"D",x"6",x"F",x"4",x"0",x"B",x"4",x"F",x"7",x"9",x"C",x"C",x"6",x"3",x"F",x"6",x"7",x"8",x"5",x"5",x"1",x"C",x"3",x"E",x"C",x"1",x"8",x"F",x"A",x"9",x"D",
x"F",x"2",x"C",x"8",x"2",x"E",x"6",x"C",x"8",x"F",x"4",x"1",x"5",x"D",x"A",x"D",x"F",x"D",x"6",x"3",x"2",x"6",x"4",x"B",x"7",x"5",x"1",x"3",x"1",x"8",x"0",x"0",x"7",x"0",x"E",
-- IDcell 8   Segment 2
x"5",x"0",x"3",x"F",x"1",x"9",x"6",x"B",x"B",x"F",x"9",x"3",x"C",x"2",x"3",x"8",x"B",x"F",x"D",x"5",x"E",x"7",x"3",x"5",x"E",x"5",x"A",x"E",x"5",x"2",x"E",x"0",x"D",x"A",x"E",x"6",
x"4",x"F",x"5",x"E",x"2",x"F",x"4",x"C",x"3",x"B",x"9",x"2",x"E",x"5",x"5",x"3",x"F",x"5",x"1",x"3",x"0",x"3",x"C",x"4",x"A",x"6",x"4",x"C",x"4",x"4",x"0",x"3",x"B",x"F",x"3",
-- IDcell 9   Segment 2
x"5",x"F",x"D",x"4",x"A",x"6",x"8",x"9",x"4",x"5",x"6",x"6",x"6",x"7",x"8",x"C",x"9",x"5",x"B",x"9",x"D",x"5",x"A",x"5",x"9",x"D",x"D",x"E",x"5",x"3",x"6",x"6",x"7",x"9",x"9",x"0",
x"4",x"5",x"F",x"E",x"B",x"0",x"3",x"A",x"2",x"B",x"A",x"A",x"7",x"4",x"0",x"9",x"4",x"1",x"4",x"0",x"E",x"9",x"0",x"6",x"8",x"C",x"6",x"1",x"C",x"2",x"E",x"9",x"7",x"2",x"C",
-- IDcell 10   Segment 2
x"9",x"5",x"B",x"5",x"8",x"4",x"D",x"C",x"4",x"0",x"C",x"8",x"B",x"5",x"D",x"E",x"A",x"D",x"6",x"3",x"D",x"4",x"8",x"F",x"C",x"E",x"6",x"5",x"B",x"1",x"E",x"6",x"1",x"B",x"A",x"B",
x"4",x"C",x"5",x"9",x"7",x"D",x"9",x"2",x"1",x"D",x"B",x"1",x"2",x"6",x"7",x"7",x"1",x"4",x"1",x"E",x"2",x"F",x"F",x"E",x"7",x"C",x"0",x"A",x"A",x"3",x"D",x"A",x"0",x"D",x"5",
-- IDcell 11   Segment 2
x"9",x"8",x"5",x"7",x"6",x"3",x"A",x"B",x"6",x"C",x"C",x"8",x"9",x"3",x"4",x"D",x"B",x"8",x"A",x"0",x"B",x"E",x"7",x"3",x"8",x"A",x"7",x"A",x"F",x"1",x"D",x"1",x"F",x"A",x"3",x"9",
x"5",x"8",x"C",x"1",x"F",x"9",x"E",x"2",x"D",x"6",x"A",x"5",x"1",x"A",x"1",x"6",x"3",x"E",x"4",x"7",x"A",x"0",x"A",x"6",x"E",x"5",x"F",x"E",x"B",x"7",x"5",x"9",x"F",x"D",x"D",
-- IDcell 12   Segment 2
x"F",x"D",x"8",x"D",x"4",x"5",x"F",x"0",x"0",x"D",x"9",x"4",x"3",x"A",x"D",x"9",x"8",x"6",x"B",x"D",x"3",x"5",x"3",x"D",x"6",x"1",x"C",x"6",x"7",x"4",x"6",x"D",x"B",x"F",x"8",x"A",
x"3",x"0",x"9",x"B",x"6",x"A",x"E",x"1",x"C",x"1",x"7",x"3",x"B",x"8",x"8",x"0",x"D",x"9",x"5",x"7",x"B",x"7",x"6",x"D",x"C",x"0",x"3",x"1",x"A",x"9",x"5",x"7",x"E",x"8",x"D",
-- IDcell 13   Segment 2
x"A",x"E",x"4",x"3",x"2",x"3",x"5",x"3",x"4",x"F",x"6",x"E",x"F",x"B",x"1",x"A",x"2",x"0",x"1",x"6",x"9",x"3",x"2",x"8",x"4",x"1",x"7",x"8",x"8",x"5",x"E",x"F",x"3",x"0",x"4",x"F",
x"A",x"2",x"2",x"0",x"3",x"8",x"9",x"F",x"A",x"9",x"C",x"2",x"6",x"0",x"7",x"E",x"5",x"A",x"4",x"0",x"6",x"F",x"4",x"C",x"E",x"4",x"A",x"7",x"4",x"9",x"8",x"A",x"3",x"9",x"F",
-- IDcell 14   Segment 2
x"E",x"5",x"2",x"0",x"5",x"5",x"7",x"9",x"8",x"9",x"3",x"B",x"E",x"1",x"8",x"4",x"C",x"B",x"9",x"9",x"4",x"8",x"C",x"2",x"8",x"E",x"2",x"F",x"9",x"A",x"A",x"F",x"6",x"9",x"9",x"D",
x"4",x"7",x"B",x"6",x"E",x"5",x"E",x"0",x"B",x"2",x"1",x"9",x"C",x"B",x"E",x"A",x"F",x"E",x"4",x"B",x"E",x"C",x"8",x"D",x"5",x"6",x"1",x"B",x"D",x"8",x"0",x"9",x"E",x"3",x"4",
-- IDcell 15   Segment 2
x"A",x"B",x"1",x"1",x"D",x"6",x"9",x"4",x"1",x"4",x"7",x"8",x"D",x"3",x"6",x"D",x"5",x"6",x"9",x"5",x"C",x"E",x"8",x"1",x"3",x"0",x"7",x"0",x"D",x"C",x"1",x"E",x"3",x"2",x"1",x"2",
x"2",x"A",x"3",x"9",x"0",x"8",x"3",x"E",x"5",x"3",x"F",x"E",x"3",x"7",x"3",x"6",x"6",x"0",x"A",x"E",x"B",x"1",x"2",x"5",x"D",x"8",x"3",x"3",x"8",x"3",x"F",x"B",x"D",x"C",x"A",
-- IDcell 16   Segment 2
x"1",x"8",x"8",x"A",x"0",x"9",x"C",x"4",x"6",x"F",x"1",x"F",x"1",x"1",x"2",x"0",x"6",x"F",x"F",x"9",x"F",x"1",x"5",x"C",x"F",x"B",x"5",x"F",x"6",x"C",x"D",x"2",x"F",x"2",x"6",x"C",
x"4",x"B",x"F",x"4",x"8",x"5",x"E",x"E",x"3",x"7",x"D",x"3",x"6",x"5",x"0",x"A",x"5",x"9",x"5",x"0",x"6",x"4",x"F",x"7",x"6",x"C",x"E",x"3",x"4",x"E",x"4",x"0",x"E",x"A",x"D",
-- IDcell 17   Segment 2
x"4",x"B",x"1",x"C",x"D",x"E",x"2",x"5",x"5",x"3",x"9",x"A",x"5",x"6",x"C",x"E",x"D",x"C",x"4",x"5",x"F",x"E",x"7",x"F",x"5",x"4",x"C",x"3",x"8",x"C",x"F",x"1",x"5",x"5",x"F",x"4",
x"F",x"B",x"1",x"A",x"E",x"8",x"6",x"8",x"F",x"6",x"C",x"3",x"9",x"5",x"2",x"D",x"0",x"7",x"0",x"1",x"4",x"B",x"F",x"8",x"2",x"8",x"E",x"8",x"1",x"0",x"B",x"D",x"E",x"2",x"D",
-- IDcell 18   Segment 2
x"1",x"6",x"C",x"A",x"8",x"F",x"8",x"C",x"6",x"A",x"8",x"7",x"9",x"E",x"8",x"6",x"5",x"E",x"3",x"6",x"1",x"1",x"E",x"A",x"C",x"3",x"8",x"9",x"D",x"5",x"6",x"A",x"F",x"A",x"3",x"E",
x"4",x"E",x"8",x"4",x"C",x"D",x"B",x"B",x"7",x"3",x"5",x"6",x"7",x"B",x"A",x"4",x"A",x"1",x"6",x"0",x"2",x"4",x"9",x"C",x"4",x"B",x"6",x"8",x"0",x"A",x"7",x"D",x"9",x"B",x"C",
-- IDcell 19   Segment 2
x"3",x"9",x"D",x"2",x"B",x"0",x"8",x"A",x"A",x"0",x"E",x"2",x"E",x"8",x"7",x"8",x"1",x"4",x"7",x"6",x"0",x"2",x"7",x"B",x"4",x"1",x"A",x"D",x"7",x"2",x"F",x"8",x"D",x"9",x"8",x"3",
x"8",x"B",x"7",x"0",x"0",x"1",x"A",x"A",x"D",x"F",x"D",x"3",x"3",x"A",x"9",x"2",x"D",x"8",x"1",x"E",x"5",x"6",x"E",x"C",x"B",x"B",x"2",x"C",x"9",x"3",x"7",x"8",x"D",x"5",x"8",
-- IDcell 20   Segment 2
x"8",x"C",x"2",x"5",x"8",x"B",x"C",x"8",x"0",x"D",x"4",x"A",x"D",x"1",x"2",x"5",x"F",x"3",x"3",x"5",x"A",x"5",x"1",x"5",x"1",x"E",x"D",x"F",x"9",x"E",x"9",x"A",x"4",x"6",x"3",x"E",
x"0",x"6",x"C",x"5",x"C",x"8",x"D",x"0",x"4",x"6",x"F",x"8",x"2",x"E",x"5",x"D",x"C",x"3",x"D",x"7",x"3",x"E",x"F",x"4",x"D",x"2",x"2",x"3",x"1",x"C",x"5",x"D",x"1",x"4",x"F",
-- IDcell 21   Segment 2
x"4",x"1",x"A",x"0",x"2",x"9",x"C",x"6",x"3",x"5",x"6",x"C",x"8",x"2",x"5",x"5",x"8",x"5",x"1",x"7",x"9",x"C",x"5",x"3",x"4",x"8",x"E",x"D",x"F",x"0",x"7",x"A",x"3",x"A",x"C",x"2",
x"0",x"2",x"2",x"5",x"3",x"9",x"A",x"C",x"2",x"8",x"D",x"C",x"4",x"C",x"D",x"3",x"C",x"1",x"D",x"F",x"A",x"D",x"C",x"8",x"E",x"E",x"9",x"6",x"4",x"4",x"C",x"D",x"9",x"3",x"9",
-- IDcell 22   Segment 2
x"0",x"D",x"7",x"0",x"A",x"7",x"7",x"C",x"B",x"E",x"9",x"8",x"0",x"4",x"9",x"1",x"3",x"B",x"F",x"B",x"E",x"C",x"4",x"F",x"B",x"F",x"9",x"1",x"7",x"C",x"5",x"C",x"D",x"3",x"5",x"8",
x"0",x"F",x"6",x"0",x"6",x"2",x"B",x"B",x"A",x"D",x"3",x"F",x"9",x"9",x"E",x"C",x"E",x"B",x"B",x"4",x"A",x"9",x"E",x"B",x"B",x"8",x"7",x"5",x"2",x"3",x"A",x"B",x"7",x"2",x"2",
-- IDcell 23   Segment 2
x"6",x"A",x"0",x"0",x"A",x"3",x"0",x"9",x"0",x"1",x"F",x"9",x"F",x"D",x"E",x"4",x"4",x"B",x"4",x"F",x"1",x"E",x"C",x"E",x"D",x"4",x"4",x"E",x"0",x"B",x"C",x"B",x"9",x"4",x"3",x"B",
x"2",x"9",x"5",x"1",x"9",x"F",x"3",x"1",x"3",x"B",x"E",x"4",x"4",x"9",x"6",x"D",x"3",x"4",x"F",x"3",x"9",x"B",x"1",x"5",x"4",x"F",x"C",x"2",x"3",x"8",x"4",x"C",x"B",x"7",x"5",
-- IDcell 24   Segment 2
x"9",x"5",x"3",x"5",x"1",x"1",x"0",x"7",x"A",x"8",x"B",x"E",x"6",x"A",x"B",x"F",x"C",x"2",x"4",x"C",x"1",x"2",x"9",x"2",x"F",x"E",x"1",x"A",x"0",x"F",x"E",x"6",x"7",x"7",x"C",x"B",
x"F",x"D",x"0",x"4",x"F",x"2",x"E",x"8",x"1",x"1",x"7",x"8",x"C",x"A",x"A",x"9",x"D",x"2",x"9",x"4",x"7",x"3",x"0",x"E",x"F",x"9",x"C",x"9",x"4",x"6",x"F",x"6",x"7",x"6",x"E",
-- IDcell 25   Segment 2
x"0",x"1",x"F",x"2",x"1",x"4",x"7",x"0",x"F",x"D",x"9",x"B",x"1",x"E",x"0",x"B",x"3",x"C",x"6",x"B",x"2",x"F",x"7",x"C",x"0",x"4",x"1",x"2",x"A",x"1",x"5",x"7",x"6",x"4",x"C",x"2",
x"7",x"7",x"D",x"6",x"1",x"B",x"A",x"2",x"E",x"E",x"3",x"B",x"3",x"7",x"6",x"9",x"D",x"E",x"7",x"A",x"D",x"A",x"C",x"B",x"2",x"B",x"B",x"2",x"9",x"9",x"1",x"8",x"F",x"B",x"7",
-- IDcell 26   Segment 2
x"A",x"5",x"7",x"8",x"A",x"B",x"F",x"E",x"1",x"5",x"5",x"3",x"6",x"9",x"4",x"4",x"0",x"F",x"A",x"3",x"D",x"4",x"D",x"F",x"7",x"5",x"7",x"C",x"C",x"A",x"5",x"9",x"6",x"4",x"6",x"9",
x"B",x"8",x"0",x"A",x"0",x"E",x"5",x"6",x"B",x"F",x"E",x"6",x"0",x"1",x"0",x"D",x"D",x"6",x"3",x"E",x"6",x"7",x"C",x"E",x"D",x"B",x"8",x"6",x"B",x"B",x"1",x"E",x"F",x"3",x"9",
-- IDcell 27   Segment 2
x"1",x"E",x"1",x"C",x"F",x"F",x"A",x"B",x"0",x"3",x"1",x"8",x"3",x"6",x"7",x"7",x"7",x"D",x"E",x"5",x"D",x"1",x"6",x"8",x"A",x"9",x"2",x"4",x"6",x"C",x"5",x"5",x"9",x"5",x"7",x"4",
x"C",x"7",x"4",x"C",x"C",x"C",x"0",x"6",x"4",x"0",x"5",x"E",x"B",x"4",x"0",x"6",x"B",x"8",x"D",x"D",x"B",x"7",x"C",x"9",x"A",x"6",x"E",x"F",x"5",x"4",x"A",x"6",x"6",x"A",x"5",
-- IDcell 28   Segment 2
x"3",x"5",x"4",x"1",x"4",x"9",x"C",x"2",x"C",x"A",x"1",x"9",x"A",x"7",x"3",x"5",x"F",x"9",x"C",x"D",x"0",x"4",x"A",x"F",x"4",x"9",x"2",x"2",x"E",x"8",x"E",x"C",x"E",x"6",x"5",x"0",
x"9",x"B",x"9",x"7",x"8",x"B",x"9",x"5",x"1",x"F",x"9",x"4",x"6",x"F",x"D",x"4",x"A",x"D",x"3",x"6",x"C",x"7",x"F",x"9",x"C",x"8",x"3",x"6",x"2",x"4",x"2",x"0",x"5",x"E",x"7",
-- IDcell 29   Segment 2
x"5",x"A",x"2",x"7",x"E",x"6",x"0",x"D",x"E",x"A",x"5",x"4",x"7",x"D",x"0",x"D",x"4",x"1",x"8",x"9",x"7",x"A",x"0",x"3",x"1",x"9",x"9",x"F",x"2",x"8",x"A",x"9",x"6",x"7",x"A",x"C",
x"5",x"1",x"7",x"2",x"8",x"E",x"3",x"B",x"3",x"8",x"3",x"2",x"5",x"B",x"4",x"F",x"B",x"E",x"C",x"F",x"1",x"B",x"8",x"5",x"A",x"7",x"E",x"E",x"9",x"B",x"0",x"4",x"1",x"8",x"2",
-- IDcell 30   Segment 2
x"7",x"8",x"4",x"D",x"A",x"3",x"B",x"1",x"6",x"B",x"8",x"1",x"0",x"F",x"E",x"3",x"B",x"8",x"5",x"1",x"0",x"6",x"0",x"A",x"D",x"7",x"B",x"D",x"2",x"7",x"D",x"9",x"D",x"9",x"4",x"5",
x"7",x"F",x"6",x"C",x"8",x"8",x"9",x"9",x"A",x"1",x"3",x"D",x"3",x"1",x"1",x"E",x"5",x"3",x"1",x"B",x"8",x"5",x"5",x"C",x"1",x"5",x"E",x"C",x"E",x"6",x"D",x"3",x"A",x"2",x"F",
-- IDcell 31   Segment 2
x"D",x"7",x"D",x"F",x"B",x"C",x"6",x"5",x"7",x"9",x"7",x"6",x"3",x"3",x"A",x"8",x"C",x"1",x"3",x"D",x"3",x"E",x"E",x"C",x"7",x"8",x"1",x"D",x"4",x"8",x"9",x"5",x"2",x"3",x"3",x"8",
x"1",x"3",x"6",x"0",x"6",x"3",x"B",x"5",x"7",x"9",x"D",x"6",x"9",x"4",x"3",x"7",x"B",x"2",x"8",x"B",x"7",x"4",x"4",x"B",x"5",x"A",x"4",x"B",x"E",x"1",x"8",x"A",x"F",x"A",x"9",
-- IDcell 0   Segment 0
x"6",x"1",x"A",x"F",x"2",x"6",x"B",x"D",x"3",x"9",x"A",x"9",x"F",x"F",x"F",x"5",x"2",x"8",x"2",x"6",x"6",x"2",x"5",x"E",x"0",x"4",x"A",x"D",x"A",x"2",x"9",x"9",x"3",x"8",x"5",x"A",
x"3",x"7",x"3",x"F",x"A",x"9",x"4",x"6",x"D",x"8",x"3",x"7",x"D",x"7",x"5",x"4",x"E",x"6",x"C",x"F",x"E",x"B",x"B",x"2",x"6",x"F",x"5",x"C",x"0",x"3",x"B",x"8",x"7",x"C",x"F",
-- IDcell 1   Segment 1
x"D",x"7",x"7",x"D",x"9",x"7",x"C",x"D",x"B",x"9",x"3",x"D",x"B",x"E",x"A",x"A",x"6",x"5",x"C",x"A",x"F",x"A",x"1",x"4",x"6",x"F",x"4",x"0",x"D",x"7",x"2",x"B",x"5",x"E",x"8",x"0",
x"9",x"4",x"4",x"F",x"7",x"5",x"0",x"E",x"0",x"7",x"3",x"2",x"5",x"D",x"C",x"1",x"6",x"4",x"E",x"D",x"6",x"0",x"F",x"3",x"2",x"4",x"3",x"4",x"B",x"C",x"7",x"1",x"8",x"7",x"D",
-- IDcell 2   Segment 2
x"4",x"5",x"2",x"9",x"D",x"9",x"C",x"A",x"6",x"5",x"A",x"F",x"4",x"9",x"C",x"1",x"C",x"3",x"9",x"B",x"D",x"C",x"1",x"8",x"C",x"F",x"A",x"B",x"8",x"7",x"E",x"0",x"3",x"F",x"E",x"4",
x"D",x"A",x"F",x"C",x"0",x"A",x"4",x"8",x"F",x"F",x"1",x"4",x"5",x"7",x"D",x"4",x"6",x"B",x"0",x"D",x"F",x"6",x"6",x"B",x"4",x"1",x"4",x"A",x"2",x"3",x"A",x"C",x"D",x"D",x"B",
-- IDcell 3   Segment 0
x"3",x"3",x"A",x"C",x"0",x"2",x"6",x"1",x"D",x"A",x"A",x"5",x"7",x"C",x"1",x"D",x"6",x"1",x"1",x"E",x"B",x"A",x"1",x"C",x"7",x"3",x"0",x"D",x"5",x"0",x"A",x"F",x"E",x"E",x"5",x"B",
x"E",x"3",x"E",x"8",x"4",x"9",x"0",x"3",x"0",x"A",x"4",x"E",x"8",x"9",x"1",x"B",x"C",x"8",x"C",x"5",x"F",x"4",x"C",x"7",x"8",x"D",x"C",x"D",x"D",x"F",x"E",x"A",x"2",x"6",x"3",
-- IDcell 4   Segment 1
x"B",x"E",x"D",x"4",x"8",x"C",x"7",x"0",x"4",x"F",x"0",x"2",x"A",x"8",x"4",x"F",x"0",x"3",x"B",x"C",x"D",x"2",x"9",x"9",x"D",x"9",x"1",x"9",x"D",x"A",x"5",x"6",x"F",x"7",x"B",x"7",
x"1",x"E",x"D",x"F",x"8",x"A",x"0",x"F",x"8",x"A",x"2",x"5",x"E",x"8",x"F",x"8",x"4",x"9",x"6",x"F",x"9",x"5",x"A",x"4",x"4",x"C",x"E",x"2",x"B",x"9",x"F",x"7",x"4",x"C",x"9",
-- IDcell 5   Segment 2
x"0",x"E",x"C",x"C",x"B",x"E",x"0",x"9",x"0",x"2",x"E",x"B",x"F",x"4",x"B",x"4",x"C",x"2",x"9",x"5",x"0",x"6",x"0",x"1",x"4",x"A",x"3",x"7",x"0",x"6",x"6",x"2",x"2",x"7",x"8",x"4",
x"B",x"7",x"B",x"2",x"D",x"5",x"1",x"5",x"3",x"E",x"1",x"0",x"A",x"D",x"3",x"1",x"1",x"2",x"D",x"C",x"5",x"E",x"4",x"5",x"2",x"7",x"7",x"A",x"3",x"2",x"E",x"7",x"9",x"D",x"E",
-- IDcell 6   Segment 0
x"7",x"C",x"B",x"4",x"9",x"3",x"7",x"8",x"8",x"9",x"C",x"7",x"D",x"F",x"D",x"9",x"A",x"A",x"2",x"D",x"3",x"7",x"2",x"3",x"5",x"E",x"0",x"6",x"F",x"9",x"9",x"3",x"D",x"3",x"D",x"4",
x"F",x"5",x"D",x"5",x"1",x"5",x"B",x"3",x"9",x"C",x"A",x"6",x"5",x"2",x"F",x"6",x"2",x"3",x"9",x"7",x"C",x"0",x"8",x"4",x"5",x"7",x"D",x"6",x"6",x"B",x"C",x"5",x"A",x"3",x"6",
-- IDcell 7   Segment 1
x"4",x"3",x"F",x"2",x"3",x"F",x"6",x"C",x"A",x"C",x"6",x"C",x"4",x"3",x"8",x"9",x"6",x"B",x"3",x"E",x"D",x"B",x"F",x"0",x"0",x"E",x"1",x"C",x"B",x"D",x"4",x"2",x"E",x"2",x"C",x"C",
x"7",x"5",x"E",x"2",x"A",x"9",x"9",x"6",x"4",x"4",x"8",x"F",x"0",x"F",x"C",x"F",x"1",x"7",x"F",x"6",x"7",x"7",x"9",x"D",x"D",x"6",x"E",x"3",x"5",x"6",x"F",x"E",x"D",x"1",x"1",
-- IDcell 8   Segment 2
x"7",x"2",x"C",x"8",x"A",x"2",x"0",x"9",x"F",x"B",x"C",x"4",x"A",x"5",x"6",x"8",x"B",x"E",x"F",x"0",x"3",x"B",x"C",x"F",x"E",x"1",x"B",x"0",x"D",x"9",x"5",x"9",x"F",x"9",x"7",x"7",
x"B",x"0",x"9",x"6",x"3",x"7",x"8",x"0",x"B",x"4",x"E",x"5",x"4",x"E",x"2",x"B",x"9",x"A",x"1",x"0",x"1",x"6",x"3",x"4",x"4",x"A",x"C",x"B",x"7",x"E",x"E",x"3",x"E",x"3",x"A",
-- IDcell 9   Segment 0
x"7",x"7",x"A",x"E",x"B",x"9",x"E",x"5",x"0",x"D",x"C",x"3",x"7",x"2",x"7",x"8",x"4",x"9",x"A",x"9",x"4",x"F",x"B",x"F",x"F",x"C",x"D",x"B",x"5",x"B",x"9",x"5",x"8",x"9",x"A",x"F",
x"5",x"0",x"A",x"B",x"D",x"8",x"A",x"5",x"8",x"8",x"0",x"8",x"B",x"9",x"6",x"6",x"3",x"0",x"5",x"8",x"E",x"1",x"7",x"A",x"2",x"E",x"B",x"C",x"4",x"9",x"6",x"D",x"F",x"4",x"3",
-- IDcell 10   Segment 1
x"6",x"6",x"7",x"1",x"2",x"3",x"C",x"8",x"9",x"0",x"7",x"7",x"F",x"E",x"4",x"A",x"A",x"A",x"E",x"F",x"1",x"5",x"C",x"6",x"3",x"5",x"E",x"9",x"7",x"6",x"C",x"6",x"8",x"1",x"1",x"6",
x"8",x"2",x"D",x"4",x"7",x"8",x"F",x"F",x"C",x"7",x"B",x"7",x"2",x"1",x"A",x"7",x"6",x"B",x"5",x"A",x"3",x"8",x"6",x"9",x"7",x"D",x"F",x"4",x"F",x"B",x"7",x"D",x"2",x"C",x"E",
-- IDcell 11   Segment 2
x"C",x"B",x"D",x"6",x"C",x"5",x"C",x"9",x"B",x"E",x"5",x"5",x"B",x"0",x"B",x"E",x"7",x"6",x"A",x"D",x"0",x"3",x"3",x"9",x"2",x"E",x"8",x"A",x"8",x"A",x"B",x"9",x"A",x"8",x"6",x"0",
x"6",x"3",x"D",x"B",x"3",x"1",x"B",x"7",x"9",x"2",x"8",x"0",x"B",x"4",x"4",x"7",x"9",x"8",x"0",x"B",x"B",x"8",x"4",x"1",x"F",x"D",x"7",x"E",x"9",x"D",x"C",x"6",x"B",x"9",x"B",
-- IDcell 12   Segment 0
x"C",x"7",x"D",x"7",x"D",x"E",x"F",x"8",x"B",x"3",x"C",x"9",x"C",x"8",x"6",x"6",x"7",x"D",x"8",x"D",x"6",x"5",x"0",x"6",x"3",x"B",x"4",x"D",x"A",x"D",x"1",x"F",x"F",x"6",x"9",x"4",
x"4",x"5",x"C",x"8",x"7",x"C",x"A",x"7",x"1",x"D",x"A",x"9",x"5",x"5",x"D",x"0",x"C",x"A",x"2",x"3",x"9",x"7",x"0",x"E",x"9",x"8",x"8",x"A",x"6",x"E",x"A",x"4",x"C",x"8",x"3",
-- IDcell 13   Segment 1
x"F",x"B",x"2",x"4",x"6",x"A",x"B",x"D",x"9",x"2",x"F",x"9",x"E",x"5",x"6",x"0",x"C",x"B",x"2",x"B",x"E",x"C",x"2",x"3",x"1",x"7",x"2",x"0",x"4",x"C",x"9",x"C",x"E",x"2",x"2",x"A",
x"D",x"3",x"B",x"D",x"1",x"9",x"E",x"A",x"0",x"2",x"E",x"9",x"0",x"F",x"5",x"F",x"3",x"B",x"7",x"F",x"4",x"F",x"6",x"5",x"5",x"3",x"8",x"D",x"8",x"E",x"D",x"0",x"9",x"8",x"E",
-- IDcell 14   Segment 2
x"2",x"9",x"E",x"7",x"4",x"5",x"7",x"9",x"4",x"7",x"2",x"F",x"D",x"D",x"8",x"F",x"F",x"C",x"2",x"7",x"0",x"0",x"B",x"2",x"B",x"F",x"3",x"3",x"C",x"6",x"4",x"9",x"9",x"8",x"9",x"D",
x"D",x"8",x"1",x"5",x"3",x"0",x"9",x"3",x"A",x"7",x"C",x"A",x"0",x"8",x"B",x"5",x"0",x"F",x"7",x"A",x"5",x"E",x"4",x"B",x"A",x"E",x"D",x"1",x"0",x"8",x"A",x"0",x"F",x"0",x"D",
-- IDcell 15   Segment 0
x"A",x"2",x"7",x"F",x"2",x"9",x"D",x"8",x"D",x"6",x"C",x"C",x"D",x"7",x"E",x"B",x"4",x"B",x"B",x"E",x"3",x"0",x"3",x"C",x"3",x"E",x"9",x"E",x"9",x"5",x"8",x"0",x"2",x"D",x"B",x"9",
x"8",x"B",x"F",x"D",x"5",x"B",x"8",x"E",x"D",x"0",x"3",x"B",x"8",x"8",x"3",x"0",x"4",x"3",x"5",x"9",x"D",x"9",x"2",x"E",x"3",x"E",x"C",x"1",x"0",x"8",x"C",x"A",x"3",x"C",x"8",
-- IDcell 16   Segment 1
x"3",x"F",x"E",x"7",x"0",x"E",x"2",x"6",x"F",x"A",x"0",x"0",x"3",x"2",x"7",x"F",x"E",x"3",x"B",x"2",x"B",x"E",x"6",x"B",x"C",x"5",x"D",x"5",x"0",x"1",x"4",x"F",x"5",x"8",x"8",x"F",
x"0",x"9",x"C",x"1",x"7",x"D",x"2",x"2",x"2",x"C",x"1",x"4",x"6",x"D",x"D",x"6",x"8",x"B",x"4",x"8",x"2",x"4",x"6",x"9",x"2",x"A",x"6",x"5",x"1",x"8",x"8",x"8",x"C",x"7",x"6",
-- IDcell 17   Segment 2
x"4",x"1",x"E",x"9",x"1",x"3",x"0",x"7",x"E",x"C",x"5",x"8",x"8",x"0",x"1",x"C",x"F",x"F",x"2",x"C",x"7",x"E",x"9",x"C",x"F",x"E",x"F",x"B",x"E",x"B",x"7",x"1",x"6",x"8",x"1",x"F",
x"A",x"E",x"2",x"B",x"E",x"A",x"E",x"C",x"7",x"2",x"D",x"4",x"E",x"4",x"5",x"5",x"6",x"E",x"9",x"9",x"3",x"4",x"5",x"D",x"3",x"B",x"A",x"4",x"B",x"3",x"6",x"9",x"B",x"5",x"9");

end params;


package body params is

 
end params;
