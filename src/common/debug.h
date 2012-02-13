/****************************************************************************/
/*! \file		debug.h
	\brief		Debug module
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Debug printf and MATLAB plot functions.

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

#ifndef _DEBUG_H_
#define _DEBUG_H_

#include "comdefs.h"

#ifdef WIN32
#include "matlab/engine.h"
#endif


class Debug {

public:

/*****************************************************************************
External types nad static constants
*****************************************************************************/




/******************************************************************************
External functions
******************************************************************************/


	//! Print message
	static void			print(	const char *	msg		);
	//! Print single integer value
	static void			print(	const char *	msg,
								int				val		);
	//! Print single real value
	static void			print(	const char *	msg,
								freal			val		);
	//! Print two real values
	static void			print(	const char *	msg,
								freal			val1,
								freal			val2	);
	//! Print three real values
	static void			print(	const char *	msg,
								freal			val1,
								freal			val2,
								freal			val3	);
	//! Print single complex value
	static void			print(	const char *	msg,
								fcomp			cval	);
	//! Print array of real values
	static void			print(	const char *	msg,
								const freal *	pVal,
								int				len		);
	//! Print array of complex values
	static void			print(	const char *	msg,
								const fcomp	*	pCval,
								int				len		);
	//! Print array of bits
	static void			print(	const char *	msg,
								const uint8 *	pVal,
								int				len		);

	//! Plot array of real values
	static void			plot(	const char *	pName,
								const freal *	pVal, 
								int				len,
								int				step = 1 );
	//! Plot single real value
	static void			plot(	const char *	pName,
								freal			val		);
	//! Plot update
	static void			plotUpd();

#if 0
	void			plotEyeDiag4(	const short	  * pCarr );
	void			plotConstDiag(	const float	  * pComp );
#endif


	Debug(	bool			iMlUsed = false,		//!< is MatLab used for plot
			const char *	fname = "debug.dat" );	//!< debug file name
	~Debug();



private:

/*****************************************************************************
Internal types and static constants
*****************************************************************************/

	static const int	nameSz = 64;	//!< Variable name size

#ifdef WIN32
	static const int	numGraph = 4;	//!< Number of graphs at plot
	static const int	strSz = nameSz*numGraph; //!< String size
	static const int	arraySz = 1024;	//!< Matlab array size		

	static const char *	pMlColor;		//!< Drawing color

	//! Graph
	struct Graph {
		char		aName[nameSz];		//!< MatLab variable name
		mxArray *	pMlArr;				//!< Pointer to MatLab array object
		double *	pMlVal;				//!< Pointer to value of MatLab array
		int			ind;				//!< Index in MatLab array
		// char		aFigure[strSz];		//!< MatLab figure command
		// char		aTitle [strSz];		//!< MatLab title command
	};
#endif

/*****************************************************************************
Internal variables
*****************************************************************************/

	static FILE *			log;					//!< debug print text file

#ifdef WIN32

	static Engine *			pMl;					//!< MatLab engine handle
	static Graph			aGraph[numGraph];		//!< graphs
	//static int			updCntr;				//!< added element counter before update
	//static int			updInt;					//!< update interval in elements 
	static char				aPlotCmd[strSz];		//!< plot graph command
	static char				aLegCmd[strSz];			//!< print legend command
#endif


#if 0
#define MATLAB_COLOR_NUM 7//!< Drawing color number

//!< Dot per eye diagram
#define MATLAB_EYE_LEN 4

//!< Number of eye traces in array
#define MATLAB_EYE_NUM 8

//!< Number points on constellation
#define MATLAB_CST_LEN 32
#endif



/******************************************************************************
Internal functions
******************************************************************************/

#ifdef WIN32
	//! Find graph by name
	static Graph *		findByName(	const char *	pName );

	//! Allocate new graph
	static Graph *		allocNew( const char *		pName );

	//! Update commands after adding new variable
	static void			updCmd();
#endif

};



#endif //#ifndef _DEBUG_H_


