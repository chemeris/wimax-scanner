/****************************************************************************/
/*! \file		deinterlv.h
	\brief		Deinterleaver
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Deinterleave block
	implements IEEE Std 802.16-2009, 8.4.9.3 Interleaving


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

#ifndef _DEINTRLV_H_
#define _DEINTRLV_H_

#include "global.h"
#include "comdefs.h"
#include "baseop.h"

class Deinterlv {


public:



/*****************************************************************************
Static constant external variables and external types
*****************************************************************************/







/******************************************************************************
External functions
******************************************************************************/


	Deinterlv(	FecType		fec,			//!< FEC type
				ModulType	modul, 			//!< modulation type
				int			bitPerBlock )	//!< bit per block
	{
		this->fec = fec;
		this->bitPerBlock = bitPerBlock;
		pPermTbl = new int[bitPerBlock];
		pBlckBuf = new float[bitPerBlock];

		int		s = modul+1;
		int		Ncbps = bitPerBlock;
		int		d = 16;
		int		j, m, k;

		for( j = 0; j < bitPerBlock; j++ ) {
			m = s*(j/s)+(j+(d*j/Ncbps))%s;		// mj = s * floor(j / s) + (j + floor(d * j / Ncbps))mod(s)
			k = d*m - (Ncbps-1) * (d*m/Ncbps);	// kj = d * mj - (Ncbps - 1) * floor(d * mj / Ncbps)
			pPermTbl[j] = k;
		}
	}

	~Deinterlv()
	{
		delete [] pPermTbl;
		delete [] pBlckBuf;
	}



	//! Deinterleav softbits
	void			deintlv(		float *			pSbit	)		//!< input/output softbits 
	{
		if( fec == FEC_CC ) {
			for( int i = 0; i < bitPerBlock; i++ )
				pBlckBuf[ pPermTbl[i] ] = pSbit[i];
			memcpy( pSbit, pBlckBuf, bitPerBlock*sizeof(*pBlckBuf) );
		}
	}


private:



/*****************************************************************************
Static constant internal variables and internal types
*****************************************************************************/




/*****************************************************************************
Internal variables
*****************************************************************************/

	FecType				fec;					//!< FEC type
	int					bitPerBlock;			//!< bit per block
	int	*				pPermTbl;				//!< permutation table - write offset in block
	float	*			pBlckBuf;				//!< block buffer


/******************************************************************************
Internal functions
******************************************************************************/
	


};



#endif //#ifndef _DEINTRLV_H_


