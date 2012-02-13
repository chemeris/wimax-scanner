/****************************************************************************/
/*! \file		derepet.h
	\brief		De-repetition 
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	De-repetition - averaging softbits of repeated slot
	implements IEEE Std 802.16-2009, 8.4.9.5 Repetition

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

#ifndef _DEREPEAT_H_
#define _DEREPEAT_H_

#include "comdefs.h"
#include "baseop.h"

class Derepeat {


public:



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/







/******************************************************************************
External functions
******************************************************************************/


	Derepeat(	RepeatType		type,			//!< repeat type
				int				slotSz	)		//!< slot size in bits
	{
		this->numRpt = repeat2num( type );
		this->slotSz = slotSz;
		slotNum = 0;
		memset( aSbit, 0, slotSz*sizeof( aSbit[0] ) );
	}

	~Derepeat()
	{
	}


	//! Derepeat slot, return true when output softbits are produced
	bool			derepeatIsOut(	float *			pSbit	)		//!< input/output softbits
	{
		if( numRpt == 1 )
			return true;
		
		int			i;
		for( i = 0; i < slotSz; i++ )
			aSbit[i] += pSbit[i];

		slotNum++;
		if( slotNum == numRpt ) {
			slotNum = 0;
			for( i = 0; i < slotSz; i++ )
				pSbit[i] = aSbit[i] / numRpt;
			memset( aSbit, 0, sizeof( aSbit ) );
			return true;
		} else {
			return false;
		}
	}


private:



/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/




/*****************************************************************************
Internal variables
*****************************************************************************/

	int			numRpt;			//!< number of repeats
	int			slotSz;			//!< slot size in bits
	int			slotNum;		//!< slot number in repeat period
	float		aSbit[symPerSlot*maxBitPerSym];	//!< slot softbits			

/******************************************************************************
Internal functions
******************************************************************************/
	



};



#endif //#ifndef _DEREPEAT_H_


