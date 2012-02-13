/****************************************************************************/
/*! \file		vect.h
	\brief		Vector operations
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	1.0
     
	Vector operations for floating point math.
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


#ifndef _VECT_H_
#define _VECT_H_

#include "comdefs.h"
#include "baseop.h"



/******************************************************************************
Static external functions
******************************************************************************/

template <class T>
__inline void		vectCpy(	T *			pR, 
								const T *	pA,
								uint32		len )
{
	while( len-- > 0 )
		*pR++ = *pA++;
}

template <class T, class S, class R>
__inline void		vectAdd(	T *			pR, 
								const S *	pA,
								const R *	pB,
								uint32		len )
{
	while( len-- > 0 )
		*pR++ = *pA++ + *pB++;
}

template <class T, class S>
__inline void		vectAdd(	T *			pR, 
								const S *	pA,
								uint32		len )
{
	while( len-- > 0 )
		*pR++ += *pA++;
}

template <class T, class S, class R>
__inline void		vectSub(	T *			pR, 
								const S *	pA,
								const R *	pB,
								uint32		len )
{
	while( len-- > 0 )
		*pR++ = *pA++ - *pB++;
}

template <class T, class S>
__inline void		vectSub(	T *			pR, 
								const S *	pA,
								uint32		len )
{
	while( len-- > 0 )
		*pR++ -= *pA++;
}

template <class T, class S, class R>
__inline void		vectMpy(	T *			pR,
								const S *	pA,
								const R *	pB,
								uint32 len )
{
	while( len-- > 0 )
		*pR++ = *pA++ * *pB++;
}

template <class T, class S>
__inline void		vectMpy(	T *			pR,
								const S *	pA,
								uint32 len )
{
	while( len-- > 0 )
		*pR++ *= *pA++;
}

template <class T, class S>
__inline void		vectScl(	T *			pR,
								S			s,
								uint32		len )
{
	while( len-- > 0 )
		*pR++ *= s;
}

template <class T>
__inline T		vectDotProd(	const T	*	pA,		
								const T	*	pB,
								uint32		len	)
{
	T	r( 0.f );
	while( len-- > 0 )
		r += *pA++ * *pB++;
	return r;
}

template <class T>
__inline T		vectDotProd(	const T	*	pA,
								uint32		stepA,
								const T	*	pB,
								uint32		len	)
{
	T	r( 0.f );
	while( len-- > 0 ){
		r += *pA * *pB++;
		pA += stepA;
	}
	return r;
}

template <class T>
__inline float	vectSumSq(		const T	*	pA,
								uint32		len	)
{
	float	r = 0.f;
	while( len-- > 0 )
		r += ( *pA++ ).norm2();
	return r;
}

__inline void	vectOsc(		fcomp *			pR,
								Osc *			pOsc,
								uint32			len		 )
{
	while( len-- > 0 )
		*pR++ = compOsc( pOsc );
}

__inline void	vectOsc(		fcomp *			pR,
								Osc *			pOsc,
								uint32			len,
								float			s		)
{
	while( len-- > 0 )
		*pR++ = compOsc( pOsc ) * s;
}


__inline void	vectHeterd(		fcomp *			pR,
								Osc *			pOsc,
								uint32			len		)
{
	while( len-- > 0 )
		*pR++ *= compOsc( pOsc );
}




#endif //#ifndef _VECT_H_



