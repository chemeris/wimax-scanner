# Project goal #

We aim at creating an open-source WiMAX scanner/receiver. It should be able to capture mobile WiMAX aka 802.16e data from the air and decode it into bursts of bits. In other words, we aim at implementing a PHY level of mobile WiMAX receiver. When we reach this goal, we plan to continue with implementing a PHY level of mobile WiMAX transmitter to have a fully open-source mobile WiMAX modem.

# Hardware #

_To make it clear: As far as we're implementing PHY level, we use [Software Defined Radio](http://en.wikipedia.org/wiki/Software-defined_radio) approach and do not rely on any existing WiMAX chips._

As a first step we plan to use USRP N200/[N210](http://www.ettus.com/downloads/ettus_ds_usrp_n200series_v3.pdf) to capture WiMAX signal and then process it on usual x86 in offline- mode. Then we plan to move to make processing real-time by using a capable DSP, like [TI TMS320C66x](http://focus.ti.com/dsp/docs/dspcontent.tsp?contentId=77428&DCMP=nysh_101109&HQS=Other+BA+c66x_ticom_feature) (using appropriate [Evaluation Module](http://focus.ti.com/docs/toolsw/folders/print/tmdxevm6670.html)).

Our initial plan was to use [USRP E100](http://www.ettus.com/downloads/USRP_E100_Series_temporary_datasheet.pdf), because it features pretty decent Xilinx Spartan 3A-DSP1800 FPGA and we should be able to do most (if not all) of DSP heavy lifting in it. In this case FPGA produces bursts of bits which are then handled by OMAP3 MCU for MAC level processing. But this way gave us not enough flexibility to experiment and was too slow to implement. Yet, we started writing VHDL code and everyone is welcome to continue this. Code is released under LGPL license, as stated below.

# Software #

  * **Initial modeling**. We use Matlab - you could find this code under [matlab](http://code.google.com/p/wimax-scanner/source/browse/?name=ostapenko-work#hg%2Fmatlab) directory in ostapenko-work branch. We welcome everyone to volunteer to port this code to Octave or SciPy, etc.
  * **DSP processing**. As a first step we will perform DSP processing in offline mode on Linux/x86, but this code hasn't been started yet. We tried to implement DSP processing with VHDL and this code could be found under [FPGA](http://code.google.com/p/wimax-scanner/source/browse/#hg%2FFPGA) directory in the repository.
  * **MAC level processing**. The code which will process bit bursts will be written in C/C++ and will work on x86 and ARM. This part is in to-be-done state.

We have a [ToDo page](TODO.md), but it's usually a bit outdated. If you want to contribute - ask developers what is already done and what is not.

# Participation #

WiMAX is one of the most complex wireless standards and we invite all skilled hackers/engineers/programmers to participate to create its fully open-source implementation.

We run [a mailing list for developers](http://lists.fairwaves.ru/listinfo/wimax) and a separate [mailing list for Russian developers](http://lists.fairwaves.ru/listinfo/wimax-ru). If you're interested in participation you're welcome to subscribe to them.

All commits are posted to a special [wimax-scanner-commits mailing list](http://lists.fairwaves.ru/listinfo/wimax-scanner-commits).

This project is **far from being ready for end-user!** If you just want to get WiMAX working in your device, you should look at some other place.

# Licensing #

All software in the repository is licensed under LGPLv2 license. Basically it means that all changes to the code itself should be published, but you can link the code to a proprietary application.