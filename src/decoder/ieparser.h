/****************************************************************************/
/*! \file		ieparser.h
	\brief		IE parser
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	IE parser, 
	implements IEEE Std 802.16-2009, 8.4.5 Map message fields and IEs
	and 8.4.4.4 DL frame prefix

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

#ifndef _IEPARSER_H_
#define _IEPARSER_H_

#ifdef WIN32
#include <winsock.h>
#else
#include <sys/socket.h>
#include <netinet/in.h>
typedef int SOCKET;
#endif

#include "comdefs.h"
#include "global.h"
#include "macmsg.h"
#include "gsmtap.h"

class IeParser {


public:

/*****************************************************************************
External types and static constants 
*****************************************************************************/



/******************************************************************************
External functions
******************************************************************************/

	IeParser(	unsigned long 	wsharkIp	);		//!< Wirwshark IP address


	~IeParser();


	//! Parse FCH data, return  FCH data or NULL if inconsistent
	const FchMsg *		parseFch(	const BurstData *	pData	);		//!< input data

	//! Parse DL-MAP data, return  DL-MAP data or NULL if inconsistent
	const DlmapMsg *	parseDlmap(	const BurstData *	pData	);		//!< input data


private:




/*****************************************************************************
Internal types and static constants
*****************************************************************************/

	static const int			fchLen = 24;		//!< FCH length
	static const int			minDlmapLen = 96;	//!< min DL-MAP length
	static const gsmtap_hdr		defGsmtapHdr;		//!< default GSM TAP header


/*****************************************************************************
Internal variables
*****************************************************************************/

	unsigned long 	wsharkIp;			//!< wireshark IP address

	bool			isIncCid;			//!< is include CID, toggled by CID-SWITCH_IE

	SOCKET			wsharkSock;			//!< wireshark socket
//	struct sockaddr_in wsharkAddr;		//!< wireshark address
	sockaddr_in		wsharkAddr;		//!< wireshark address
	int				frmCntr;			//!< frame counter	

	FchMsg			fch;				//!< FCH data
	DlmapMsg		dlmap;				//!< DL-MAP data

/******************************************************************************
Internal functions
******************************************************************************/

	//! Parse DL-MAP header, from CI to No OFDMA symbols
	void			parseDlmapHdr(	const uint8 * *		ppBit	);	//!< input bits
	//! Parse Compressed DL-MAP header, from UL-MAP appended to DL IE count
	void			parseCdlmapHdr(	const uint8 * *		ppBit	);	//!< input bits
	//! Parse DL-MAP IE header
	void			parseDlmapIe(	const uint8 * *		ppBit,		//!< input bits
									int					ieNum	);	//!< IE number

	//! Parse DL-MAP Burst profiles and Gap/PAPR reduction IE 
	void			parseProfGapIe(	Diuc				diuc,		//!< DIUC
									const uint8 * *		ppBit,		//!< input bits
									DlmapOfdmaIe *		pIe	);		//!< output IE
	//! Parse DL-MAP Extended IE 
	void			parseExtIe(		Diuc				diuc,		//!< DIUC
									const uint8 * *		ppBit,		//!< input bits
									DlmapOfdmaIe *		pIe	);		//!< output IE
	//! Parse DL-MAP Extended-2 IE 
	void			parseExt2Ie(	Diuc				diuc,		//!< DIUC
									const uint8 * *		ppBit,		//!< input bits
									DlmapOfdmaIe *		pIe	);		//!< output IE
	//! Parse DL-MAP Extended-3 IE 
	void			parseExt3Ie(	Diuc				diuc,		//!< DIUC
									const uint8 * *		ppBit,		//!< input bits
									DlmapOfdmaIe *		pIe	);		//!< output IE

	

	//! Open wireshark socket for burst capture
	void			openSock(		unsigned long 		wsharkIp	);

	//! Close wireshark socket 
	void			closeSock();

	//! Send data burst to wireshark
	void			sendPack(		uint8				subType,		//!< burst subtype
									const uint8 *		pBit,			//!< burst bits
									int					len		);		//!< bit lenght



};



#endif //#ifndef _IEPARSER_H_


