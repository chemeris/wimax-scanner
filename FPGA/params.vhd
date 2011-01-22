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

end params;


package body params is

 
end params;
