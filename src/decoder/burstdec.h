/****************************************************************************/
/*! \file		burstdec.h
	\brief		Burst decoder
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Burst decoder, 
	implements IEEE Std 802.16-2009, 8.4.9 Channel coding, 
	excluding 8.4.9.4.1 Subcarrier randomization

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


#ifndef _BURSTDEMOD_H_
#define _BURSTDEMOD_H_

#include "comdefs.h"
#include "global.h"
#include "demod.h"
#include "derepeat.h"
#include "deinterlv.h"
#include "fec.h"
#include "prbs.h"


class BurstDec {


public:

/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/





/******************************************************************************
External functions
******************************************************************************/

	BurstDec();


	~BurstDec();


	//! Init FCH burst only decoding and process 0-th slot
	void		initFch();

	/*! Init DL-MAP burst and other burst decoding, 
		adding other bursts with addBurst, reprocess 0-th timeslot 
		without FCH and process all other slots
		return last slot of DL-map
		*/
	int		initDlmapGetLastTs(	const FchMsg *		pFch,			//!< FCH message
								int					numSch );		//!< number of subchannels per timeslot


	//! Add bursts params list to init decoder
	void		addBurst(		int					numBurst,		//!< number of burst in list
								const BurstParam *	pParam		);	//!< burst param list


	//! Put symbol for decoding and decode it according to set burst params
	void		putSym(			const fcomp *		pSlotScar,		//!< logical symbol in slot order
								int					tsNum	 );		//!< timeslot number


	//! Get decoded burst data, return pointer to data or NULL if no data decoded
	const BurstData *		getBurstData();




private:




/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/

	//! Burst decoding state
	enum DecStat {
		DECSTAT_DEC,			//!< burst data is decoding
		DECSTAT_FIN,			//!< burst data decoding finished, wait for reading
		DECSTAT_GOT				//!< burst data is got
	};

	//! Burst decoder
	struct Burst {
		BurstParam		param;				//!< burst param

		Demod *			pDem;				//!< demodulator
		Derepeat *		pDerepeat;			//!< derepeat
		Deinterlv *		pDeintlv;			//!< deinterleaver
		Fec	*			pFec;				//!< fec decoder
		Prbs *			pPrbs;				//!< pseudo-random bit sequence generator

		uint8 *			pNextBit;			//!< next burst bit (inside pFrmBit)
		int				residSlot;			//!< residual slots to fill
		DecStat			stat;				//!< decoding state
		BurstData		data;				//!< burst data
	};




/*****************************************************************************
Internal variables
*****************************************************************************/

	int					numSch;				//!< total number of subchannels in timeslot
	int					scarPerSch;			//!< subcarrier per subchannle

	int					numBurst;			//!< number of burst in aBurst
	Burst				aBurst[maxBurstPerFrm];		//!< burst decoder

	uint8 *				pFrmBit;			//!< frame bits size maxSlotPerFrm*maxSymPerSlot*maxScarPerSch*maxBitPerSym, sheared by all burst decoders
	int					nextBit;			//!< next free bit in pFrmSbit and pFrmBit

/******************************************************************************
Internal functions
******************************************************************************/


	//! Find put burst, whose data should be decoded and present in current timeslot, return pointer to burst or NULL if not found
	Burst *		findPutBurst(	int *				pPrevBurst,		//!< input/output previously/last found burst number
								int					tsNum		);	//!< timeslot number	

	//! Find ready burst, whose data fully decoded, return pointer to burst or NULL if not found
	Burst *		findReadyBurst();


	//! Get slot per burst number, including repeated slot
	int			getSlotPerBurst( const BurstParam *	pParam		);	//!< burst params

	//! Get position (number of slots and first slot) for current timeslot, return first slot
	int			getPosSlot(		const BurstParam *	pParam,			//!< burst params
								int					tsNum,			//!< timeslot number
								int *				pNumSlot	);	//!< output number of slots

	//! Get first slot number in current number, including repeating
	int			getFstSlotInTs(	const BurstParam *	pParam,			//!< burst params
								int					tsNum		);	//!< timeslot number	


	//! Init new burst
	void		initNewBurst(	Burst *				pBurst,			//!< burst to init
								const BurstParam *	pParam,			//!< burst params
								bool				isFch = false );	//!< is FCH burst

	//! Decode (demodulate, derepeat, deinterleave, decode, derandomize) data and put it to internal buffer
	void		decBurstSym(	const fcomp *		pSlotScar,		//!< logical symbol in slot order
								Burst *				pBurst,			//!< burst to process
								int					 tsNum		);	//!< timeslot number

	//! Delete all bursts
	void		deleteAllBurst();



};



#endif //#ifndef _BURSTDEMOD_H_


