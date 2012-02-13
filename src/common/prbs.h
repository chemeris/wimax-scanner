/****************************************************************************/
/*! \file		prbs.h
	\brief		Pseudo Random Binary Sequence generator
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Pseudo Random Binary Sequence generator.

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

#ifndef _PRBS_H_
#define _PRBS_H_

#include "comdefs.h"
#include "baseop.h"

class Prbs {


public:



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/

static const int	regSz = 32;		//!< Registor size in bits, all taps should be less than ( register size - max sequence size )



/******************************************************************************
Static external functions
******************************************************************************/




/******************************************************************************
External functions
******************************************************************************/


	Prbs(		int			numTap,		//!< number of nonzero taps, excluding 0-th tap 
				const int *	pTap	)	//!< nonzero taps, excluding 0-th tap, max tap should be last
	{
		this->numTap = numTap;
		this->pTap = new int[numTap];
		int	maxTap = 0;
		int minTap = INT_MAX;
		for( int i = 0; i < numTap; i++ ) {
			this->pTap[i] = pTap[i];
			maxTap = _max( maxTap, pTap[i] );
			minTap = _min( minTap, pTap[i] );
			ASSERT( pTap[i] <= pTap[numTap-1] );
		}
		maxSeqSz = _min( minTap-1, regSz-maxTap );
		ASSERT( maxSeqSz > 0 );
		reg = 0;
	}

	~Prbs()
	{
		delete[] pTap;
	}


	//! Ininitial register value
	void			init(	uint32	val	)		//!< initial register value		
	{
		reg = val;
	}

	//! Generate single pseudo random bit, return register state
	uint32			genBit()
	{
		uint32	t = 0;
		reg <<= 1;
		for( int i = 0; i < numTap; i++ )
			t ^= reg >> pTap[i];
		reg |= t & 0x01;
		return reg; // ( reg >> pTap[numTap-1] ) & 0x01;
	}

	//! Generate pseudo random sequence, LSB is latest bit
	uint32			genSeq(	int		sz	)		//!< sequence size in bits
	{
		ASSERT( sz <= regSz );
		int	p;
		uint32	r = 0;
		while( sz > 0 ) {
			p = _min( sz, maxSeqSz );
			r = ( r << p ) | genSeqMaxLen( p );
			sz -= p;
		}
		return r;
	}


private:



/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/




/*****************************************************************************
Internal variables
*****************************************************************************/

	uint32			reg;		//!< shift register

	int				numTap;		//!< number of nonzero taps, excluding 0-th tap 
	int *			pTap;		//!< nonzero taps shift, excluding 0-th tap
	int				maxSeqSz;	//!< Max sequence size generate by single operation

/******************************************************************************
Internal functions
******************************************************************************/
	
	//! Generate sequence of bit of max length, LSB is latest bit
	uint32			genSeqMaxLen(	int sz	)		//!< sequence size in bits, up to maxSeqSz
	{
		ASSERT( sz <= maxSeqSz );
		uint32	m = ( 0x01UL << sz ) - 1;
		uint32	t = 0;
		reg <<= sz;
		for( int i = 0; i < numTap; i++ )
			t ^= reg >> pTap[i];
		reg |= t & m;

		return ( reg >> pTap[numTap-1] ) & m;
	}



};



#endif //#ifndef _PRBS_H_


