/*
	WiMax receiver simple testbench
*/
#include <stdio.h>
#include "wimax_dem.h"
#include "CIC_flt.h"
#if 1
#define INPUT_BLOCK_SIZE (2048+128*2) /* sizeof block (number of "short"*/
#else
#define INPUT_BLOCK_SIZE (2048)			/* sizeof block (number of "short"*/
#endif

#ifdef WIN32
#include "getopt_msvc.h"
#include <winsock.h>
#define	DEFAULT_IP_ADDT "192.168.1.1"
#else
#include <unistd.h>
#include <arpa/inet.h>
#define	DEFAULT_IP_ADDT "127.0.0.1"
#endif



//! Command arguments values
struct ArgVal {
	VerbMode 		verbMode;		//!< verbosity mode
	unsigned long 	wsharkIp;		//!< wireshark IP address
	FILE *			pInFile;		//!< input file
};



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



void		printRes(		Decoder::ProcRes		procRes,
							const Decoder::DecRes *	pDecRes,
							int						frmCntr		)
{
	printf( "***** Frame %i decoding result: %s *****\n", frmCntr, getVerbProcRes( procRes ) );
	if( procRes > Decoder::PROC_RES_FCH_FAIL )
		printFch( &pDecRes->fchMsg );
	if( procRes > Decoder::PROC_RES_DLMAP_FAIL )
		printDlmap( &pDecRes->dlmapMsg );
}


//! Parse command arguments and open input file, return NULL if error
static const ArgVal *		parseArg(	int argc,				//!< standard main argument
										char *argv[]	);		//!< standard main argument



int main( int argc, char *argv[] )
{
//	fprintf(stderr, "\nbuild time = %s \n", __TIME__);

	const ArgVal *	pArg;

	pArg = parseArg( argc, argv );
	if( pArg == NULL ) {
		printf( 
			"This command run Wimax decoder\n"
			"wimax [-vN] [-iXXX.XXX.XXX.XXX] infile.ext\n"
			"    -vN - verbosity mode: 0 - silent, 1 - brief, 2 - full; default - brief\n"
			"    -iXXX.XXX.XXX.XXX - Wiresharc IPv4 addres; default - " DEFAULT_IP_ADDT "\n"
			"    infile.ext - input complex sample file\n"
			);
		exit( EXIT_FAILURE );
	} 

	tWiMax_Dem		dem( pArg->verbMode, pArg->wsharkIp ); 
	tWiMax_Status	status; 

	int16_t in_data[INPUT_BLOCK_SIZE]; 
	int j=0, i=0, k = 0; 
	while( fread(in_data, sizeof(in_data[0]), INPUT_BLOCK_SIZE, pArg->pInFile )==INPUT_BLOCK_SIZE)//for (j=0; j<25; j++)
	{
//		int16_t *pin = in_data; 
		dem.GetSamples((Complex <int16_t> *)in_data, INPUT_BLOCK_SIZE/2, &status);
		if( ( pArg->verbMode == VERB_FULL ) && ( status.pDecRes != NULL ) )	{
			printRes( status.procRes, status.pDecRes, 4 );
		}
	}

	fclose( pArg->pInFile );
	return 0;
}



const ArgVal *		parseArg(	int argc,
								char *argv[]	)
{
	static ArgVal	argVal;
	int				t;
	const char *	pIpTxt = DEFAULT_IP_ADDT;
	char			c;
	argVal.verbMode = VERB_BRIEF;

	opterr = 0;
	while ( (c = getopt (argc, argv, "v:i:")) != -1 )
		switch (c) {
			case 'v':
				t = atoi( optarg );
				if( ( t < VERB_SILENT ) || ( t > VERB_FULL ) )
					return NULL;
				argVal.verbMode = (VerbMode)t;
				break;
			case 'i':
				pIpTxt = optarg;
				break;
			case '?':
			default:
				return NULL;
		}
	argVal.wsharkIp = inet_addr( pIpTxt );
	if( argVal.wsharkIp == INADDR_NONE )
		return NULL;

	if( optind != argc-1 )
		return NULL;
	argVal.pInFile = fopen( argv[optind], "rb" );
	if( argVal.pInFile == NULL ) {
		fprintf(stderr, "!!! Can't open input file %s", argv[optind] ); 
		return NULL;
	}
	printf( "Decode samples from file %s, verbosity %d, Wirwshark IP %s\n",
		argv[optind], argVal.verbMode, pIpTxt );
	return &argVal;
}
