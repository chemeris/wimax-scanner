/****************************************************************************/
/*! \file		ieparser.cpp
	\brief		IE parser
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	IE parser, 
	implements IEEE Std 802.16-2009, 8.4.5 Map message fields and IEs
	and 8.4.4.4 DL frame prefix

	TODO:
	2. Compressed DL-MAP is implemented with very restricted set of IEs.
	2. Noncompressed DL-MAP is implemented but not tested.

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

#include "ieparser.h"
#include "baseop.h"

#ifndef WIN32
#define INVALID_SOCKET (-1)
#endif



/*****************************************************************************
External static constants 
*****************************************************************************/






/******************************************************************************
External functions
******************************************************************************/

IeParser::IeParser()
{
	openSock();
}


IeParser::~IeParser()
{
	closeSock();
}


const FchMsg *		IeParser::parseFch(	const BurstData *	pData	)
{
	int		i;
	const uint8 *	pBit = pData->pBit;

	//Debug::print( "FCH", pData->pBit, pData->len );
	if( ( pData->len != fchLen*2 )							||
		( memcmp( &pBit[0], &pBit[fchLen], fchLen ) != 0 )     )
		return NULL;

	sendPack( GSMTAP_WIMAX_FCH, pData->pBit, pData->len/2 );

	bool	isUsed = false;
	for( i = 0; i < dpGroupNum; i++ ) {
		fch.aIsSchGrpUsed[i] = ( *pBit++ != 0 );
		if( fch.aIsSchGrpUsed[i] )
			isUsed = true;
	}
	if( !isUsed ) // ignore FCH with all groups disabled
		return NULL;
	pBit++; // reserved
	fch.dlmapRepeat = (RepeatType)packBit( &pBit, 2 );
	fch.dlmapFec = (FecType)packBit( &pBit, 3 );
	if( fch.dlmapFec > FEC_LDPC )
		return NULL;
	fch.dlmapLen = packBit( &pBit, 8 );
	return &fch;
}



const DlmapMsg *	IeParser::parseDlmap(	const BurstData *	pData	)
{
	int				i, htEc;
	const uint8 *	pBit = pData->pBit;

	isIncCid = false;
	sendPack( GSMTAP_WIMAX_PDU, pData->pBit, pData->len );

	if( ( htEc = packBit( &pBit, 2 ) ) == MSG_COMPR ) { // compressed 
		if( packBit( &pBit, 1 ) != MSG_COMPR_DLMAP )
			return NULL;
		if( pData->len < 88 ) // Compressed DL-MAP header size
			return NULL;
		parseCdlmapHdr( &pBit );
		if( ! chkCrc32IsOk( pData->pBit, dlmap.msgLen*8 ) )
			return NULL;
		for( i = 0; i < dlmap.ieCount; i++ )
			parseDlmapIe( &pBit, i );
	} else { // normal
		if( ( htEc != MSG_NOCOM )				||
			( packBit( &pBit, 6 ) != MSG_DLMAP )  )
			return NULL;
		if( pData->len < 152 ) // General MAC plus DL-MAP header size
			return NULL;
		parseDlmapHdr( &pBit );
		if( ! chkCrc32IsOk( pData->pBit, dlmap.msgLen*8 ) )
			return NULL;
		const uint8 *	pEnd = pData->pBit + dlmap.msgLen*8 - 4;
		while( pBit < pEnd )
			parseDlmapIe( &pBit, dlmap.ieCount++ );
	}

	return &dlmap;
}




/*****************************************************************************
Internal static constants
*****************************************************************************/


const gsmtap_hdr		IeParser::defGsmtapHdr = {
	GSMTAP_VERSION,				// version;        /* version, set to 0x01 currently */
    sizeof(gsmtap_hdr)/sizeof(int32),	// hdr_len;        /* length in number of 32bit words */
    GSMTAP_TYPE_WIMAX,			// type;           /* see GSMTAP_TYPE_* */
    1,							// timeslot;       /* timeslot (0..7 on Um) */
    0x0100,						// arfcn; - in network byte order   /* ARFCN (frequency) */
    1,							// signal_dbm;     /* signal level in dBm */
    1,							// snr_db;         /* signal/noise ratio in dB */
	0,							// frame_number;   /* GSM Frame Number (FN) */
    GSMTAP_WIMAX_FCH,			// sub_type;       /* Type of burst/channel, see above */
    1,							// antenna_nr;     /* Antenna Number */
	1,							// sub_slot;       /* sub-slot within timeslot */
	0							// res;            /* reserved for future use (RFU) */
};



/******************************************************************************
Internal functions
******************************************************************************/


void			IeParser::parseDlmapHdr(	const uint8 * *		ppBit	)
{
	dlmap.isCompr		= false;
	*ppBit += 1; // reserved
	packBit( ppBit, 1 ); // CI
	packBit( ppBit, 2 ); // EKS
	*ppBit += 1; // reserved
	dlmap.msgLen		= packBit( ppBit, 11 );
	dlmap.cid			= packBit( ppBit, 16 );
	packBit( ppBit, 8 ); // HCS
	dlmap.isUlmapApp	= false; // not used
	dlmap.isPartChang	= false; // not used
	dlmap.sync.frmDur	= packBit( ppBit, 8  );
	dlmap.sync.frmNum	= packBit( ppBit, 24 );
	dlmap.dcdCount		= packBit( ppBit, 8  );
	dlmap.operId		= packBit( ppBit, 24  );
	dlmap.sectId		= packBit( ppBit, 24  );
	dlmap.numSym		= packBit( ppBit, 8  );
	dlmap.ieCount		= 0;
}

void			IeParser::parseCdlmapHdr(	const uint8 * *		ppBit	)
{
	dlmap.isCompr		= true;
	dlmap.isUlmapApp	= packBit( ppBit, 1 ) != 0;
	dlmap.isPartChang	= packBit( ppBit, 1 ) != 0;
	dlmap.msgLen		= packBit( ppBit, 11 );
	dlmap.cid			= 0; // not used
	dlmap.sync.frmDur	= packBit( ppBit, 8  );
	dlmap.sync.frmNum	= packBit( ppBit, 24 );
	dlmap.dcdCount		= packBit( ppBit, 8  );
	dlmap.operId		= packBit( ppBit, 8  );
	dlmap.sectId		= packBit( ppBit, 8  );
	dlmap.numSym		= packBit( ppBit, 8  );
	dlmap.ieCount		= packBit( ppBit, 8  );
}



void			IeParser::parseDlmapIe(	const uint8 * *		ppBit,
										int					ieNum	)
{
	Diuc			diuc; 

	diuc = (Diuc)packBit( ppBit, 4 );
	if( diuc == DIUC_EXT ) { // Extended
		diuc = (Diuc)(packBit( ppBit, 4 ) + DIUC_E_FIRST);
		parseExtIe( diuc, ppBit, &dlmap.aIe[ieNum] );
	} else if( diuc == DIUC_EXT2 ) {
			diuc = (Diuc)(packBit( ppBit, 4 ) + DIUC_E_FIRST);
		if( diuc == DIUC_E2_EXT3 ) { // Extended-3
			diuc = (Diuc)(packBit( ppBit, 4 ) + DIUC_E3_FIRST);
			parseExt3Ie( diuc, ppBit, &dlmap.aIe[ieNum] );
		} else { // Extended-2
			parseExt2Ie( diuc, ppBit, &dlmap.aIe[ieNum] );
		}
	} else { // Profiles or Gap/PAPR
		parseProfGapIe( diuc, ppBit, &dlmap.aIe[ieNum] );
	}
	dlmap.aIe[ieNum].diuc = diuc;
}



void			IeParser::parseProfGapIe(	Diuc				diuc,
											const uint8 * *		ppBit,
											DlmapOfdmaIe *		pIe		)
{
	if( diuc != DIUC_GAP_PARP ) { // Different burst profiles
		DlmapIeProf &	prof = pIe->b.burstProf;
		if( isIncCid ) {
			prof.numCid = packBit( ppBit, 8 );
			for( int i = 0; i < prof.numCid; i++ )
				prof.aCid[i] = packBit( ppBit, 16 );
		} else {
			prof.numCid = 0;
		}
		BurstParam &	param = pIe->b.burstProf.param;
		param.fstTs  = packBit( ppBit, 8 ); // OFDMA Symbol offset
		// if(Permutation = 0b11 and (AMC type is 2x3 or 1x6)) {
		param.fstSch = packBit( ppBit, 6 ); // Subchannel offset
		param.boost  = (Boosting)packBit( ppBit, 3 ); // Boosting
		param.lstTs  = param.fstTs  + packBit( ppBit, 7 ); // No. OFDMA Symbols
		param.lstSch = param.fstSch + packBit( ppBit, 6 ); // No. Subchannels
		param.repeat = (RepeatType)packBit( ppBit, 2 ); // Repetition Coding Indication
		param.shape  = SHAPE_RECT;
		param.modul  = (ModulType)0; // should be extracted from DCD
		param.fec    = (FecType)0; // should be extracted from DCD
		param.rate   = (FecRate)0; // should be extracted from DCD
		param.isFch  = false;
		// }
	} else { // Gap/PAPR reduction
		// not yet impelemented
	}
}

void			IeParser::parseExtIe(		Diuc				diuc,
											const uint8 * *		ppBit,
											DlmapOfdmaIe *		pIe		)
{
	int		len = packBit( ppBit, 4 );
	switch( diuc ) {
		case DIUC_E_STC_ZONE:			// STC Zone IE
			pIe->b.stcDlZone.offs			= packBit( ppBit, 8 );			// OFDMA symbol offset
			pIe->b.stcDlZone.zone			= (Zone)packBit( ppBit, 2 );	// Permutation
			pIe->b.stcDlZone.useAllSc		= packBit( ppBit, 1 )!=0;		// use all SC
			pIe->b.stcDlZone.stc			= packBit( ppBit, 2 );			// STC
			pIe->b.stcDlZone.matrix			= packBit( ppBit, 2 );			// matrix indicator
			pIe->b.stcDlZone.dlPermBase		= packBit( ppBit, 5 );			// DL permutation base
			pIe->b.stcDlZone.prbsId			= packBit( ppBit, 2 );			// PRBS ID
			pIe->b.stcDlZone.amcType		= packBit( ppBit, 2 );			// AMC type
			pIe->b.stcDlZone.isMidambPres	= packBit( ppBit, 1 )!=0;		// is MIMO midamble present at the first symbol in STC
			pIe->b.stcDlZone.isMidambBoost	= packBit( ppBit, 1 )!=0;		// is midamble boosting 3 dB
			pIe->b.stcDlZone.is3Ant			= packBit( ppBit, 1 )!=0;		// is 3 antennas, 2 otherwise
			pIe->b.stcDlZone.isDedicPilot	= packBit( ppBit, 1 )!=0;		// is Dedicated Pilots
			*ppBit += 4;
			break;
		case DIUC_E_CHAN_MEAS:			// Channel Measurement IE
		case DIUC_E_AAS_DL:				// AAS DL IE
		case DIUC_E_LOC_ANOTH:			// Data Location in Another BS IE
		case DIUC_E_CID_SWITCH:			// CID Switch IE
		case DIUC_E_HARQ_MAP:			// HARQ Map Pointer IE
		case DIUC_E_PHYMOD_DL:			// PHYMOD DL IE
		case DIUC_E_BCAST_CTRL:			// Broadcast Control Pointer IE
		case DIUC_E_DP_ALLOC_OTHER:		// DL PUSC Burst Allocation in Other Segment IE
		case DIUC_E_PASCA_ALLOC:		// PUSC ASCA ALLOC IE
		case DIUC_E_HFDD_GRP:			// H-FDD Group Switch IE
		case DIUC_E_EXT_BCAST_CTRL:		// Extended Broadcast Control Pointer IE
		case DIUC_E_UL_INTF_NOISE:		// UL Interference and Noise Level IE
			// not yet impelemented
			*ppBit += len*8;
			break;
		default:
			break;
	}
}

void			IeParser::parseExt2Ie(		Diuc				diuc,
											const uint8 * *		ppBit,
											DlmapOfdmaIe *		pIe		)
{
	int		len = packBit( ppBit, 8 );

	switch( diuc ) {
		case DIUC_E2_MBS_MAP:			// MBS MAP IE
		case DIUC_E2_HO_ANCH_ACT:		// HO Anchor Active DL MAP IE
		case DIUC_E2_HO_ACT_ANCH:		// HO Active Anchor DL MAP IE
		case DIUC_E2_HO_CID_TRANSL:		// HO CID Translation MAP IE
		case DIUC_E2_MIMO_ANOTH:		// MIMO in Another BS IE
		case DIUC_E2_MMIMO_BASIC:		// Macro-MIMO DL Basic IE
		case DIUC_E2_SKIP:				// Skip IE
		case DIUC_E2_HARQ_DLMAP:		// HARQ DL MAP IE
		case DIUC_E2_HARQ_ACK:			// HARQ ACK IE
		case DIUC_E2_ENH_DLMAP:			// Enhanced DL MAP IE
		case DIUC_E2_CLOOP_MIMO_ENH:	// Closed-loop MIMO DL Enhanced IE
		case DIUC_E2_MIMO_BASIC:		// MIMO DL Basic IE
		case DIUC_E2_MIMO_ENH:			// MIMO DL Enhanced IE
		case DIUC_E2_PHARQ_DLMAP:		// Persistent HARQ DL MAP IE
		case DIUC_E2_AAS_SDMA:			// AAS SDMA DL IE
			// not yet impelemented
			*ppBit += len*8;
			break;
		default:
			break;
	}
}

void			IeParser::parseExt3Ie(		Diuc				diuc,
											const uint8 * *		ppBit,
											DlmapOfdmaIe *		pIe		)
{
	int		len = packBit( ppBit, 8 ) - 4;

	switch( diuc ) {
		case DIUC_E3_PWR_BOOST:			// Power Boosting IE
			// not yet implemented
			*ppBit += len*8;
			break;
		default:
			break;
	}
}

void			IeParser::openSock()
{
#ifdef WIN32
	WORD wVersionRequested = MAKEWORD(2, 2);
    WSADATA wsaData;
    WSAStartup(wVersionRequested, &wsaData);
#endif

	wsharkSock = socket( PF_INET, SOCK_DGRAM, IPPROTO_UDP );
	if( wsharkSock == INVALID_SOCKET ) {
#ifdef WIN32
		printf( "!!! Can not open Wireshark Socket\n" ); 
		int err = WSAGetLastError();
	    WSACleanup();
#endif
		return;
	}


	memset(&wsharkAddr, 0, sizeof(wsharkAddr));
	wsharkAddr.sin_family = AF_INET;
#ifdef WIN32
	wsharkAddr.sin_addr.s_addr = inet_addr( "192.168.1.1" ); // it must be present
#else
	wsharkAddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
#endif
	wsharkAddr.sin_port = htons( GSMTAP_UDP_PORT );

	frmCntr = 0;
}

void			IeParser::closeSock()
{
	if( wsharkSock == INVALID_SOCKET )
		return;
#ifdef WIN32
	closesocket( wsharkSock );
	WSACleanup();
#else
	close( wsharkSock );
#endif
}

void			IeParser::sendPack(		uint8			subType,
										const uint8 *	pBit,
										int				lenBit		)
{
	if( wsharkSock == INVALID_SOCKET )
		return;

	gsmtap_hdr		hdr = defGsmtapHdr;
	if( subType == GSMTAP_WIMAX_FCH )
		frmCntr++;
	hdr.sub_type = subType;
	hdr.frame_number = htonl( frmCntr );

	static const int	maxLen = 256;
	static const int	hdrLen = sizeof(hdr);
	uint8	aData[maxLen+hdrLen];
	int		len = _min( (lenBit+7)>>3, maxLen );
	memcpy( aData, &hdr, hdrLen );
	for( int i = 0; i < len; i++ )
		aData[i+hdrLen] = packBit( &pBit, 8 );
	aData[len+hdrLen-1] <<= len*8 - lenBit; // align MSB 
	sendto(	wsharkSock,		(const char *)&aData,	len+hdrLen,			0,
			(struct sockaddr *)&wsharkAddr,			sizeof(wsharkAddr)			);
}
