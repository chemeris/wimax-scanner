/****************************************************************************/
/*! \file		turbo.cpp
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


#include "turbo.h"
#include "vect.h"



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/

const int		Turbo::aGenPol[] = { 015, 010, 016, 013, 011 }; // feedback, A and B feedforward, Y and W generator polynomials in octal



/******************************************************************************
External functions
******************************************************************************/

Turbo::Turbo()
{
	initTrans();
}

Turbo::~Turbo()
{
}


void		Turbo::decod(	uint8 *			pBit,
							const float *	pSbit,
							int				sz,
							const int		aP[4]		)
{
	int			i, fsz;
	float 		aaAbyw[COMP_NUM][maxFsz];		//!< A B Y W softbits, including head and tail 
	float 		aaExtrAb[COMP_AB_NUM][maxSz];	//!< Extrinsic AB
	float 		aaApostAb[COMP_AB_NUM][maxFsz];	//!< A-posteriori AB output, including head and tail

	fsz = sz + tailSz*2;
	memset( aaExtrAb, 0, sizeof(aaExtrAb) );
	initIntlvTbl( sz, aP );

	for( i = 0; i < numIter; i++ ) {
		fillAbyw( aaAbyw, aaExtrAb, pSbit, sz, COMP_Y1 );
		addAbywTail( aaAbyw, sz );
		compDecod( aaApostAb, aaAbyw, fsz );
		vectSub( &aaExtrAb[COMP_A][0], &aaApostAb[COMP_A][tailSz], &aaAbyw[COMP_A][tailSz], sz );
		vectSub( &aaExtrAb[COMP_B][0], &aaApostAb[COMP_B][tailSz], &aaAbyw[COMP_B][tailSz], sz );

		fillAbyw( aaAbyw, aaExtrAb, pSbit, sz, COMP_Y2 );
		intlvAb( aaAbyw, sz );
		addAbywTail( aaAbyw, sz );
		compDecod( aaApostAb, aaAbyw, fsz );
		vectSub( &aaExtrAb[COMP_A][0], &aaApostAb[COMP_A][tailSz], &aaAbyw[COMP_A][tailSz], sz );
		vectSub( &aaExtrAb[COMP_B][0], &aaApostAb[COMP_B][tailSz], &aaAbyw[COMP_B][tailSz], sz );
		deintlvExtr( aaExtrAb, sz );
	}
	getHardBit( pBit, aaApostAb, sz );
//	Debug::print( "Bits", pBit, sz*2 );
}




/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/

const float		Turbo::extrScale = 0.5f;



/*****************************************************************************
Internal variables
*****************************************************************************/




/******************************************************************************
Internal functions
******************************************************************************/

uint8	Turbo::encod(	int *		pSt,
						uint8		a,
						uint8		b,
						uint8 *		pW	)
{
	ASSERT( ( *pSt >= 0 ) && ( *pSt < numSt ) );
	uint8	y;
	int		st = *pSt;
	st ^= genParity( st & aGenPol[0] ) << regLen;
	y   = (uint8)genParity( st & aGenPol[3] ) ^ a ^ b;
	*pW = (uint8)genParity( st & aGenPol[4] ) ^ a ^ b;
	st ^= a * aGenPol[1];
	st ^= b * aGenPol[2];
	*pSt = st>>1;
	return y;
}


void		Turbo::initTrans()
{
	int		i, j, st, found;
	uint8	a, b, y, w;
	Stat *	pSt;
	
	for( i = 0; i < numSt; i++ ) {
		for( j = 0; j < numBr; j++ ) {
			st = i;
			a = j>>1;
			b = j&01;
			aaBkw[i][j].cur = st;
			y = encod( &st, a, b, &w );
			aaBkw[i][j].prev = st;
			aaBkw[i][j].aAbyw[COMP_A] = (float)a*2.f-1.f;
			aaBkw[i][j].aAbyw[COMP_B] = (float)b*2.f-1.f;
			aaBkw[i][j].aAbyw[COMP_Y] = (float)y*2.f-1.f;
			aaBkw[i][j].aAbyw[COMP_W] = (float)w*2.f-1.f;
		}
	}

	for( i = 0; i < numSt; i++ ) {
		found = -1; // restart findBkwPrev
		for( j = 0; j < numBr; j++ ) {
			st = i;
			pSt = findBkwPrev( st, &found );
			aaFrw[i][j].cur = st;
			aaFrw[i][j].prev = pSt->cur;
			memcpy( aaFrw[i][j].aAbyw, pSt->aAbyw, sizeof(pSt->aAbyw) );
		}
	}
}

Turbo::Stat *	Turbo::findBkwPrev(		int		prev,
										int *	pFound	)
{
	for( int i = *pFound+1; i < numSt*numBr; i++ )
		if( aaBkw[0][i].prev == prev ) {
			*pFound = i;
			return &aaBkw[0][i];
		}
	ASSERT( 0 );
	return NULL;
}


void	Turbo::fillAbyw(	float 			aaAbyw[COMP_NUM][maxFsz],
							float 			aaExtrAb[COMP_AB_NUM][maxSz],
							const float *	pSbit,
							int				sz,
							int				yOffs	 )
{
	vectScl( &aaExtrAb[COMP_A][0], extrScale, sz );
	vectScl( &aaExtrAb[COMP_B][0], extrScale, sz );
	vectAdd( &aaAbyw[COMP_A][tailSz], &pSbit[sz*COMP_A], &aaExtrAb[COMP_A][0], sz );
	vectAdd( &aaAbyw[COMP_B][tailSz], &pSbit[sz*COMP_B], &aaExtrAb[COMP_B][0], sz );
	vectCpy( &aaAbyw[COMP_Y][tailSz], &pSbit[sz*yOffs], sz );
	vectCpy( &aaAbyw[COMP_W][tailSz], &pSbit[sz*(yOffs-COMP_Y1+COMP_W1)], sz );
}

void	Turbo::addAbywTail( 	float 		aaAbyw[COMP_NUM][maxFsz],
								int			sz			)
{
	for( int i = 0; i < COMP_NUM; i++ ) {
		vectCpy( &aaAbyw[i][0], &aaAbyw[i][sz], tailSz );
		vectCpy( &aaAbyw[i][sz+tailSz], &aaAbyw[i][tailSz], tailSz );
	}
	//Debug::print( "A", aaAbyw[COMP_A], sz+tailSz*2 );
	//Debug::print( "B", aaAbyw[COMP_B], sz+tailSz*2 );
	//Debug::print( "Y", aaAbyw[COMP_Y], sz+tailSz*2 );
	//Debug::print( "W", aaAbyw[COMP_W], sz+tailSz*2 );
}


void	Turbo::compDecod(	float 	aaApostAb[COMP_AB_NUM][maxFsz],
							float 	aaAbyw[COMP_NUM][maxFsz],
							int		fsz	)
{
	int		i, st, br;
	float	t, max;

	// backward recursion
	float		aaBeta[maxFsz+1][numSt];		//!< betas for full block
	memset( &aaBeta[fsz][0], 0, numSt*sizeof(aaBeta[0][0]) );
	for( i = fsz-1; i >= 0; i-- ) {
		for( st = 0; st < numSt; st++ ) {
			max = -FLT_MAX;
			for( br = 0; br < numBr; br++ ) {
				t = aaBeta[i+1][ aaBkw[st][br].prev ];
				t += vectDotProd( &aaAbyw[0][i], maxFsz, &aaBkw[st][br].aAbyw[0], COMP_NUM );
				max = _max( max, t );
			}
			aaBeta[ i ][ st ] = max;
		}
	}
	//Debug::print( "Beta", &aaBeta[0][0], (fsz+1)*numSt );

	// forward recursion and output LLR calculation
	float		aAlpha[numSt], aNext[numSt];	//!< alphas for current and next states
	memset( aAlpha, 0, sizeof(aAlpha) );
	float		maxAp, maxAn, maxBp, maxBn;
	for( i = 0; i < fsz; i++ ) {
		// output LLR calculation
		maxAp = -FLT_MAX;
		maxAn = -FLT_MAX;
		maxBp = -FLT_MAX;
		maxBn = -FLT_MAX;
		for( st = 0; st < numSt; st++ ) {
			for( br = 0; br < numBr; br++ ) {
				t = aAlpha[ aaBkw[st][br].cur ] + aaBeta[ i+1 ][ aaBkw[st][br].prev ];
				t += vectDotProd( &aaAbyw[0][i], maxFsz, &aaBkw[st][br].aAbyw[0], COMP_NUM );
				if( aaBkw[st][br].aAbyw[COMP_A] > 0 ) {
					maxAp = _max( maxAp, t );
				} else {
					maxAn = _max( maxAn, t );
				}
				if( aaBkw[st][br].aAbyw[COMP_B] > 0 ) {
					maxBp = _max( maxBp, t );
				} else {
					maxBn = _max( maxBn, t );
				}
			}
		}
		aaApostAb[COMP_A][i] = maxAp - maxAn;
		aaApostAb[COMP_B][i] = maxBp - maxBn;
		//Debug::print( "Llr", aaApostAb[COMP_A][i], aaApostAb[COMP_B][i] );

		// next alpha calculation
		for( st = 0; st < numSt; st++ ) {
			max = -FLT_MAX;
			for( br = 0; br < numBr; br++ ) {
				t = aAlpha[ aaFrw[st][br].prev ];
				t += vectDotProd( &aaAbyw[0][i], maxFsz, &aaFrw[st][br].aAbyw[0], COMP_NUM );
				max = _max( max, t );
			}
			aNext[ st ] = max;
		}
		//Debug::print( "Alpha", aNext, numSt );
		memcpy( aAlpha, aNext, sizeof(aAlpha) );
	}

}



void	Turbo::initIntlvTbl(	int			sz,
								const int	aP[4]		)
{
	int		i, p;
	// Step 2: P (j ) 8.4.9.2.3.2 CTC interleaver
	for( i = 0; i < sz; i++ ) {
		p = aP[0]*i+1;
		switch( i & 0x03 ) {
			case 0:							break;
			case 1:		p += sz/2+aP[1];	break;
			case 2:		p += aP[2];			break;
			case 3:		p += sz/2+aP[3];	break;
		}
		aIntlvTbl[i] = p % sz;
	}
}

void	Turbo::intlvAb(			float 		aaAbyw[COMP_NUM][maxFsz],
								int			sz			)
{
	int		i;
	float	aaT[COMP_AB_NUM][maxSz];
	// Step 1: Switch alternate couples
	for( i = 0; i < sz; i++ ) {
		if( i & 0x01 ) {
			aaT[COMP_B][i] = aaAbyw[COMP_A][i+tailSz];
			aaT[COMP_A][i] = aaAbyw[COMP_B][i+tailSz];
		} else {
			aaT[COMP_A][i] = aaAbyw[COMP_A][i+tailSz];
			aaT[COMP_B][i] = aaAbyw[COMP_B][i+tailSz];
		}
	}
	// Step 2: P (j )
	for( i = 0; i < sz; i++ ) {
		aaAbyw[COMP_A][i+tailSz] = aaT[COMP_A][ aIntlvTbl[i] ];
		aaAbyw[COMP_B][i+tailSz] = aaT[COMP_B][ aIntlvTbl[i] ];
	}
}

void	Turbo::deintlvExtr(		float 		aaExtrAb[COMP_AB_NUM][maxSz],
								int			sz			)
{
	int		i;
	float	aaT[COMP_AB_NUM][maxSz];
	// Step 2: P (j )
	for( i = 0; i < sz; i++ ) {
		aaT[COMP_A][ aIntlvTbl[i] ] = aaExtrAb[COMP_A][i];
		aaT[COMP_B][ aIntlvTbl[i] ] = aaExtrAb[COMP_B][i];
	}
	// Step 1: Switch alternate couples
	for( i = 0; i < sz; i++ ) {
		if( i & 0x01 ) {
			aaExtrAb[COMP_B][i] = aaT[COMP_A][i];
			aaExtrAb[COMP_A][i] = aaT[COMP_B][i];
		} else {
			aaExtrAb[COMP_A][i] = aaT[COMP_A][i];
			aaExtrAb[COMP_B][i] = aaT[COMP_B][i];
		}
	}
	//Debug::print( "ExtrA", aaExtrAb[COMP_A], sz );
	//Debug::print( "ExtrB", aaExtrAb[COMP_B], sz );
}


void	Turbo::getHardBit(		uint8 *		pBit,	
						  		float 		aaExtrAb[COMP_AB_NUM][maxFsz],
								int			sz			)
{
	int		i, p;
	// Step 2: P (j ) and Step 1: Switch alternate couples
	for( i = 0; i < sz; i++ ) {
		p = aIntlvTbl[i];
		if( p & 0x01 ) {
			pBit[p*2+COMP_B] = aaExtrAb[COMP_A][i+tailSz] > 0;
			pBit[p*2+COMP_A] = aaExtrAb[COMP_B][i+tailSz] > 0;
		} else {
			pBit[p*2+COMP_A] = aaExtrAb[COMP_A][i+tailSz] > 0;
			pBit[p*2+COMP_B] = aaExtrAb[COMP_B][i+tailSz] > 0;
		}
	}
}