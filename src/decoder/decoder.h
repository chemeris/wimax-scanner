/****************************************************************************/
/*! \file		decoder.h
	\brief		WIMAX decoder
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	WIMAX decoder.

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

#ifndef _DECODER_H_
#define _DECODER_H_

#include "comdefs.h"
#include "global.h"
#include "caralloc.h"
#include "burstdec.h"
#include "ieparser.h"


class Decoder {


public:



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/

	const static int	maxPhyRandOffs = 32;		//!< max physical subcarrier randomisation offset


	//! Symbol processing result code
	enum ProcRes {
		PROC_RES_WAIT,				//!< wait and continue to supply symbols for decoding
		PROC_RES_FIN,				//!< processing is finished
		PROC_RES_FCH_FAIL =INT_MIN, //!< FCH decoding failure			
		PROC_RES_DLMAP_FAIL,		//!< DL-MAP decoding failure			
	};

	//! Decoder results
	struct DecRes {
		FchMsg			fchMsg;	//!< FCH message
		DlmapMsg		dlmapMsg;	//!< DL-MAP message
	};







/******************************************************************************
External functions
******************************************************************************/

	Decoder(	int				fftSz,			//!< FFT size
				unsigned long 	wsharkIp	);	//!< wireshark IP address

	~Decoder();


	//! Start new frame
	void			startNewFrm(	int			index	);	//!< preamble index	

	//! Process new symbol
	ProcRes			procSym(	const fcomp *	pSym,		//!< input symbol
								const fcomp *	pChEst	);	//!< channel estimation


	//! Get decoded results, full results valid after procSym returns PROC_RES_FIN
	const DecRes *	getDecRes();	

	//! Descramble the subcarriers, this is used for pilots sequence generation
	void phyDerand2(fcomp *pin,
					fcomp *pout, 
					int _symInSlotCntr, 
					int _slotCntr); 
private:



/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/




/*****************************************************************************
Internal variables
*****************************************************************************/

	int						idcell;			//!< IDCell
	int						segm;			//!< segment
	CarAlloc::SchParam		schParam;		//!< subchannel params
	int						symPerTs;		//!< symbol per timeslot number

	int						symInSlotCntr;	//!< symbol in slot counter
	int						slotCntr;		//!< slot counter
	int						dlmapLstTs;		//!< DL-MAP last time slot number, set after decoding FCH

	CarAlloc				carAlloc;		//!< subcarrier allocation module
	BurstDec				burstDec;		//!< bursts decoder
	IeParser				ieParser;		//!< IE parser

	fcomp					aaPhyScar[maxSymPerTs][maxUsedScarNum];	//!< physical ordered subcarrier
	fcomp					aaSchScar[maxSymPerTs][maxSchScarNum];	//!< logical subchannel ordered subcarrier
	fcomp					aSlotScar[maxSchScarNum*maxSymPerTs];	//!< slot ordered subcarrier

	float					aPhyRandSeq[maxUsedScarNum+maxPhyRandOffs];		//!< physical subcarrier randomisation sequence

	ProcRes					procRes;		//!< procSym result code
	DecRes					decRes;			//!< decoding results


/******************************************************************************
Internal functions
******************************************************************************/
	
	//! Set IDCell and segment
	void			setIdcellSegm( int	index );	//!< preamble index

	//! Init first DL PUSC zone for FCH detection
	void			initFstZone();

	//! Equalized used subcarrier of symbol and put them to internal buffer, remove guard
	void			equUsedSym(	const fcomp *	pSym,		//!< input symbol
								const fcomp *	pChEst	);	//!< channel estimation


	/*! Init physical subcarrier randomisation sequence
		8.4.9.4.1 Subcarrier randomization
		*/
	void			initPhyRandSeq();

	/*! Physical subcarrier de-randomisation
		8.4.9.4.1 Subcarrier randomization
		*/
	void			phyDerand();


	//! Decode FCH data and apply them 
	void			decApplyFch();

	//! Decode DL-MAP data and apply them 
	void			decApplyDlmap();




};



#endif //#ifndef _DECODER_H_


