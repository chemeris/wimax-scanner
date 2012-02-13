/****************************************************************************/
/*! \file		comtypes.h
	\brief		Common types
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	1.0
     
  Common types, defines and handy functions.
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


#ifndef _COMDEFS_H_
#define _COMDEFS_H_


#ifdef _DEBUG
#include <assert.h>
#endif
#include <string.h>
#include <ctype.h> 
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <limits.h>


#include <math.h>
#include <float.h>

#ifdef __cplusplus

#include "complex.h"
//#include <complex>

#endif


/*****************************************************************************
Project config
*****************************************************************************/

typedef enum VerbMode {
	VERB_SILENT,	//! Verbosity Silent - only fatal error
	VERB_BRIEF,		//! Verbosity Brief - fatal error and important message
	VERB_FULL		//! Verbosity Full - full information
} VerbMode;

//! Verbosity mode
#define VERB_MODE VERB_BRIEF


// Check platform
#if defined WIN32
//#elif defined __LINUX__
#elif defined __GNUC__
#else
#error Unknown platform, WIN32 and UNIX are supported only
#endif

/*****************************************************************************
Common types
*****************************************************************************/

typedef long long int		int64;
typedef unsigned long long	uint64;
typedef long long int		int40;
typedef int					int32;
typedef unsigned int		uint32;
typedef short int 			int16;
typedef unsigned short int 	uint16;
typedef signed char			int8;
typedef unsigned char		uint8;

#if( !defined( __cplusplus ) &&  !defined( bool ) && !defined( false ) && !defined( true ) )
typedef int16 bool;
#define false 0
#define true 1
#endif


#ifdef __cplusplus
//! Complex signal samples type
//typedef std::complex<float> fcomp;
typedef Complex<float> fcomp;
#endif


//! Real signal samples
typedef float freal;


//! Failure, not found etc designator
#define FAIL (-1)


//! Array size
#define ARRAY_SZ( x ) (int)(sizeof(x)/sizeof(x[0]))


/*****************************************************************************
                        Language-dependent definitions
*****************************************************************************/

#undef ASSERT
#ifdef _DEBUG
	#define ASSERT(x)  assert(x)
#else
	#define ASSERT(_ignore)  ((void)0)
#endif


#ifdef __cplusplus
#define EXTERN_C extern "C"
#else
#define EXTERN_C extern
#endif

#define INLINE __inline


//! Print error message and exit program with failude code
__inline void	PRINTF_EXIT	(	const char * pFormat,		//!< format string
								...						)	//!< other arguments
{
	va_list arg_list;
	va_start( arg_list, pFormat);
	printf( pFormat, arg_list);
	va_end( arg_list);
	exit( EXIT_FAILURE );
}


//! copy no more then n-1 symbols and att terminating zero
__inline void STRNCPY( char * s1, const char * s2, size_t n )
{
	strncpy( s1, s2, n-1 );
	s1[n-1]='\0';
}

//! convert string to lower case (platform independant)
__inline void TOLOWER( char * s )
{
	for(	; *s != '\0'; s++ )
		*s = tolower( *s );
}




#ifdef __cplusplus

#include "debug.h"

#endif





#endif //#ifndef _COMDEFS_H_



