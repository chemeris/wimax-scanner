----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:49:06 01/12/2011 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
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

fwd_inv_we <= '1';
fwd_inv <= '0';
scale_sch <=  "0110001110";
scale_sch_we <= '1';
start <= '1';

process(clk)
begin
  if rising_edge(clk) then
  end if;
end process;

end Behavioral;

