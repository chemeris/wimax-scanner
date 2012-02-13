/****************************************************************************/
/*! \file		caralloc.h
	\brief		Subcarrier allocation
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Subcarrier allocation, 
	implements IEEE Std 802.16-2009, 8.4.6 OFDMA subcarrier allocations

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

#ifndef _CARALLOC_H_
#define _CARALLOC_H_

#include "comdefs.h"
#include "global.h"


class CarAlloc {


public:

/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/


	//! Subchannel params 
	struct SchParam {
		int			numSch;			//!< number of subchannel
		int			fstFftScar;		//!< first used FFT subcarrier
		int			numFftScar;		//!< number of used FFT subcarrier
		int			scarPerSym;		//!< number of subcarrier per symbol
	};





/******************************************************************************
External functions
******************************************************************************/

	CarAlloc(	int		fftSz	);		//!< FFT size


	~CarAlloc();


	/*! Start new DL PUSC allocation zone, non first (containing FCH) zone
		segment is used from newFstDlPuscZone
		*/
	void			newDlPuscZone( 		bool *		pIsGroupUsed,		//!< Is major group used
										int			clustPermBase,		//!< Cluster permutation base
										int			schPermBase		);	//!< Subchannle permutation base

	/*! Start new first (containing FCH) DL PUSC allocation zone, all major groups used
		if not all major group are used, they should be set with setDlPuscGroup
		after decoding FCH 
		*/
	void			newFstDlPuscZone(	int			segm,				//!< segment
										int			clustPermBase,		//!< Cluster permutation base
										int			schPermBase		);	//!< Subchannle permutation base

	/*! Set DL PUSC used major group, used in first (containing FCH) DL PUSC allocation zone only
		to set it after decoding FCH
		*/
	void			setDlPuscGroup(	const bool *	pIsGroupUsed	);	//!< input is major group used

	//! Get number of subchannel per timeslot, usefull after setting groups by setDlPuscGroup
	int				getNumSch();


	//! Fill subchannel params
	void		 	fillSchParam(	SchParam *	pSchParam		);		//!< output subchannel params


	//! Demap subcarrier
	void			demap(		fcomp *			pSchScar,		//!< output subchannel subcarrier
								const fcomp *	pPhyScar,		//!< input physical subcarrier
								int				symInSlotNum );	//!< symbol in slot number

	/*! Reorder subcarrier in slot order: 
		sch(n)sym(m), sch(n)sym(m+1), sch(n+1)sym(m), sch(n+1)sym(m+1)
		*/
	void			slotReord(	fcomp *			pSlotScar,		//!< output slot subcarrier
								const fcomp *	pSchScar	);	//!< input subchannel subcarrier


private:




/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/



/********** DL PUSC **********/

static const int		dpMaxClustPerSym = 120;	//!< max cluster per symbol number
static const int		dpMaxEvenPermSz = 12;	//!< max even major group permutation sequence size
static const int		dpMaxOddPermSz = 8;		//!< max odd major group permutation sequence size

static const int		dpSymPerClust = 2;		//!< symbols per cluster
static const int		dpScarPerClust = 14;	//!< data and pilot subcarriers per cluster
static const int		dpDataPerClust = 12;	//!< data only subcarriers per cluster


//! OFDMA DL subcarrier allocations—PUSC params, IEEE Std 802.16-2009, table 442 - 445 
struct DpAllocParam {
	int			guardLeft;			//!< Number of Guard subcarriers, Left
	int			guardRight;			//!< Number of Guard subcarriers, Right
	int			used;				//!< Number of used subcarriers
	int			aRenumSeq[dpMaxClustPerSym];		//!< Renumbering sequence	
	int			numSch;				//!< Number of subchannels
	int			numClust;			//!< Number of cluster
	int			evenPermSz;			//!< Even major group permutation size
	int			oddPermSz;			//!< Odd major group permutation size
	int			aEvenPerm[dpMaxEvenPermSz];	//!< Even major group Permutation
	int			aOddPerm [dpMaxOddPermSz];	//!< Odd major group Permutation
};

//! OFDMA DL subcarrier allocations—PUSC description table, IEEE Std 802.16-2009, table 442 - 445
static const DpAllocParam	aDpAllocParam[FFT_ENUM_NUM];

//! Is pilot subcarrier in cluster
static const bool			aaDpIsPilotScar[dpSymPerClust][dpScarPerClust];



/*****************************************************************************
Internal variables
*****************************************************************************/

	int						fftSz;				//!< FFT size
	int						fstSch;				//!< first (0-th) subchannel
	Zone					zone;				//!< current allocation zone

	// DL PUSC params
	int						dpClustPermBase;	//!< cluster permutation base
	int						dpSchPermBase;		//!< subchannel permutation base
	bool					aDpIsGroupUsed[dpGroupNum];	//! is major group used
	const DpAllocParam *	pDpParam;			//!< current allocation params
	int						dpNumSch;			//!< number of subchannels per timeslot


/******************************************************************************
Internal functions
******************************************************************************/

	/*! Remove pilot and DC subcarriers
		subsection d) of 8.4.6.1.2.1.1 DL subchannels subcarrier allocation in PUSC
		*/
	void		removePilotDc(	fcomp *			pTo,			//!< output buffer
								const fcomp *	pFrom,			//!< input buffer
								int				symInSlotNum );	//!< symbol in slot number

	/*! Renumber physical cluster to logical
		sub-section b) of 8.4.6.1.2.1.1 DL subchannels subcarrier allocation in PUSC
		*/
	void		renumbPhysToLog(	fcomp *			pTo,		//!< output buffer
									const fcomp *	pFrom	);	//!< input buffer

	/*! Allocate subcarrier to subchannel
		sub-section c) and d) of 8.4.6.1.2.1.1 DL subchannels subcarrier allocation in PUSC
		*/
	void		allocScarToSch(		fcomp *			pTo,		//!< output buffer
									const fcomp *	pFrom	);	//!< input buffer

};



#endif //#ifndef _SCARALLOC_H_


