/*******************************************************************************
*     This file is owned and controlled by Xilinx and must be used             *
*     solely for design, simulation, implementation and creation of            *
*     design files limited to Xilinx devices or technologies. Use              *
*     with non-Xilinx devices or technologies is expressly prohibited          *
*     and immediately terminates your license.                                 *
*                                                                              *
*     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"            *
*     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                  *
*     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION          *
*     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION              *
*     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS                *
*     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                  *
*     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE         *
*     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY                 *
*     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                  *
*     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR           *
*     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF          *
*     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS          *
*     FOR A PARTICULAR PURPOSE.                                                *
*                                                                              *
*     Xilinx products are not intended for use in life support                 *
*     appliances, devices, or systems. Use in such applications are            *
*     expressly prohibited.                                                    *
*                                                                              *
*     (c) Copyright 1995-2009 Xilinx, Inc.                                     *
*     All rights reserved.                                                     *
*******************************************************************************/
// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
ifft YourInstanceName (
	.clk(clk),
	.ce(ce),
	.start(start),
	.xn_re(xn_re), // Bus [15 : 0] 
	.xn_im(xn_im), // Bus [15 : 0] 
	.fwd_inv(fwd_inv),
	.fwd_inv_we(fwd_inv_we),
	.scale_sch(scale_sch), // Bus [9 : 0] 
	.scale_sch_we(scale_sch_we),
	.rfd(rfd),
	.xn_index(xn_index), // Bus [9 : 0] 
	.busy(busy),
	.edone(edone),
	.done(done),
	.dv(dv),
	.xk_index(xk_index), // Bus [9 : 0] 
	.xk_re(xk_re), // Bus [15 : 0] 
	.xk_im(xk_im)); // Bus [15 : 0] 

// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file ifft.v when simulating
// the core, ifft. When compiling the wrapper file, be sure to
// reference the XilinxCoreLib Verilog simulation library. For detailed
// instructions, please refer to the "CORE Generator Help".

