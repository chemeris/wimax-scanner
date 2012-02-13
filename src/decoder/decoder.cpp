/****************************************************************************/
/*! \file		decoder.cpp
	\brief		WIMAX decoder
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	WIMAX decoder.

	TODO:
	1. 1024 FFT, DL PUSC FCH/DL-MAP decoding is implemented only

	History:
	0.1 - initial version

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

#include "decoder.h"
#include "prbs.h"
#include "vect.h"


/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/





/******************************************************************************
External functions
******************************************************************************/

Decoder::Decoder(	int				fftSz,
					unsigned long 	wsharkIp	)
:	carAlloc( fftSz ),
	burstDec(),
	ieParser( wsharkIp )
{
}


Decoder::~Decoder()
{
}


void					Decoder::startNewFrm(	int			index	)
{
	ASSERT( ( index >= 0 ) && ( index < maxPreamIndex ) ); 
	setIdcellSegm( index );
	initFstZone();
	burstDec.initFch();
	procRes = PROC_RES_WAIT;
}



Decoder::ProcRes		Decoder::procSym(	const fcomp *	pSym,
											const fcomp *	pChEst	)
{
	if( procRes < PROC_RES_WAIT ) // fatal error stop processing
		return procRes;

	equUsedSym( pSym, pChEst );
	phyDerand();
	carAlloc.demap(		&aaSchScar[symInSlotCntr][0],
						&aaPhyScar[symInSlotCntr][0],
						symInSlotCntr );

	symInSlotCntr++;
	if( symInSlotCntr != symPerTs )
		return PROC_RES_WAIT;

	carAlloc.slotReord(	aSlotScar, &aaSchScar[0][0] );
	burstDec.putSym( aSlotScar, slotCntr );

	if( slotCntr == 0 )
		decApplyFch();
	if( slotCntr == dlmapLstTs )
		decApplyDlmap();

	symInSlotCntr = 0;
	slotCntr++;
	return procRes;
}


const Decoder::DecRes *		Decoder::getDecRes()
{
	return &decRes;
}



/*****************************************************************************
Static const internal variables and internal types
*****************************************************************************/




/******************************************************************************
Internal functions
******************************************************************************/


void			Decoder::setIdcellSegm( int	index )
{
	ASSERT( index < 114 );
	if( index < 96 ) {
		idcell = index%32;
		segm = index/32;
	} else {
		idcell = index-96;
		segm = idcell%3;
	}
}


void			Decoder::initFstZone()
{
	carAlloc.newFstDlPuscZone( segm, 0, idcell );
	initPhyRandSeq();

	symPerTs = aSymPerTsTbl[ ZONE_DL_PUSC ];
	symInSlotCntr = 0;
	slotCntr = 0;

	dlmapLstTs = -1;

	carAlloc.fillSchParam( &schParam );
}

void			Decoder::equUsedSym(	const fcomp *	pSym,
										const fcomp *	pChan		)
{
	int			fstUsed = schParam.fstFftScar;
	int			usedLen = schParam.numFftScar;
	fcomp *		pPut = &aaPhyScar[symInSlotCntr][0];

	pSym  += fstUsed;
	pChan += fstUsed;

	for( int i = 0; i < usedLen; i++ ) {
		*pPut++ = *pSym++ * pChan->conj();
		pChan++;
	}
}


void			Decoder::initPhyRandSeq()
{
	uint32		t;
	Prbs		prbs( ARRAY_SZ(aPhyRandPrbsTap), aPhyRandPrbsTap );
	prbs.init( bitRev( idcell,5) | ( ( bitRev(segm+1,2) ) << 5 ) | ( 0x0F << 7 ) );
	for( int i = 0; i < maxUsedScarNum+maxPhyRandOffs; i++ ) {
		t = ( prbs.genBit() >> aPhyRandPrbsTap[ARRAY_SZ(aPhyRandPrbsTap)-1] ) & 0x01;
		aPhyRandSeq[i] = 2.f*(0.5f - (float)t );
	}
}


void			Decoder::phyDerand()
{
	vectMpy(	&aaPhyScar[symInSlotCntr][0],
				&aPhyRandSeq[symInSlotCntr + slotCntr*symPerTs],
				schParam.numFftScar		);
}

void			Decoder::phyDerand2(	fcomp *pin,
										fcomp *pout, 
										int _symInSlotCntr, 
										int _slotCntr)
{
	vectMpy(	pout,
				pin,
				&aPhyRandSeq[_symInSlotCntr + _slotCntr*symPerSlot],
				schParam.numFftScar		);
}



void			Decoder::decApplyFch()
{
	const BurstData *		pData = burstDec.getBurstData();
	if( pData ) {
		const FchMsg *		pFch = ieParser.parseFch( pData );
		if( pFch ) {
			carAlloc.setDlPuscGroup( pFch->aIsSchGrpUsed );
			carAlloc.slotReord(	aSlotScar, &aaSchScar[0][0] );
			dlmapLstTs = burstDec.initDlmapGetLastTs( pFch, carAlloc.getNumSch() );
			burstDec.putSym( aSlotScar, slotCntr );

			decRes.fchMsg = *pFch;
			return;
		}
	}
	procRes = PROC_RES_FCH_FAIL;
}

void			Decoder::decApplyDlmap()
{
	const BurstData *		pData = burstDec.getBurstData();
	if( pData ) {
		const DlmapMsg *	pDlmap = ieParser.parseDlmap( pData );
		if( pDlmap ) {
			decRes.dlmapMsg = *pDlmap;
			return;
		}
	}
	procRes = PROC_RES_DLMAP_FAIL;
}
