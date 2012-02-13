/****************************************************************************/
/*! \file		fec.h
	\brief		FEC decoder
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	FEC decoder of convolutional code, convolutional turbo code, LDPC code etc.
	implements IEEE Std 802.16-2009, 8.4.9.2 Encoding

*/
/*****************************************************************************/

/*****************************************************************************
	Copyright (C) 2011  Iliya Voronov

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
	USA
*****************************************************************************/

#ifndef _FEC_H_
#define _FEC_H_

#include "comdefs.h"
#include "global.h"
#include "baseop.h"
#include "turbo.h"

class Fec {


public:



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/


/******************************************************************************
External functions
******************************************************************************/


	Fec(	FecType		fec,			//!< FEC type
			FecRate		rate,			//!< FEC rate
			ModulType	modul,			//!< modulation
			int			slotSz,			//!< slot size in data bits
			int			numSlot		);	//!< number of slots

	~Fec();


	//! Decode soft bits, return number of output bits or zero if not output produced
	int			decod(		uint8 *			pBit,			//!< output bits, length slotSz * concatenation size
							const float *	pSbit	);		//!< input softbits, length slotSz / FEC rate


private:


/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/

	static const int	maxBlockSz = maxConcSz*symPerSlot*3;	//!< max block size, including CTC 1/3

	static const int	ccMemLen = 7;		//!< CC memory length including input bit = K
	static const int	ccNumStat = 0x01UL<<(ccMemLen-1);	//!< CC number of state of viterbi decoder = m
	static const int	ccNumGen = 2;		//!< CC number of generator polynomials = output bits per input bit = n

	static const int	ctcForbidNum = 7;	//!< CTC forbidden number of slots in block
	static const int	ctcNumSblock = 6;	//!< CTC number of subblock


	//! Convolutional code internal structure
	struct Cc {
		int		aOut0[ccNumStat];			//!< output symbols for 0 input bit, MSB is 0-th generator polinom
		int		aState0[ccNumStat];			//!< next state for 0 input bit, LSB is odlest bit in register
		int		aOut1[ccNumStat];			//!< output symbols for 1 input bit, MSB is 0-th generator polinom
		int		aState1[ccNumStat];			//!< next state for 1 input bit, LSB is odlest bit in register
		float	prev_section[ccNumStat];
		float	next_section[ccNumStat];
		int		prev_bit[ccNumStat*(maxConcSz*symPerSlot + symPerSlot/2)];
		int		prev_state[ccNumStat*(maxConcSz*symPerSlot + symPerSlot/2)];
		float	rec_array[ccNumGen];
		float	metric_c[1<<ccNumGen];
	};

	//! CTC Subblock interleaver params 
	struct CtcSblkIntlvParam {
		int		m;
		int		J;
	};
	static const CtcSblkIntlvParam	aCtcSblkIntlvParamTbl[maxConcSz];	//!< CTC Subblock interleaver params table Table 505—Parameters for the subblock interleavers

	//! CTC inter-component interleaver
	struct CtcIntIntlvParam {
		ModulType	modul;			//!< modulation
		FecRate		rate;			//!< FEC rate
		int			numSlot;		//!< number of slot
		int			aP[4];			//!< params
	};
	static const CtcIntIntlvParam	aCtcIntIntlvParamTbl[];	//!< CTC inter-component interleaver Table 502—CTC channel coding per modulation 

	//! Convolutional turbo code internal structure
	struct Ctc {
		int			aaSblockIntlv[maxConcSz][maxBlockSz/ctcNumSblock];		//!< subblock interleaver table 8.4.9.2.3.4.2 Subblock interleaving
		const CtcIntIntlvParam *	pIntIntlvParam;		//!< pointer to first CTC inter-component interleaver params of specified rate and modulation
		Turbo *		pTurbo;				//!< CTC decoder
	};


	static const int	aCcGenPol[];		//!< Convolutional code generator polynomials 

	static const int	aaCcConcSz[MODUL_NUM][FEC_RATE_NUM];	//!< CC slot concatination size, Table 493—Encoding slot concatenation for different allocations and modulations
	static const int	aaCtcConcSz[MODUL_NUM][FEC_RATE_NUM];	//!< CTC slot concatination size, Table 501—Encoding slot concatenation for different rates in CTC


/*****************************************************************************
Internal variables
*****************************************************************************/

	FecType				fec;		//!< FEC type
	FecRate				rate;		//!< FEC rate
	ModulType			modul;		//!< modulation
	int					slotSz;		//!< slot size in data bits
	int					sbitSz;		//!< slot size in softbits

	int					slotCntr;	//!< slot counter in block
	int					blockCntr;	//!< block counter in burst

	// concatenation params
	bool				isEqBlock;	//!< all block equal length, otherwise 2 last block is different length
	int					numBlock;	//!< number of blocks in burst
	int					normNumSlot;	//!< normal number of slots in block, equal blocks or not 2 last blocks of nonequal blocks
	int					beflNumSlot;	//!< block before last number of slots in block
	int					lastNumSlot;	//!< last block number of slots in block

	float				aSbit[maxBlockSz];	//!< block of concatenated slots buffer 

	Cc					cc;			//!< convolutional code internal data
	Ctc					ctc;		//!< convolutional turbo code internal data


/******************************************************************************
Internal functions
******************************************************************************/
	
	//! Init concatenation params
	void	initConcat(		int				numSlot		);	//!< number of slots in burst

	//! Init convolutional code
	void	initCc(			int				numGen,			//!< number of generator polynomials = output bits per input bit
							const int *		pGenPol		);	//!< generator polynomials

	//! Decode convolutional code, return number of output bits of zero if not output produced
	void	decCc(			uint8 *			pBit,			//!< output bits
							const float *	pSbit,			//!< input softbits
							int				numSlot		);	//!< number of slot in current concatenation block

	//! Delete convolutional code
	void	deleteCtc();


	//! Init convolutional turbo code
	void	initCtc();

	//! Init post CTC interleaver
	void	initCtcIntlv();

	//! Decode convolutional turbo code, return number of output bits of zero if not output produced
	void	decCtc(			uint8 *			pBit,			//!< output bits
							const float *	pSbit,			//!< input softbits
							int				numSlot		);	//!< number of slot in current concatenation block

	//! Deinterleave convolutional turbo code, return softbits in A B Y1 W1 Y2 W2 sequence
	void	intlvCtc(		float *			pSbit,			//!< input/output softbits
							int				numSlot		);	//!< number of slot in current concatenation block

	//! Delete convolutional turbo code
	void	deleteCc();

};



#endif //#ifndef _FEC_H_


