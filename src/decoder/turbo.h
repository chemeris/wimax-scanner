/****************************************************************************/
/*! \file		turbo.h
	\brief		Convolutional turbo decoder
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Convolutional turbo decoder for 
	Duobinary Circular RSC code
	implements IEEE Std 802.16-2009, 8.4.9.2.3.1 CTC encoder

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

#ifndef _TURBO_H_
#define _TURBO_H_

#include "comdefs.h"
#include "global.h"
#include "baseop.h"

class Turbo {


public:



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/


/******************************************************************************
External functions
******************************************************************************/


	Turbo();

	~Turbo();

	//! Decode duobinary CRSC turbo code
	void		decod(		uint8 *			pBit,		//!< output bits, length compSz*2
							const float *	pSbit,		//!< input softbits in A B Y1 Y2 W1 W2 sequence, length compSz*6
							int				sz,			//!< component (A, B etc) size
							const int		aP[4]		);	//!< inter-component interleaver params

private:


/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/

	static const int		regLen = 3;				//!< generator register length
	static const int		numSt = (0x01<<regLen);	//!< number of states
	static const int		numBr = 4;				//!< number of input branches

	static const int		numIter = 4; // 10		//!< number of iteration
	static const int		tailSz = 10; // 18		//!< tail size

	static const int		maxSz = maxConcSz*symPerSlot;	//!< max component size
	static const int		maxFsz = maxSz+tailSz*2;	//!< max full size 

	static const float		extrScale;				//!< extrinsic scale 


	enum CompNum {
		COMP_A,				//!< component A
		COMP_B,				//!< component B
		COMP_Y,				//!< component Y 
		COMP_W,				//!< component W
		COMP_Y1 = COMP_Y, 	//!< component Y1
		COMP_Y2, 			//!< component Y2
		COMP_W1,			//!< component W1
		COMP_W2,			//!< component W2
		COMP_AB_NUM = COMP_B+1,
		COMP_NUM = COMP_W+1
	};

	static const int		aGenPol[];			//!< feedback, A and B feedforward, Y and W generator polynomials in octal

	// State Item
	struct Stat {
		int			cur;				//!< current state
		int			prev;				//!< previous state
		float		aAbyw[COMP_NUM];	//!< A B Y W values
	};



/*****************************************************************************
Internal variables
*****************************************************************************/

	Stat			aaFrw[numSt][numBr];	//!< forward transitions
	Stat			aaBkw[numSt][numBr];	//!< backward transitions
	int				aIntlvTbl[maxSz];		//!< interleaver table

/******************************************************************************
Internal functions
******************************************************************************/
	
	//!	Duobinary Circular RSC encoder, return Y, Figure 289—CTC encoder 
	uint8		encod(		int *		pSt,	//!< input/output encoder state
							uint8		a,		//!< A
							uint8		b,		//!< B
							uint8 *		pW	);	//!< output W

	//! Init transition tables
	void		initTrans();
	
	//! Find backward transitions with specified prev state, return found transition, start find from pFound
	Stat *		findBkwPrev(	int		prev,			//!< prev state to find
								int *	pFound		);	//!< last found position

	
	//! Fill ABYW
	void		fillAbyw(		float 	aaAbyw[COMP_NUM][maxFsz],		//!< output A B Y W softbits, including head and tail 
								float 	aaExtrAb[COMP_AB_NUM][maxSz],	//!< input Extrinsic AB
								const float *	pSbit,					//!< input softbits
								int		sz,								//!< component size
								int		yOffs		);					//!< Y offset: COMP_Y1 or COMP_Y2

	//! Add ABYW head and tail
	void		addAbywTail(	float 	aaAbyw[COMP_NUM][maxFsz],		//!< input/output A B Y W softbits
								int		sz						);		//!< component size

	//! Componenet decoder
	void		compDecod(		float 	aaApostAb[COMP_AB_NUM][maxFsz],	//!< output A-posteriori A B output
								float 	aaAbyw[COMP_NUM][maxFsz],		//!< input A B Y W softbits
								int		fsz						);		//!< full component size incluting head and tail 




	//! Init interleaver tabel for faster intlvAb and deintlvExtr processing, Step 2: P (j ) 8.4.9.2.3.2 CTC interleaver
	void		initIntlvTbl(	int			sz,							//!< component size
								const int	aP[4]		);				//!< interleaver params
	
	//! Interleaver A B, 8.4.9.2.3.2 CTC interleaver
	void		intlvAb(		float 		aaAbyw[COMP_NUM][maxFsz],	//!< input/output A B Y W softbits
								int			sz						);	//!< component size

	//! Deinterleaver extrinsic A B, 8.4.9.2.3.2 CTC interleaver
	void		deintlvExtr(	float		aaApostAb[COMP_AB_NUM][maxSz], //!< input/output A-posteriori A B
								int			sz						);	//!< component size

	//! Get output hard bits from interleaver A-posteriori A B
	void		getHardBit(		uint8 *		pBit,						//!< output bits
						  		float 		aaApostAb[COMP_AB_NUM][maxFsz],	//!< A-posteriori A B output
								int			sz						);	//!< component size



};



#endif //#ifndef _TURBO_H_


