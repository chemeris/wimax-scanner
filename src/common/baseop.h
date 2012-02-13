/****************************************************************************/
/*! \file		baseop.h
	\brief		Base operations
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	1.0
     
	Base operations for floating point math.
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

#ifndef _BASEOP_H_
#define _BASEOP_H_

#include "comdefs.h"


/******************************************************************************
// Useful mathematical constants in float format
******************************************************************************/

#define MF_E        2.71828182845904523536f			// e
#define MF_LOG2E    1.44269504088896340736f			// log2(e)
#define MF_LOG10E   0.434294481903251827651f		// log10(e)
#define MF_LN2      0.693147180559945309417f		// ln(2)
#define MF_LN10     2.30258509299404568402f			// ln(10)
#define MF_PI       3.14159265358979323846f			// pi
#define MF_2PI      6.28318530717958647692f			// 2*pi
#define MF_PI_2     1.57079632679489661923f			// pi/2
#define MF_PI_4     0.785398163397448309616f		// pi/4
#define MF_1_PI     0.318309886183790671538f		// 1/pi
#define MF_2_PI     0.636619772367581343076f		// 2/pi
#define MF_2_SQRTPI 1.12837916709551257390f			// 2/sqrt(pi)
#define MF_SQRT2    1.41421356237309504880f			// sqrt(2)
#define MF_SQRT1_2  0.707106781186547524401f		// 1/sqrt(2)



/*****************************************************************************
External types
*****************************************************************************/

//! 1-st order float IIR filter
struct Iir1 {
	float		b0;		//!< b0
	float		b1;		//!< b1
	float		a1;		//!< -a1
	float		xnm1;	//!< X[n-1]
	float		ynm1;	//!< Y[n-1]
};

//! Oscillator internal structure
struct Osc {
	float		cph;	//!< current phase, -pi to +pi  
	float		dlt;	//!< delta phase = Pi*Ft/Fs, -pi to +pi
};


/******************************************************************************
Static external functions
******************************************************************************/

template< class T >
__inline T	_max( T	a,	T	b )
{
	return ( a > b ) ? a : b;
}

template< class T >
__inline T	_min( T	a,	T	b )
{
	return ( a < b ) ? a : b;
}

template< class T >
__inline T	limit( T	a,	T	l,	T	h )
{
	ASSERT( l <  h );
	return getMax( getMin( a, h ), l );
}

__inline int32	round( float a )
{
	return (int32)floor( a + 0.5f );
}


__inline float sq( float a )
{
	return a*a;
}

template< class T >
__inline T	cyclInc( T	a,	T	max )
{
	a++;
	if( a == max )
		a = 0;
	return a;
}

__inline float	lin2db( float a )
{
	return 20.f*log10f( a+FLT_EPSILON  );
}

__inline float	db2lin( float a )
{
	return 	powf( 10.f, a / 20.f );
}

//! Exponent, number of left shift to normalize value 
__inline int _norm (int val )
{
	int res=0;
	if ( val == 0 )
		return 0; // maximal shift
	while ( ( val ^ (val<<1) ) > 0 ) { // MSB == MSB-1
		val<<=1;
		res++;
	}
	return res;
}

//! Nonzero bit counter
__inline uint16	countBit( uint16 a )
{
	uint16	r = 0;
	while( a ) {
		r += a & 0x01;
		a >>= 1;
	}
	return r;
}

//! Parity generation
__inline uint16	genParity( uint16 a )
{
	uint16	r = 0;
	while( a ) {
		r ^= a;
		a >>= 1;
	}
	return r & 0x01;
}

//! Bit reversing
__inline uint16	bitRev( uint16 a, uint16 n )
{
	uint16	r = 0;
	for( int i = 0; i < n; i++ )
		r |= ( ( a >> i ) & 0x01 ) << ( n-i-1 );
	return r;
}


__inline uint8 bin2gray( uint8 a )
{
	return a ^ (a>>1);
}


__inline float avrg( float old, float nw, float ncoef )
{
	if( old == 0.f )
		return nw;
	return nw*ncoef + old*(1.f-ncoef);
}

__inline void iirFilt( float * pY, float x, float b, float a )
{
	float	t;
	t  = *pY * a;
	t +=  x  * b;
	*pY = t;
}

__inline float iirFilt1( Iir1 * pIir, int16 x )
{
	float	t;
	t  = pIir->ynm1 * pIir->a1;
	t += x			* pIir->b0;
	t += pIir->xnm1 * pIir->b1;
	pIir->ynm1 = t;
	pIir->xnm1 = x;
	return t;
}



__inline float	normPhi	( float phi )
{
	while( phi >  MF_PI )
		phi -= MF_2PI;
	while( phi <= -MF_PI )
		phi += MF_2PI;
	return phi;
}

__inline float sinOsc( Osc * pOsc )
{
	pOsc->cph = normPhi( pOsc->cph + pOsc->dlt );
	return sinf( pOsc->cph ) ;
}

__inline fcomp	compOsc( Osc * pOsc )
{
	pOsc->cph = normPhi( pOsc->cph + pOsc->dlt );
	fcomp	res( cosf( pOsc->cph ), sinf( pOsc->cph ) );
	return res;
}


//! Find interpolated maximum position, square interpolation by 3 point  
/*!	X = -1, 0, +1, Y = y(X-1), y(X0), y(X+1)
	c = y(X0); 
	b = (y(X+1)-y(X-1))/2;
	a  = (y(X+1)+y(X-1))/2-y(X0);
	xm = -b/2a = 0.5*(y(X-1)-y(X+1))/(y(X-1)-2*y(X0)+y(X+1));
*/
__inline float findMax3(	const float y[3]	)
{
	return 0.5f*(y[0]-y[2])/(y[0]-2.0f*y[1]+y[2]);
}

//! Find more precise DFT frequency by two near amplitudes  
/*!	1-st amplitude A1 = B*cos(pi/2*d), 2-nd amplitude A2 = B*cos(pi/2(1-d))
	phi is A1 to B difference, sinc is approximated with cos
	A1/A2=sin(pi/2*d)/sin(pi/2(1-d))
	d = 2/pi*arcctg( A1/A2 )
	Œ œŒ¬€ÿ≈Õ»» “Œ◊ÕŒ—“» —œ≈ “–¿À‹ÕŒ√Œ ¿Õ¿À»«¿ œ≈–»Œƒ»◊≈— »’ —»√Õ¿ÀŒ¬ 
	œ–» ƒ»— –≈“ÕŒÃ œ–≈Œ¡–¿«Œ¬¿Õ»» ‘”–‹≈. ≈Ù‡ÌÓ‚ ¬.Ã.
*/
__inline float precDftFreq(	float a0, float a1	)
{
	return MF_2_PI*atanf( a1 / a0 );
}



//! CRC-CCITT X^16+X^12+X^5+1 calculation
/*	Init state 0xFFFF, MSB first
	Checkout CRC 0x29B1 for string "123456789" = 0x31,0x32...0x39
*/
__inline uint16 crcCcitt(	uint8 * pBit,	uint16	len	)
{
	const static uint16		crcCcittPoly = 0x1021;
	uint16	i, reg = 0xFFFF;
	for( i = 0; i < len; i++ ) {
		reg ^= ( (uint16)*pBit++ & 0x01 ) << 15;
		if ((reg & 0x8000)) {
			reg <<= 1;
			reg ^= crcCcittPoly;
		} else {
			reg <<= 1;
		}

	}
	return reg;
}


//! Generate CRC32
/*	Generator polynomial G(x)=x^32+x^26+x^23+x^22+x^16+x^12+x^11+x^10+x^8+x^7+x^5+x^4+x^2+x+1
	or 0x04c11db7 in hexadecimal, initial register value is 0xFFFFFFFF, CRC is inverted.
	For 0x40, 0x40, 0x1A, 0x06, 0xC4, 0x5A, 0xBC, 0xF6, 0x57, 0x21, 0xE7, 0x55, 0x36, 0xC8, 0x27, 0xA8, 0xD7, 0x1B, 0x43, 0x2C, 0xA5, 0x48
	Generated CRC is 0x1B, 0xD1, 0xBA, 0x21; MSB first
*/
__inline void	genCrc32(	uint8 * pBit,	uint16	msgLen	)
{
	const static uint32		crcPoly = 0x04c11db7;
	uint32	i, reg = 0xFFFFFFFFUL;
	for( i = 0; i < msgLen; i++ ) {
		reg ^= ( (uint32)*pBit++ & 0x01 ) << 31;
		if( reg & 0x80000000UL ) {
			reg <<= 1;
			reg ^= crcPoly;
		} else {
			reg <<= 1;
		}

	}
	reg = ~reg;
	for( i = 0; i < 32; i++ ) {
		*pBit++ = reg >> 31;
		reg <<= 1;
	}
}

//! CRC32 calculation
/*	Check reminder G(x)=x^31+x^30+x^26+x^25+x^24+x^18+x^15+x^14+x^12+x^11+x^10+x^8+x^6+x^5+x^4+x^3+x+1
	or 0xC704DD7B in hexadecimal, initial register value is 0xFFFFFFFF.
*/
__inline bool	chkCrc32IsOk(	const uint8 * pBit,	uint16	len	)
{
	const static uint32		crcPoly = 0x04c11db7;
	const static uint32		crcChk = 0xC704DD7B;
	uint32	i, reg = 0xFFFFFFFFUL;
	for( i = 0; i < len; i++ ) {
		reg ^= ( (uint32)*pBit++ & 0x01 ) << 31;
		if( reg & 0x80000000UL ) {
			reg <<= 1;
			reg ^= crcPoly;
		} else {
			reg <<= 1;
		}

	}
	return ( reg == crcChk );
}




#endif //#ifndef _BASEOP_H_



