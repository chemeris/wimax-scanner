/****************************************************************************/
/*! \file		burstdec.cpp
	\brief		Burst decoder
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Burst decoder, 
	implements IEEE Std 802.16-2009, 8.4.9 Channel coding, 
	excluding 8.4.9.4.1 Subcarrier randomization

	TODO:
	1. Single DL burst with QPSK modulation and CC or CTC coding is implemented only
	2. HARQ is not implemented

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

#include "burstdec.h"



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/






/******************************************************************************
External functions
******************************************************************************/

BurstDec::BurstDec()
{
	numBurst = 0;
	pFrmBit = new uint8[maxSlotPerFrm*symPerSlot*maxBitPerSym];
}

BurstDec::~BurstDec()
{
	deleteAllBurst();
	delete [] pFrmBit;
}


void		BurstDec::initFch()
{
	numSch = 0; // not used before DL-MAP
	scarPerSch = dpScarPerSch;

	deleteAllBurst();
	nextBit = 0;
	initNewBurst( aBurst, &fchBurstParam, true );
	numBurst = 1;
}

int			BurstDec::initDlmapGetLastTs(	const FchMsg *	pFch,
											int				numSch	)
{
	this->numSch = numSch;

	BurstParam		dlmapParam = dlmapDefBurstParam;
	dlmapParam.fec = pFch->dlmapFec;
	dlmapParam.repeat = pFch->dlmapRepeat;
	int		lenSch = pFch->dlmapLen+dlmapParam.fstSch;
	dlmapParam.lstSch = (lenSch-1)%numSch;
	dlmapParam.lstTs = (lenSch-1)/numSch;

	deleteAllBurst();
	nextBit = 0;
	initNewBurst( aBurst, &dlmapParam );
	numBurst = 1;
	return dlmapParam.lstTs;
}



void		BurstDec::addBurst(			int					numAdd,
										const BurstParam *	pParam	)
{
	ASSERT( numBurst + numAdd < maxBurstPerFrm );
	for( int i = 0; i < numAdd; i++ )
		initNewBurst( &aBurst[numBurst++], pParam++ );
}


void		BurstDec::putSym(			const fcomp *		pSlotScar,
										int					tsNum		)
{
	Burst *		pBurst;
	int			prevBurst = -1;
	while( ( pBurst = findPutBurst( &prevBurst, tsNum ) ) != NULL )
		decBurstSym( pSlotScar, pBurst, tsNum );
}

const BurstData *		BurstDec::getBurstData()
{
	Burst *		pBurst;
	while( ( pBurst = findReadyBurst() ) != NULL ) {
		pBurst->stat = DECSTAT_GOT;
		return &pBurst->data;
	}
	return NULL;
}




/*****************************************************************************
Static const internal variables and internal types
*****************************************************************************/





/******************************************************************************
Internal functions
******************************************************************************/

BurstDec::Burst *	BurstDec::findPutBurst(	int *	pPrevBurst,
											int		tsNum		)
{
	Burst *		pBurst = aBurst;
	for( int  i = *pPrevBurst+1; i < numBurst; i++ ) {
		if( ( pBurst->param.fstTs <= tsNum ) &&
			( pBurst->param.lstTs >= tsNum ) &&   
			( pBurst->stat == DECSTAT_DEC  )	) {
			*pPrevBurst = i;
			return pBurst;
		}
		pBurst++;
	}
	return NULL; 
}


BurstDec::Burst *	BurstDec::findReadyBurst()
{
	Burst *		pBurst = aBurst;
	for( int  i = 0; i < numBurst; i++ ) {
		if( pBurst->stat == DECSTAT_FIN	)
			return pBurst;
		pBurst++;
	}
	return NULL;
}



int					BurstDec::getSlotPerBurst(	const BurstParam *	pParam	)
{
	int		numSlot;
	switch( pParam->shape ) {
		case SHAPE_RECT:
			numSlot = ( pParam->lstSch - pParam->fstSch + 1 ) *
					  ( pParam->lstTs  - pParam->fstTs  + 1 );
			break;
		case SHAPE_CONT_SCH:
			numSlot = ( pParam->lstSch - pParam->fstSch + 1 ) +
					  numSch * ( pParam->lstTs - pParam->fstTs );
			break;
		default:
			ASSERT( 0 );
			break;
	}
	return numSlot;
}


int					BurstDec::getPosSlot(		const BurstParam *	pParam,
												int					tsNum,
												int *				pNumSlot	)
{
	int		numSlot;
	int		fstSlot;
	switch( pParam->shape ) {
		case SHAPE_RECT:
			numSlot = pParam->lstSch-pParam->fstSch+1;
			fstSlot = pParam->fstSch;
			break;
		case SHAPE_CONT_SCH:
			if( ( pParam->fstTs == pParam->lstTs ) &&
				( pParam->fstTs == tsNum		 )    ) {
				numSlot = pParam->lstSch-pParam->fstSch+1;
			} else if( tsNum == pParam->fstTs ) {
				numSlot = numSch - pParam->fstSch;
			} else if( tsNum == pParam->lstTs ) {
				numSlot = pParam->lstSch + 1;
			} else if(	( tsNum > pParam->fstTs ) && 
						( tsNum < pParam->lstTs )    ) {
				numSlot = numSch;
			}
			if( pParam->fstTs == tsNum ) {
				fstSlot = pParam->fstSch;
			} else {
				fstSlot = 0;
			}
			break;
		default:
			ASSERT( 0 );
			break;
	}
	*pNumSlot = numSlot;
	return fstSlot;
}



void				BurstDec::initNewBurst(	Burst *				pBurst,
											const BurstParam *	pParam,
											bool				isFch		)
{
	pBurst->param = *pParam;
	ASSERT( ( pParam->modul == MODUL_QPSK ) || ( pParam->repeat == REPEAT_1 ) ); // only QPSK may be repeated 
	int		slotSz = symPerSlot;		// size in bits at different stages of decoding
	pBurst->pDem = new Demod( pParam->modul, slotSz );
	slotSz *= modul2bps( pParam->modul );
	pBurst->pDerepeat = new Derepeat( pParam->repeat, slotSz );
	pBurst->pDeintlv = new Deinterlv( pParam->fec, pParam->modul, slotSz );
	slotSz = (int)( (float)slotSz * fecrate2val( pParam->rate ) );
	int		numSlot = getSlotPerBurst( pParam )/repeat2num( pParam->repeat );	// number of slot after derepeat
	pBurst->pFec = new Fec( pParam->fec, pParam->rate, pParam->modul, slotSz, numSlot );
	pBurst->pPrbs = new Prbs( ARRAY_SZ(aBurstDataPrbsTap), aBurstDataPrbsTap );

	pBurst->pNextBit = &pFrmBit[nextBit];
	pBurst->residSlot = getSlotPerBurst( pParam );
	pBurst->stat = DECSTAT_DEC;
	pBurst->data.pBit = pBurst->pNextBit;
	pBurst->data.len  = numSlot * slotSz;

	nextBit += pBurst->data.len;
}



void				BurstDec::decBurstSym(	const fcomp *	pSlotScar,
											Burst *			pBurst,
											int				 tsNum			)
{
	float		aSbit[symPerSlot*maxBitPerSym];
	int			numSlot ;
	int			fstSlot = getPosSlot(  &pBurst->param, tsNum, &numSlot );
	int			i, numBit;
	pSlotScar += fstSlot*symPerSlot;
//	Debug::print( "IQ", pSlotScar, 96*4 );
	for( i = 0; i < numSlot; i++ ) {
		pBurst->pDem->demod( aSbit, pSlotScar, 1 );
		pSlotScar += symPerSlot;
//		Debug::print( "Rpt", aSbit, 96 );
		if( pBurst->pDerepeat->derepeatIsOut( aSbit ) ) {
//			Debug::print( "Intlv", aSbit, 96 );
			pBurst->pDeintlv->deintlv( aSbit );
//			Debug::print( "Enc", aSbit, 96 );
			numBit = pBurst->pFec->decod( pBurst->pNextBit, aSbit );
			pBurst->pPrbs->init( pBurst->param.isFch ? 0x000 : 0x5476 ); // FCH do not use randomization
			for( int j = 0; j < numBit; j++ )
				pBurst->pNextBit[j] ^= (uint8)pBurst->pPrbs->genBit()&0x01;
//			if( numBit )
//				Debug::print( "Bit", pBurst->pNextBit, numBit );
			pBurst->pNextBit += numBit;
		}
	}
	pBurst->residSlot -= numSlot;
	if( pBurst->residSlot <= 0 )
		pBurst->stat = DECSTAT_FIN;
}


void				BurstDec::deleteAllBurst()
{
	Burst *		pBurst = aBurst;
	for( int i = 0; i < numBurst; i++ ) {
		delete pBurst->pDem;
		delete pBurst->pDerepeat;
		delete pBurst->pDeintlv;
		delete pBurst->pFec;
		delete pBurst->pPrbs;
	}
}


