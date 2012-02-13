/****************************************************************************/
/*! \file		tbench.c
	\brief		Test bench for WIMAX scanner
	\author		Iliya D. Voronov, iliya.voronov@gmail.com
	\version	1.0
     
  Test bench for WIMAX scanner.
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

#include "comdefs.h"
#include "decoder.h"
#include "debug.h"


const int		maxStrSz = 256;

const int		fftSz = 1024;





//! Read preamble index from input file, return FAILURE on read error
static int		readIndex(		FILE *		pSbitFile );	//!< input soft bits file

//! Read symbol samples and channel estimation from input file, return FFT size or FAILURE on read error
static int		readSymChan(	FILE *		pSbitFile,		//!< input soft bits file
								fcomp *		pSym,			//!< output samples
								fcomp *		pChan	);		//!< output channel estimation

//! Print results
static void		printRes(		Decoder::ProcRes			procRes,		//!< processing result
								const Decoder::DecRes *	pDecRes,		//!< decoding result
								int						frmCntr		);	//!< frame counter

int main()
{
	const char *	pSbitFname = "softbits.txt";
    FILE *			pSbitFile;
	int				symCntr;
	int				frmCntr = 0;
	fcomp			aSym[fftSz];
	fcomp			aChEst[fftSz];
	int				index;
	Decoder::ProcRes		procRes;
	const Decoder::DecRes *	pDecRes;

	Debug	debug( false );

	pSbitFile = fopen( pSbitFname, "rt" );
	if( ! pSbitFile )
		PRINTF_EXIT( "!!! Can not open file %s for read\n", pSbitFname );

	Decoder	decoder( fftSz );

	while( ( index = readIndex( pSbitFile ) ) != FAIL ) {
		symCntr = 0;
		decoder.startNewFrm( index );
		while( readSymChan( pSbitFile, aSym, aChEst ) == fftSz ) {
			symCntr++;
			if( symCntr <= 4 )
				procRes = decoder.procSym( aSym, aChEst );
			if( symCntr == 4 )
				break;
		}
		pDecRes = decoder.getDecRes();
		printRes( procRes, pDecRes, frmCntr );
		frmCntr++;
	}
}







int		readIndex(		FILE *		pSbitFile )
{
	char	aStr[maxStrSz];
	int		t;

	if( ( fscanf( pSbitFile, "%s", aStr ) != 1 ) ||
		( strcmp( aStr, "frameNumber" ) != 0 )		)
		return FAIL;
	if( ( fscanf( pSbitFile, "%i", &t ) != 1 ) ||
		( t > 100 )								  )
		return FAIL;
	if( ( fscanf( pSbitFile, "%s", aStr ) != 1 ) ||
		( strcmp( aStr, "preambleIndex" ) != 0 )	)
		return FAIL;
	if( ( fscanf( pSbitFile, "%i", &t ) != 1 ) ||
		( t < 0 ) || ( t > 113 )					  )
		return FAIL;
	return t;
}


int		readSymChan(	FILE *		pSbitFile,
						fcomp *		pSym,
						fcomp *		pChan	)
{
	const int	numPerStr = 4;
	char	aStr[maxStrSz];
	int		fftSz, fftSz1;

	if( ( fscanf( pSbitFile, "%s", aStr ) != 1 ) ||
		( strcmp( aStr, "symbol" ) != 0 )	)
		return FAIL;
	fftSz = 0;
	while( fscanf( pSbitFile, " (%f%fi), (%f%fi), (%f%fi), (%f%fi),",
				&pSym[0].r, &pSym[0].i, &pSym[1].r, &pSym[1].i,
				&pSym[2].r, &pSym[2].i, &pSym[3].r, &pSym[3].i		) == numPerStr*2 ) {
		pSym += numPerStr;
		fftSz += numPerStr;
	}

	if( ( fscanf( pSbitFile, "%s", aStr ) != 1 ) ||
		( strcmp( aStr, "channel" ) != 0 )	)
		return FAIL;
	fftSz1 = 0;
	while( fscanf( pSbitFile, " (%f%fi), (%f%fi), (%f%fi), (%f%fi),",
				&pChan[0].r, &pChan[0].i, &pChan[1].r, &pChan[1].i,
				&pChan[2].r, &pChan[2].i, &pChan[3].r, &pChan[3].i	) == numPerStr*2 ) {
		pChan += numPerStr;
		fftSz1 += numPerStr;
	}
	if( fftSz != fftSz1 )
		return FAIL;

	pChan -= fftSz;
	for( int i = 0; i < fftSz; i++ ) {
		*pChan = pChan->conj();
		pChan++;
	}
	return fftSz;
}

/***** Print result funsions *****/

static const char *		getVerbProcRes( Decoder::ProcRes			procRes	)
{
	const static char *	apGoodRes[] = {
		"Partly decoded",
		"Decoded"
	};
	const static char *	apFailRes[] = {
		"FCH fail",
		"DL-MAP fail"
	};
	if( procRes >= Decoder::PROC_RES_WAIT ) {
		ASSERT( procRes < ARRAY_SZ( apGoodRes ) );
		return apGoodRes[procRes];
	} else {
		ASSERT( procRes-Decoder::PROC_RES_FCH_FAIL < ARRAY_SZ( apFailRes ) );
		return apFailRes[procRes-Decoder::PROC_RES_FCH_FAIL];
	}
}

static const char *		apVerbCode[] = {
	"CC", "BTC", "CTC",	"ZT_CC", "CC_woi", "LDPC"
};

void		printFch(		const FchMsg * pFch )
{
	printf( "FCH used subch: " );
	for( int i = 0; i < dpGroupNum; i++ )
		printf( "%i", pFch->aIsSchGrpUsed[i] );
	printf( ", DL_MAP repeat: %i, ", ( pFch->dlmapRepeat != 0 ) ? pFch->dlmapRepeat*2 : 1 );
	ASSERT( pFch->dlmapFec < ARRAY_SZ( apVerbCode ) );
	printf( "code: %s, ", apVerbCode[pFch->dlmapFec] );
	printf( "len: %i\n", pFch->dlmapLen );
}


const static float		aDlmapFrmDur[] = { -1.f, 2.f, 2.5f, 4.f, 5.f, 8.f, 10.f, 12.5f };

const static char *		apDlmapDiucVerb[] = {
	"Profile 0",							
	"Profile 1",							
	"Profile 2",							
	"Profile 3",							
	"Profile 4",							
	"Profile 5",							
	"Profile 6",							
	"Profile 7",							
	"Profile 8",							
	"Profile 9",							
	"Profile A",							
	"Profile B",							
	"Profile C",							
	"Gap PARP DUIC",							// DIUC_GAP_PARP,		
	"Extended-2 DIUC",							// DIUC_EXT2,				
	"Extended DIUC",							// DIUC_EXT,				
	"Channel Measurement",						// DIUC_E_CHAN_MEAS,		
	"STC Zone",									// DIUC_E_STC_ZONE,		
	"AAS DL",									// DIUC_E_AAS_DL,			
	"Data Location in Another BS",				// DIUC_E_LOC_ANOTH,		
	"CID Switch",								// DIUC_E_CID_SWITCH,		
	"!!! reserved",								// DIUC_E_CID_RES1,		
	"!!! reserved",								// DIUC_E_CID_RES2,		
	"HARQ Map Pointer",							// DIUC_E_HARQ_MAP,		
	"PHYMOD DL",								// DIUC_E_PHYMOD_DL,		
	"!!! reserved",								// DIUC_E_CID_RES3,		
	"Broadcast Control Pointer",				// DIUC_E_BCAST_CTRL,		
	"DL PUSC Burst Alloc in Other Segm",		// DIUC_E_DP_ALLOC_OTHER,	
	"PUSC ASCA ALLOC",							// DIUC_E_PASCA_ALLOC,		
	"H-FDD Group Switch",						// DIUC_E_HFDD_GRP,		
	"Extended Broadcast Control Pointer",		// DIUC_E_EXT_BCAST_CTRL,	
	"UL Interference and Noise Level",			// DIUC_E_UL_INTF_NOISE,	
	"MBS MAP",									// DIUC_E2_MBS_MAP,		
	"HO Anchor Active DL MAP",					// DIUC_E2_HO_ANCH_ACT,	
	"HO Active Anchor DL MAP",					// DIUC_E2_HO_ACT_ANCH,	
	"HO CID Translation MAP",					// DIUC_E2_HO_CID_TRANSL,	
	"MIMO in Another BS",						// DIUC_E2_MIMO_ANOTH,		
	"Macro-MIMO DL Basic",						// DIUC_E2_MMIMO_BASIC,	
	"Skip",										// DIUC_E2_SKIP,			
	"HARQ DL MAP",								// DIUC_E2_HARQ_DLMAP,		
	"HARQ ACK",									// DIUC_E2_HARQ_ACK,		
	"Enhanced DL MAP",							// DIUC_E2_ENH_DLMAP,		
	"Closed-loop MIMO DL Enhanced",				// DIUC_E2_CLOOP_MIMO_ENH,	
	"MIMO DL Basic",							// DIUC_E2_MIMO_BASIC,		
	"MIMO DL Enhanced",							// DIUC_E2_MIMO_ENH,		
	"Persistent HARQ DL MAP",					// DIUC_E2_PHARQ_DLMAP,	
	"AAS SDMA DL",								// DIUC_E2_AAS_SDMA,		
	"Extended-3 DIUC",							// DIUC_E2_EXT3,
	"Power Boosting IE"							// DIUC_E3_PWR_BOOST
};



void		printDlmap(		const DlmapMsg * pDlmap )
{
	printf( "DLMAP Compressed: %s, UL-MAP appended: %s, FDD partition changed: %s\n", 
		pDlmap->isCompr ? "yes" : "no", 
		pDlmap->isUlmapApp ? "yes" : "no", 
		pDlmap->isUlmapApp ? "yes" : "no" );
	printf( " MAP message len: %i, Sync frame duration: %3.1f ms, frame number: %i\n",
		pDlmap->msgLen, aDlmapFrmDur[pDlmap->sync.frmDur], pDlmap->sync.frmNum );
	printf( " DCD count: %i, Operator ID: %i, Sector ID: %i, Number OFDMA symbols: %i\n",
		pDlmap->dcdCount, pDlmap->operId, pDlmap->sectId, pDlmap->numSym );
	for( int i = 0; i < pDlmap->ieCount; i++ ) {
		printf( "IE DIUC: %s\n",
			apDlmapDiucVerb[ pDlmap->aIe[i].diuc ] );
	}
}



void		printRes(		Decoder::ProcRes			procRes,
							const Decoder::DecRes *	pDecRes,
							int						frmCntr		)
{
	printf( "***** Frame %i decoding result: %s *****\n", frmCntr, getVerbProcRes( procRes ) );
	if( procRes > Decoder::PROC_RES_FCH_FAIL )
		printFch( &pDecRes->fchMsg );
	if( procRes > Decoder::PROC_RES_DLMAP_FAIL )
		printDlmap( &pDecRes->dlmapMsg );
}
