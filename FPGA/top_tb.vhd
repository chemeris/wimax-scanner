--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:57:45 01/12/2011
-- Design Name:   
-- Module Name:   D:/Work/Xilinx_Project/WiMAX/top_tb.vhd
-- Project Name:  WiMAX
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         clk : IN  std_logic;
         adc_clk : in  std_logic;
			rst: IN std_logic;
         adc_re : IN  std_logic_vector(15 downto 0);
         adc_im : IN  std_logic_vector(15 downto 0);
         data : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
	signal rst : std_logic := '0';
   signal adc_re : std_logic_vector(15 downto 0) := (others => '0');
   signal adc_im : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal adc_clk : std_logic;
   signal data : std_logic_vector(7 downto 0);


signal char_count: std_logic_vector(31 downto 0) := x"00000000";

   -- Clock period definitions
   constant clk_period : time := 18 ns;
   constant adc_clk_period : time := 90 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          clk => clk,
			 rst => rst,
          adc_clk => adc_clk,
          adc_re => adc_re,
          adc_im => adc_im,
          data => data
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   adc_clk_process :process
		
   begin
		adc_clk <= '0';
		wait for adc_clk_period/2;
		adc_clk <= '1';
		wait for adc_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1';
      wait for 100 ns;	

      wait for clk_period*11;
		rst <= '0';
      -- insert stimulus here 

      wait;
   end process;

   read_input: process  
        type char_file is file of character;
        file c_file_handle: char_file;
        variable C: character;
        
   begin
        file_open(c_file_handle, "wimax_2647_11.2Msps_16.dat", READ_MODE);
        while not endfile(c_file_handle) loop
			if NOT (ENDFILE(c_file_handle)) THEN
			  
			   wait until adc_clk = '1';
				if (rst = '0') then
					read (c_file_handle, C) ; adc_re(15 downto 8 ) <= conv_std_logic_vector(character'pos(C),8);
					read (c_file_handle, C) ; adc_re(7 downto 0 ) <= conv_std_logic_vector(character'pos(C),8);
					read (c_file_handle, C) ; adc_im(15 downto 8 ) <= conv_std_logic_vector(character'pos(C),8);
					read (c_file_handle, C) ; adc_im(7 downto 0 ) <= conv_std_logic_vector(character'pos(C),8);
					char_count <= char_count + 1;  -- Keep track of the number of characters
				end if;
			end if;
			wait for 10 ns;
        end loop;
        file_close(c_file_handle);
   end process;

END;
