/****************************************************************************/
/*! \file		debug.cpp
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

#include "debug.h"
#include "baseop.h"


/*****************************************************************************
Static constant external variables
*****************************************************************************/



/******************************************************************************
Static external functions
******************************************************************************/


void			Debug::print(	const char *	msg		)
{
	fprintf( log, "%s\n", msg );
}

void			Debug::print(	const char *	msg,
								int				val		)
{
	fprintf( log, "%s %i\n", msg, val );
}

void			Debug::print(	const char *	msg,
								freal			val		)
{
	print( msg, &val, 1 );
}
void			Debug::print(	const char *	msg,
								freal			val1,
								freal			val2	)
{
	fprintf( log, "%s % .6f, % .6f, \n", msg, val1, val2 );
}
void			Debug::print(	const char *	msg,
								freal			val1,
								freal			val2,
								freal			val3	)
{
	fprintf( log, "%s % .6f, % .6f, % .6f, \n", msg, val1, val2, val3 );
}
void			Debug::print(	const char *	msg,
								fcomp			cval	)
{
	print( msg, &cval, 1 );
}

void			Debug::print(	const char *	msg,
								const float *	pVal,
								int				len		)
{
	fprintf( log, "%s ", msg );
	if( len >= 4 )
		fprintf( log, "\n" );
	for( int i = 0; i < len; i++ ) {
		fprintf( log, "% .6f, ", *pVal++ );
		if( ( i & 0x07 ) == 0x07 )
			fprintf( log, "\n" );
	}
	if( ( len & 0x07 ) != 0x00 )
		fprintf( log, "\n" );
}

void			Debug::print(	const char *	msg,
								const fcomp	*	pCval,
								int				len		)
{
	fprintf( log, "%s ", msg );
	if( len >= 4 )
		fprintf( log, "\n" );
	for( int i = 0; i < len; i++ ) {
		fprintf( log, "% .6f%+.6fi, ", pCval->real(), pCval->imag() );
		if( ( i & 0x03 ) == 0x03 )
			fprintf( log, "\n" );
		pCval++;
	}
	if( ( len & 0x03 ) != 0x00 )
		fprintf( log, "\n" );
}

void			Debug::print(	const char *	msg,
								const uint8 *	pVal,
								int				len		)
{
	fprintf( log, "%s ", msg );
	if( len >= 8 )
		fprintf( log, "\n" );
	for( int i = 0; i < len; i++ ) {
		fprintf( log, "%01X, ", (int)*pVal++ );
		if( ( i & 0x03 ) == 0x03 )
			fprintf( log, " " );
		if( ( i & 0x0F ) == 0x0F )
			fprintf( log, "\n" );
	}
	if( ( len & 0x0F ) != 0x00 )
		fprintf( log, "\n" );
}




void			Debug::plot(	const char *	pName,
								const freal *	pVal, 
								int				len,
								int				step	)
{
#ifdef WIN32
	if( ! pMl )
		return;

	Graph *		pGraph = findByName( pName );
	if( pGraph == NULL ) {
		pGraph = allocNew( pName );
		if( pGraph == NULL ) {
			printf("!!! Can not allocate new graph\n");
		}
		updCmd();
	}

	// put new values
	while( len-- > 0 ) {
		pGraph->pMlVal[pGraph->ind] = (double)*pVal;
		pGraph->ind = cyclInc( pGraph->ind, arraySz );
		pVal += step;
	}
/*
	this->updCntr += len;
	if( this->updCntr < this->updInt )
		return;

	// time to update plot
	this->updCntr = 0;
*/
#endif
}

void			Debug::plot(	const char *	pName,
								freal			val		)
{
#ifdef WIN32
	if( ! pMl )
		return;

	plot( pName, &val, 1, 1 );
#endif
}

void			Debug::plotUpd()
{
#ifdef WIN32

	if( ! pMl )
		return;

	for( int i = 0; i < numGraph; i++ )
		if( aGraph[i].aName[0] != '\0' )
			engPutVariable( pMl, aGraph[i].aName,  aGraph[i].pMlArr ); // Update used MatLab variables

	engEvalString( pMl, "figure(hplot);" );
	engEvalString( pMl, aPlotCmd  ); // Plot all variables
	engEvalString( pMl, aLegCmd  );
#endif
}




/******************************************************************************
External functions
******************************************************************************/


Debug::Debug(	bool			iMlUsed,
				const char *	fname		)
{
	log = fopen( fname, "wt" );
	if( ! iMlUsed )
		return;

#ifdef WIN32
	int			i;
	Graph		* pGraph;

	pMl = engOpen("\0"); // Connect to MatLab on local machine
	if( pMl == NULL ) { // MatLab is not connected
		printf( "!!! Can not establish connection to MatLab\n" );
		exit( EXIT_FAILURE );
	}

	for( i = 0, pGraph = aGraph; i < numGraph; i++, pGraph++ ) {
		pGraph->aName[0] = '\0'; // empty graph name
		pGraph->ind = 0;
/*
		strcpy( pVis->aName, pDescr->pName );
		n = sprintf( pVis->aFigure, "figure(%d);", (int)(i+1)   );
		ASSERT( n < PARSE_NAME_SZ );
		n = sprintf( pVis->aPlot,   "plot(%s,'%c');", pVis->aName, pMlColor[i%VIS_ML_COLOR_NUM] );
		ASSERT( n < PARSE_NAME_SZ );
		n = sprintf( pVis->aTitle,  "title('%s');", pVis->aName );
		ASSERT( n < PARSE_NAME_SZ );
		for( j = 0; j < strlen( pVis->aTitle ); j++ )
		if( pVis->aTitle[j] == '_' ) // '_' meand subscript in matlab
		pVis->aTitle[j] = '-';
*/
		pGraph->pMlArr = mxCreateDoubleMatrix( 1, arraySz, mxREAL);  // Create variable
		if ( pGraph->pMlArr != NULL ) {
			pGraph->pMlVal  = (double *) mxGetPr( pGraph->pMlArr);
			if ( pGraph->pMlVal == NULL )
				printf("!!! Can not get access to MatLab array\n" );
		} else {
			pGraph->pMlVal = NULL;
			printf("!!! Can not create MatLab array\n");
		}
		if( pGraph->pMlVal ) {
			memset( pGraph->pMlVal, 0, arraySz*sizeof(double) );
			engPutVariable( pMl, pGraph->aName,  pGraph->pMlArr ); // Update MatLab variable
		}

	}
	engEvalString ( pMl, "close all;" );
	engEvalString ( pMl, "hplot = figure();" );
#endif
}



Debug::~Debug()
{
#ifdef WIN32
	fclose( log );
	if( pMl ) {
		plotUpd();
		for( int i = 0; i < numGraph; i++ ) {
			if ( aGraph[i].pMlArr != NULL )  // destroy only actually created arrays
				mxDestroyArray( aGraph[i].pMlArr );
		}
	}
#endif
}




/*****************************************************************************
Static constant internal variables
*****************************************************************************/

	FILE *			Debug::log;

#ifdef WIN32
	Engine *		Debug::pMl;
	Debug::Graph	Debug::aGraph[numGraph];
	//int			Debug::updCntr = 0;
	//int			Debug::updInt = 0;
	char			Debug::aPlotCmd[strSz];
	char			Debug::aLegCmd[strSz];

	const char *	Debug::pMlColor = "bgrcmyk";
#endif

/******************************************************************************
Internal functions
******************************************************************************/

#ifdef WIN32
Debug::Graph *		Debug::findByName(	const char *	pName )
{
	for( int i = 0; i < numGraph; i++ )
		if( strncmp( pName, aGraph[i].aName, nameSz ) == 0 )
			return &aGraph[i];
	return NULL;
}

Debug::Graph *		Debug::allocNew( const char *		pName )
{
	int		i;

	for( i = 0; i < numGraph; i++ )		// find empty graph
		if( aGraph[i].aName[0] == '\0' )
			break;
	if( i >= numGraph )		// no empty graph
		return NULL;

	// empty graph is found
	STRNCPY( aGraph[i].aName, pName, nameSz );
	return &aGraph[i];
}

//! Update commands after adding new variable
void				Debug::updCmd()
{
	char *			pStr, *	pEnd;
	int				i, len, n;
	Graph *			pGraph;

	// plot command
	pStr = &aPlotCmd[0];
	pEnd = &aPlotCmd[strSz-2]; // reserv space for 1 character
	strcpy( pStr, "plot(" );
	len = strlen( pStr );
	pStr += len;
	for( i = 0, pGraph = aGraph; i < numGraph; i++, pGraph++ ) {
		if( pGraph->aName[0] == '\0' )
			continue;
		n = pEnd - pStr;
		len = _snprintf( pStr, n, "1:%d,%s,'%c.-',", (int)arraySz, pGraph->aName, pMlColor[i] );
		assert( ( len > 0 ) && ( len < n ) );
		pStr += len;
	}
	pStr--; // remove tailing ','
	strcpy( pStr, ");" );

	// legend command
	pStr = &aLegCmd[0];
	pEnd = &aLegCmd[strSz-2]; // reserv space for 1 character
    strcpy( pStr, "legend(" );
	len = strlen( pStr );
	pStr += len;
	for( i = 0, pGraph = aGraph; i < numGraph; i++, pGraph++ ) {
		if( pGraph->aName[0] == '\0' )
			continue;
		n = pEnd - pStr;
		len = _snprintf( pStr, n, "'%s',", pGraph->aName );
		assert( ( len > 0 ) && ( len < n ) );
		pStr += len;
	}
	pStr--; // remove tailing ','
	strcpy( pStr, ");" );
}

#endif



#if 0
//! Plot eye diagram
/*! Plot eye diagram of 4 complex samples per symbol
	New 4 complex samples are put to circular buffer of 16 samples, then
	whole buffer is plotted.
	\param	pCarr		pointer to complex array, format [0].re, [0].im, [1].re ... [3].im
*/
void eyeDiag4( const short	  * pCarr )
{
static mxArray		  * pEyeArr;
static double		  * pEyeRe, * pEyeIm;
	int		i;

	if( pEyeArr == NULL ) { // called first time
		pEyeArr = mxCreateDoubleMatrix( MATLAB_EYE_LEN*MATLAB_EYE_NUM+1, 1, mxCOMPLEX);  // Create variable
		if( pEyeArr != NULL ) {
			pEyeRe = (double *) mxGetPr(pEyeArr);
			pEyeIm = (double *) mxGetPi(pEyeArr);
			if( ( pEyeRe == NULL ) || ( pEyeIm == NULL ) )
				printf("Can not get access to MatLab array\n" );
		} else {
			pEyeIm = pEyeRe = NULL;
			printf("Can not create MatLab array\n");
		}
		if( ( pEyeRe ) && ( pEyeRe ) ) {
			memset( pEyeRe, 0, MATLAB_EYE_LEN*MATLAB_EYE_NUM*sizeof(double) );
			memset( pEyeIm, 0, MATLAB_EYE_LEN*MATLAB_EYE_NUM*sizeof(double) );
			engPutVariable( matlab.pMl, "eyedg",  pEyeArr ); // Update MatLab variable
		}
		engEvalString ( matlab.pMl, "eyedgh = eyediagram(eyedg,4,1,2,'-');" );
	}

	memcpy( &pEyeRe[0], &pEyeRe[MATLAB_EYE_LEN],
			((MATLAB_EYE_NUM-1)*MATLAB_EYE_LEN+1)*sizeof(double)	);
	memcpy( &pEyeIm[0], &pEyeIm[MATLAB_EYE_LEN],
			((MATLAB_EYE_NUM-1)*MATLAB_EYE_LEN+1)*sizeof(double)	);
	for( i = 0; i < MATLAB_EYE_LEN; i++ ) {
		pEyeRe[i+(MATLAB_EYE_NUM-1)*MATLAB_EYE_LEN+1] = pCarr[i*2  ];
		pEyeIm[i+(MATLAB_EYE_NUM-1)*MATLAB_EYE_LEN+1] = pCarr[i*2+1];
	}
	engPutVariable( matlab.pMl, "eyedg",  pEyeArr ); // Update MatLab variable
	engEvalString( matlab.pMl, "eyediagram(eyedg,4,1,2,'-',eyedgh);" );
}


//! Plot constellation diagram
/*! Plot constellation diagram
	New complex sample is put to circular buffer of 33 samples, then
	whole buffer is plotted. 
	The newest samples are show with red color, oldest - with blue.
	\param	pComp		pointer to complex value, format re, im
*/
extern void constDiag(	const float	  * pComp ) {

static mxArray		  * pArrRe = NULL, * pArrIm = NULL;
static double		  * pCstRe, * pCstIm;


	if( ( pArrRe == NULL ) || ( pArrIm == NULL ) ) { // called first time
		pArrRe = mxCreateDoubleMatrix( MATLAB_CST_LEN+1, 1, mxREAL);
		pArrIm = mxCreateDoubleMatrix( MATLAB_CST_LEN+1, 1, mxREAL);
		if( ( pArrRe != NULL ) && ( pArrIm != NULL ) ) {
			pCstRe = (double *) mxGetPr(pArrRe);
			pCstIm = (double *) mxGetPr(pArrIm);
			if( ( pCstRe == NULL ) || ( pCstIm == NULL ) )
				printf("Can not get access to MatLab array\n" );
		} else {
			pCstIm = pCstRe = NULL;
			printf("Can not create MatLab array\n");
		}
		if( ( pCstRe ) && ( pCstRe ) ) {
			memset( pCstRe, 0, (MATLAB_CST_LEN+1)*sizeof(double) );
			memset( pCstIm, 0, (MATLAB_CST_LEN+1)*sizeof(double) );
			engPutVariable( matlab.pMl, "cstdgre",  pArrRe );
			engPutVariable( matlab.pMl, "cstdgim",  pArrIm );
		}
		engEvalString( matlab.pMl, "hcst = figure();" );
		engEvalString( matlab.pMl, "scatter(cstdgre,cstdgim,4,1:33);" );
		engEvalString( matlab.pMl, "axis([-1.5 1.5 -1.5 1.5]);" );
	}

	memcpy( &pCstRe[0], &pCstRe[1],	MATLAB_CST_LEN*sizeof(double)	);
	pCstRe[MATLAB_CST_LEN] = pComp[0];
	engPutVariable( matlab.pMl, "cstdgre",  pArrRe );
	memcpy( &pCstIm[0], &pCstIm[1],	MATLAB_CST_LEN*sizeof(double)	);
	pCstIm[MATLAB_CST_LEN] = pComp[1];
	engPutVariable( matlab.pMl, "cstdgim",  pArrIm  );
	engEvalString( matlab.pMl, "figure(hcst);" );
	engEvalString( matlab.pMl, "scatter(cstdgre,cstdgim,4,1:33);" );
	engEvalString( matlab.pMl, "axis([-1.5 1.5 -1.5 1.5]);" );
}
#endif



