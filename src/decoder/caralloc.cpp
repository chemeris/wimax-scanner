/****************************************************************************/
/*! \file		caralloc.cpp
	\brief		Subcarrier allocation
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Subcarrier allocation, 
	implements IEEE Std 802.16-2009, 8.4.6 OFDMA subcarrier allocations

	TODO:
	1. First DL PUSC zone is implemented only
	2. Replace removePilotDc, renumbPhysToLog, allocScarToSch and slotReord by single prefilled lookup table

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


#include "caralloc.h"
#include "baseop.h"


/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/







/******************************************************************************
External functions
******************************************************************************/


CarAlloc::CarAlloc(	int		fftSz	)
{
	this->fftSz = fftSz;
	newFstDlPuscZone( 0, 0, 0 );
}


CarAlloc::~CarAlloc()
{
}


void			CarAlloc::newDlPuscZone(	bool *			pIsGroupUsed,
											int				clustPermBase,
											int				schPermBase		)
{
	zone = ZONE_DL_PUSC;
	dpClustPermBase = clustPermBase;
	dpSchPermBase = schPermBase;
	pDpParam = &aDpAllocParam[fftSz2Type(fftSz)];
	setDlPuscGroup( pIsGroupUsed );
}

void			CarAlloc::newFstDlPuscZone(	int				segm,
											int				clustPermBase,
											int				schPermBase		)
{
	bool	aAllGroup[dpGroupNum] = { true, true, true, true, true, true };
	newDlPuscZone( aAllGroup, clustPermBase, schPermBase );
	fstSch = (pDpParam->evenPermSz+pDpParam->oddPermSz)*segm;
}

void			CarAlloc::setDlPuscGroup(	const bool *			pIsGroupUsed	)
{
	memcpy( aDpIsGroupUsed, pIsGroupUsed, sizeof(aDpIsGroupUsed) );
	dpNumSch = 0;
	for( int i = 0; i < dpGroupNum; i++ ) {
		if( *pIsGroupUsed++ )
			dpNumSch += ( i & 0x01 ) ? pDpParam->oddPermSz : pDpParam->evenPermSz;
	}
	ASSERT( dpNumSch > 0 );
}

int				CarAlloc::getNumSch()
{
	return dpNumSch;
}



void		 	CarAlloc::fillSchParam(	SchParam *	pSchParam		)
{
	pSchParam->numSch = pDpParam->numSch;
	pSchParam->fstFftScar = pDpParam->guardLeft;
	pSchParam->numFftScar = fftSz - pDpParam->guardLeft - pDpParam->guardRight;
	pSchParam->scarPerSym = dpScarPerSch;
}


void			CarAlloc::demap(	fcomp *			pSchScar,
									const fcomp *	pPhyScar,
									int				symInSlotNum )
{
	fcomp	aBuf[maxSchScarNum];
	fcomp	aBuf1[maxSchScarNum];
	removePilotDc( aBuf, pPhyScar, symInSlotNum );
	renumbPhysToLog( aBuf1, aBuf );
	allocScarToSch( pSchScar, aBuf1 );
}


void			CarAlloc::slotReord(	fcomp *			pSlotScar,
										const fcomp *	pSchScar	)
{
	int		i, j;
	for( i = 0; i < pDpParam->numSch; i++ ) {
		for( j = 0; j < dpSymPerClust; j++ ) {
			memcpy(	pSlotScar,
					&pSchScar[j*maxSchScarNum],
					dpScarPerSch*sizeof(*pSchScar) );
			pSlotScar += dpScarPerSch;
		}
		pSchScar += dpScarPerSch;
	}
}




/*****************************************************************************
Static const internal variables and internal types
*****************************************************************************/



const CarAlloc::DpAllocParam		CarAlloc::aDpAllocParam[FFT_ENUM_NUM] = {
	//{	// FFT 128
	//},
	//{	// FFT 512
	//},
	{	// FFT 1024
		92,			// guardLeft
		91,			// guardRight
		841,		// used
		{	6, 48, 37, 21, 31, 40, 42, 56, 32, 47, 30, 33, 54, 18,
			10, 15, 50, 51, 58, 46, 23, 45, 16, 57, 39, 35, 7, 55,
			25, 59, 53, 11, 22, 38, 28, 19, 17, 3, 27, 12, 29, 26,
			5, 41, 49, 44, 9, 8, 1, 13, 36, 14, 43, 2, 20, 24, 52,
			4, 34, 0	}, // aRenumSeq
		30,			// numSch
		60,			// numClust
		6,			// evenPermSz
		4,			// oddPermSz
		{	3,2,0,4,5,1	},	// aEvenPerm
		{	3,0,2,1 }		// aOddPerm

	},
	//{	// FFT 2048
	//}
};

const bool			CarAlloc::aaDpIsPilotScar[dpSymPerClust][dpScarPerClust] = {
	{	0,0,0,0,1,0,0,0,1,0,0,0,0,0		},	// even symbols
	{	1,0,0,0,0,0,0,0,0,0,0,0,1,0		},	// odd symbols
};




/******************************************************************************
Internal functions
******************************************************************************/

void		CarAlloc::removePilotDc(	fcomp *			pTo,
										const fcomp *	pFrom,
										int				symInSlotNum )
{
	int				i, j;
	int				numClust = pDpParam->numClust;
	const bool *	pIsPilot = &aaDpIsPilotScar[symInSlotNum][0];


	for( i = 0; i < numClust/2; i++ )
		for( j = 0; j < dpScarPerClust; j++ ) {
			if( ! pIsPilot[j] )
				*pTo++ = *pFrom;
			pFrom++;
		}
	pFrom++; // remove DC subcarrier
	for( i = numClust/2; i < numClust; i++ )
		for( j = 0; j < dpScarPerClust; j++ ) {
			if( ! pIsPilot[j] )
				*pTo++ = *pFrom;
			pFrom++;
		}
}



void		CarAlloc::renumbPhysToLog(	fcomp *			pTo,
										const fcomp *	pFrom	)
{
	int			i, phys, log; // physical and logical cluster numbers 
	int			numClust = pDpParam->numClust;
	const int *	pRenum = pDpParam->aRenumSeq;

	phys = fstSch;
	for( i = 0; i < numClust; i++ ) {
		log = pRenum[ ( phys + 13 * dpClustPermBase ) % numClust ];
		//Debug::print( "Phys-Log", (float)phys, (float)log ); 
		memcpy( &pTo[log*dpDataPerClust],
				&pFrom[phys*dpDataPerClust],
				dpDataPerClust*sizeof(fcomp) );
		phys = cyclInc( phys, numClust );
	}
}


void		CarAlloc::allocScarToSch(	fcomp *			pTo,
										const fcomp *	pFrom	)
{
	int			numSch, usedScar, groupBase;
	const int *	pPerm;

	usedScar = 0;
	groupBase = 0;
	for( int i = 0; i < dpGroupNum; i++ ) {
		numSch = ( i & 0x01 ) ? pDpParam->oddPermSz : pDpParam->evenPermSz;
		if( aDpIsGroupUsed[i] ) {
			pPerm  = ( i & 0x01 ) ? pDpParam->aOddPerm  : pDpParam->aEvenPerm;
			for( int s = 0; s < numSch; s++ ) {
				for( int k = 0; k < dpScarPerSch; k++ ) {
					int	nk = ( k + 13 * s ) % dpScarPerSch;
					int scar = nk*numSch + ( pPerm[ ( nk%numSch + s ) % numSch ] + dpSchPermBase ) % numSch;
//					Debug::print( "From-To", (float)(scar+groupBase*dpScarPerSch), (float)(usedScar) ); 
					pTo[usedScar++] = pFrom[scar+groupBase*dpScarPerSch];
				}
			}
		}
		groupBase += numSch;
	}
}
