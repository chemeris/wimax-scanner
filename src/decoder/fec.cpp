/****************************************************************************/
/*! \file		fec.c
	\brief		FEC decoder
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	FEC decoder of convolutional code, convolutional turbo code, LDPC code etc.
	implements IEEE Std 802.16-2009, 8.4.9.2 Encoding

	TODO:
	1. BTC, ZTCC, LPDC codes are not yet implemented

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


#include "fec.h"

#include "convolutional.h"




/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/

const int		Fec::aCcGenPol[] = { 0171, 0133 }; // in octal



/******************************************************************************
External functions
******************************************************************************/


Fec::Fec(	FecType		fec,
			FecRate		rate,
			ModulType	modul,
			int			slotSz,
			int			numSlot		)
{
	this->fec = fec;
	this->rate = rate;
	this->modul = modul;
	this->slotSz = slotSz;
	this->sbitSz = (int)((float)slotSz / fecrate2val( rate ));

	slotCntr = 0;
	blockCntr = 0;
	initConcat( numSlot );

	switch( fec ) {
		case FEC_CC:
			initCc( ARRAY_SZ( aCcGenPol ), aCcGenPol );
			memset(cc.prev_state, 0, sizeof(cc.prev_state)); //@@@
			break;
		case FEC_CTC:
			initCtcIntlv();
			initCtc();
			break;
		default:
			ASSERT( 0 ); // not yet implemented
			break;
	}

}

Fec::~Fec()
{
	switch( fec ) {
		case FEC_CC:
			deleteCc();
			break;
		case FEC_CTC:
			deleteCtc();
			break;
		default:
			ASSERT( 0 ); // not yet implemented
			break;
	}
}



int			Fec::decod(		uint8 *			pBit,
							const float *	pSbit		)
{
	for( int i = 0; i < sbitSz; i++ )
		aSbit[slotCntr*sbitSz+i] = - *pSbit++; // softbit is inverted LLR 
	slotCntr++;

	ASSERT( blockCntr < numBlock );
	int		numSlot = normNumSlot; // number of slot in current concatenated block
	if( ! isEqBlock ) {
		if( blockCntr == numBlock-1 )
			numSlot = lastNumSlot;
		if( blockCntr == numBlock-2 )
			numSlot = beflNumSlot;
	}
	if( slotCntr < numSlot )
		return 0;

	slotCntr = 0;
	blockCntr++;

	//Debug::print( "In", aSbit, numSlot*96 );

	switch ( fec ) {
		case FEC_CC:
			decCc(  pBit, aSbit, numSlot );
			break;
		case FEC_CTC:
			intlvCtc( aSbit, numSlot );
			//Debug::print( "Deintlv", aSbit, numSlot*96 );
			decCtc( pBit, aSbit, numSlot );
			break;
		default:
			break;
	}
	return numSlot*slotSz;
}




/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/

const int		Fec::aaCcConcSz[MODUL_NUM][FEC_RATE_NUM] = {
	{		6,	 FAIL,		4,	 FAIL	},		// QPSK		1/2 2/3 3/4 5/6
	{		3,	 FAIL,		2,	 FAIL	},		// 16-QAM	1/2 2/3 3/4 5/6
	{		2,		1,		1,	 FAIL	}		// 64-QAM	1/2 2/3 3/4 5/6
};

const int		Fec::aaCtcConcSz[MODUL_NUM][FEC_RATE_NUM] = {
	{	   10,	 FAIL,		6,	 FAIL	},		// QPSK		1/2 2/3 3/4 5/6
	{		5,	 FAIL,		3,	 FAIL	},		// 16-QAM	1/2 2/3 3/4 5/6
	{		3,		2,		2,		2	}		// 64-QAM	1/2 2/3 3/4 5/6
};

const Fec::CtcSblkIntlvParam	Fec::aCtcSblkIntlvParamTbl[maxConcSz] = {
	{	3,	3	},		//  48	
	{	4,	3	},		//  96
	{	5,	3	},		// 144
	{	5,	3	},		// 192
	{	6,	2	},		// 240
	{	6,	3	},		// 288
	{ FAIL,FAIL,},		// forbidden number of concatenation slots
	{	6,	3	},		// 384
	{	6,	4	},		// 432
	{	7,	2	}		// 480
};

const Fec::CtcIntIntlvParam	Fec::aCtcIntIntlvParamTbl[] = {
	{ MODUL_QPSK,  FEC_1_2,   1, {   5,   0,   0,   0 } },
	{ MODUL_QPSK,  FEC_1_2,   2, {  13,  24,   0,  24 } },
	{ MODUL_QPSK,  FEC_1_2,   3, {  11,   6,   0,   6 } },
	{ MODUL_QPSK,  FEC_1_2,   4, {   7,  48,  24,  72 } },
	{ MODUL_QPSK,  FEC_1_2,   5, {  13,  60,   0,  60 } },
	{ MODUL_QPSK,  FEC_1_2,   6, {  17,  74,  72,   2 } },
	{ MODUL_QPSK,  FEC_1_2,   7, {FAIL,FAIL,FAIL,FAIL } },
	{ MODUL_QPSK,  FEC_1_2,   8, {  11,  96,  48, 144 } },
	{ MODUL_QPSK,  FEC_1_2,   9, {  13, 108,   0, 108 } },
	{ MODUL_QPSK,  FEC_1_2,  10, {  13, 120,  60, 180 } },
	{ MODUL_QPSK,  FEC_3_4,   1, {  11,  18,   0,  18 } },
	{ MODUL_QPSK,  FEC_3_4,   2, {  11,   6,   0,   6 } },
	{ MODUL_QPSK,  FEC_3_4,   3, {  11,  54,  56,   2 } },
	{ MODUL_QPSK,  FEC_3_4,   4, {  17,  74,  72,   2 } },
	{ MODUL_QPSK,  FEC_3_4,   5, {  11,  90,   0,  90 } },
	{ MODUL_QPSK,  FEC_3_4,   6, {  13, 108,   0, 108 } },
	{ MODUL_16QAM, FEC_1_2,   1, {  13,  24,   0,  24 } },
	{ MODUL_16QAM, FEC_1_2,   2, {   7,  48,  24,  72 } },
	{ MODUL_16QAM, FEC_1_2,   3, {  17,  74,  72,   2 } },
	{ MODUL_16QAM, FEC_1_2,   4, {  11,  96,  48, 144 } },
	{ MODUL_16QAM, FEC_1_2,   5, {  13, 120,  60, 180 } },
	{ MODUL_16QAM, FEC_3_4,   1, {  11,   6,   0,   6 } },
	{ MODUL_16QAM, FEC_3_4,   2, {  17,  74,  72,   2 } },
	{ MODUL_16QAM, FEC_3_4,   3, {  13, 108,   0, 108 } },
	{ MODUL_64QAM, FEC_1_2,   1, {  11,   6,   0,   6 } },
	{ MODUL_64QAM, FEC_1_2,   2, {  17,  74,  72,   2 } },
	{ MODUL_64QAM, FEC_1_2,   3, {  13, 108,   0, 108 } },
	{ MODUL_64QAM, FEC_2_3,   1, {   7,  48,  24,  72 } },
	{ MODUL_64QAM, FEC_2_3,   2, {  11,  96,  48, 144 } },
	{ MODUL_64QAM, FEC_3_4,   1, {  11,  54,  56,   2 } },
	{ MODUL_64QAM, FEC_3_4,   2, {  13, 108,   0, 108 } },
	{ MODUL_64QAM, FEC_5_6,   1, {  13,  60,   0,  60 } },
	{ MODUL_64QAM, FEC_5_6,   2, {  13, 120,  60, 180 } }
};


/*****************************************************************************
Internal variables
*****************************************************************************/




/******************************************************************************
Internal functions
******************************************************************************/
	

void	Fec::initConcat(	int			numSlot		)
{
	int concatSz;
	switch( fec ) {
		case FEC_CC:		concatSz = aaCcConcSz[modul][rate];		break;
		case FEC_CTC:		concatSz = aaCtcConcSz[modul][rate];	break;
		default:			ASSERT( 0 );							break;
	}
	ASSERT( concatSz != FAIL );

	if( numSlot <= concatSz ) {
		isEqBlock = true;
		numBlock = 1;
		normNumSlot = numSlot;
	} else if( ( numSlot % concatSz ) == 0 ) {
		isEqBlock = true;
		numBlock = numSlot / concatSz;
		normNumSlot = concatSz;
	} else {
		isEqBlock = false;
		numBlock = numSlot / concatSz + 1;
		normNumSlot = concatSz;
		beflNumSlot = ( ( numSlot % concatSz ) + concatSz + 1 ) / 2;
		lastNumSlot = ( ( numSlot % concatSz ) + concatSz     ) / 2;
	}
	if( fec == FEC_CTC ) {
		if( isEqBlock ) {
			if( normNumSlot == ctcForbidNum ) {
				isEqBlock = false;
				numBlock = 2;
				beflNumSlot = ( normNumSlot + 1 ) / 2;
				lastNumSlot = ( normNumSlot     ) / 2;
			}
		} else {
			if( ( beflNumSlot == ctcForbidNum ) || 
				( lastNumSlot == ctcForbidNum )    ) {
				beflNumSlot++;
				lastNumSlot--;
			}
		}
	}

}



void	Fec::initCc(		int				numGen,
							const int *		pGenPol		)
{
	ASSERT( ccNumGen == numGen );
	for( int i = 0; i < numGen; i++ )
		ASSERT( ccMemLen >= ( 31 - _norm( pGenPol[i] ) ) );

	nsc_transit( cc.aOut0, cc.aState0, 0, pGenPol, ccMemLen, ccNumGen );
	nsc_transit( cc.aOut1, cc.aState1, 1, pGenPol, ccMemLen, ccNumGen );
}

void	Fec::decCc(			uint8 *			pBit,
							const float *	pSbit,
							int				numSlot	)
{
	ViterbiTb( pBit, 
		cc.aOut0,			cc.aState0, 
		cc.aOut1,			cc.aState1,
		pSbit,		ccMemLen,		ccNumGen, 
		numSlot*slotSz,		slotSz/2, 
		cc.prev_section,	cc.next_section,
		cc.prev_bit,		cc.prev_state,
		cc.rec_array,		cc.metric_c
		);
}

void	Fec::deleteCc()
{
}


void	Fec::initCtc()
{
	ctc.pIntIntlvParam = NULL;
	for( int i = 0; i < ARRAY_SZ(aCtcIntIntlvParamTbl); i++ )
		if( ( aCtcIntIntlvParamTbl[i].modul == modul ) &&
			( aCtcIntIntlvParamTbl[i].rate  == rate  )    ) {
			ctc.pIntIntlvParam = &aCtcIntIntlvParamTbl[i];
			break;
		}
	ASSERT( ctc.pIntIntlvParam );
	ctc.pTurbo = new Turbo();
}

void	Fec::initCtcIntlv()
{
	// fill subblock interleaver table 8.4.9.2.3.4.2 Subblock interleaving
	int		concSz, m, J, i, k, Tk, N;
	for( concSz = 1; concSz <= maxConcSz; concSz++ ) {
		if( concSz == ctcForbidNum )
			continue;
		N = concSz*symPerSlot/2;
		m = aCtcSblkIntlvParamTbl[concSz-1].m;
		J = aCtcSblkIntlvParamTbl[concSz-1].J;
		ASSERT( m != FAIL );
		for( i = 0, k = 0; i < N; k++ ) {
			Tk = (0x01<<m)*(k%J) + bitRev( k/J, m ); // Tk = 2^m*(k mod J) + BROm(k / J)
			if( Tk < N )
				ctc.aaSblockIntlv[concSz-1][i++] = Tk;
		}
	}		
}

void	Fec::decCtc(		uint8 *			pBit,
							const float *	pSbit,
							int				numSlot	)
{
	ctc.pTurbo->decod( pBit, pSbit, slotSz*numSlot/2, ctc.pIntIntlvParam[numSlot-1].aP );
}

void	Fec::intlvCtc(		float *			pSbit,
							int				numSlot	)
{
	int			i, j, sblockSz;
	float *		pT, * pS;
	float		aT[maxBlockSz];

	// fill punctured LLRs with zeros
	pS = pSbit + sbitSz*numSlot;
	for( i = 0; i < ((slotSz*3-sbitSz)*numSlot); i++ )
		*pS++ = 0.f;

	// Reverse 8.4.9.2.3.4.3 Bit grouping
	sblockSz = slotSz*numSlot/2;
	memcpy( aT, pSbit, sblockSz*2*sizeof(*pSbit) ); // copy A B
	pS = &pSbit[sblockSz*2];
	pT = &aT[sblockSz*2];
	for( j = 0; j < 2; j++ ) {
		for( i = 0; i < sblockSz; i++ ) {
			pT[0] = *pS++;
			pT[sblockSz] = *pS++;
			pT++;
		}
		pT += sblockSz;
	}

	// Reverse 8.4.9.2.3.4.2 Subblock interleaving
	pS = pSbit;
	pT = aT;
	for( j = 0; j < ctcNumSblock; j++ ) {
		for( i = 0; i < sblockSz; i++ )
			pS[ ctc.aaSblockIntlv[numSlot-1][i] ] = *pT++;
		pS += sblockSz;
	}

}

void	Fec::deleteCtc()
{
	delete ctc.pTurbo;
}
