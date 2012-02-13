/****************************************************************************/
/*! \file		demod.h
	\brief		Demodulator
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Demodulator - symbol to softbit mapping
	implements IEEE Std 802.16-2009, 8.4.9.4.2 Data modulation

	TODO:
	1. 16 QAM and 64 QAM are not yet implemented

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

#ifndef _DEMOD_H_
#define _DEMOD_H_

#include "global.h"
#include "comdefs.h"
#include "baseop.h"

class Demod {


public:



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/







/******************************************************************************
External functions
******************************************************************************/


	Demod(	ModulType	modul, 		//!< modulation type
			int			slotSz	)	//!< slot size in symbols
	{
		this->slotSz = slotSz;
		ASSERT( modul == MODUL_QPSK );
		this->modul = modul;
		errSum = 0.f;
		numSym = 0;
	}

	~Demod()
	{
	}



	//! Demodulate symbols
	void			demod(		float *			pSbit,			//!< output softbits, in order b0, b1, b2 ... 
								const fcomp *	pSym,			//!< input subcarrier symbols
								int				numSlot	)		//!< number of slots
	{
		int		len = numSlot*slotSz;
		for( int i = 0; i < len; i++ ) {
			*pSbit++ = pSym->real()*MF_SQRT2;
			*pSbit++ = pSym->imag()*MF_SQRT2;
			errSum += sq( abs( pSym->imag() ) - MF_SQRT1_2 ); 
			errSum += sq( abs( pSym->real() ) - MF_SQRT1_2 ); 
			pSym++;
		}
		numSym += len;
	}

	//! Get burst SNR
	float			getSnr()
	{
		return sqrt( errSum/(float)numSym );
	}


private:



/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/




/*****************************************************************************
Internal variables
*****************************************************************************/

	int					slotSz;		//!< slot size in symbols
	ModulType			modul;		//!< modulation type
	float				errSum;		//!< total symbol error sum
	int					numSym;		//!< total number of symbols 


/******************************************************************************
Internal functions
******************************************************************************/
	


};



#endif //#ifndef _DEMOD_H_


