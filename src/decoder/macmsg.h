/****************************************************************************/
/*! \file		macmsg.h
	\brief		MAC message format
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	MAC message format, 
	implements IEEE Std 802.16-2009, 6.3.2 MAC PDU formats
	including physical layer specific.

*/
/*****************************************************************************/


#ifndef _MACMSG_H_
#define _MACMSG_H_

#include "comdefs.h"
#include "global.h"




//!< MAC management messages, Table 38—MAC management messages 
enum MsgType {
	MSG_UCD,					//!< UCD
	MSG_DCD,					//!< DCD
	MSG_DLMAP,					//!< DL-MAP
	MSG_ULMAP,					//!< UL-MAP

	MSG_NOCOM = 0x0,			//!< Normal DL-MAP/UL-MAP - HT=0, EC=0
	MSG_COMPR = 0x3,			//!< Compressed DL-MAP/UL-MAP - 2 MSB of normal message type

	MSG_COMPR_DLMAP = 0x0,		//!< Compressed DL-MAP - 1 LSB
	MSG_SUB_DL_UL_MAP			//!< SUB-DL-UL-MAP - 1 LSB
};


/*****************************************************************************
DL-MAP
*****************************************************************************/

//! DIUC code, including 
enum Diuc {
	// DIUC code, Table 322—OFDMA DIUC values
	DIUC_GAP_PARP = 13,			//!< Gap PARP DUIC
	DIUC_EXT2,					//!< Extended-2 DIUC
	DIUC_EXT,					//!< Extended DIUC
	// Extended DIUC code, Table 324—Extended DIUC code assignment for DIUC = 15 
	DIUC_E_CHAN_MEAS,			//!< Channel Measurement IE
	DIUC_E_STC_ZONE,			//!< STC Zone IE
	DIUC_E_AAS_DL,				//!< AAS DL IE
	DIUC_E_LOC_ANOTH,			//!< Data Location in Another BS IE
	DIUC_E_CID_SWITCH,			//!< CID Switch IE
	DIUC_E_CID_RES1,			//!< reserved
	DIUC_E_CID_RES2,			//!< reserved
	DIUC_E_HARQ_MAP,			//!< HARQ Map Pointer IE
	DIUC_E_PHYMOD_DL,			//!< PHYMOD DL IE
	DIUC_E_CID_RES3,			//!< reserved
	DIUC_E_BCAST_CTRL,			//!< Broadcast Control Pointer IE
	DIUC_E_DP_ALLOC_OTHER,		//!< DL PUSC Burst Allocation in Other Segment IE
	DIUC_E_PASCA_ALLOC,			//!< PUSC ASCA ALLOC IE
	DIUC_E_HFDD_GRP,			//!< H-FDD Group Switch IE
	DIUC_E_EXT_BCAST_CTRL,		//!< Extended Broadcast Control Pointer IE
	DIUC_E_UL_INTF_NOISE,		//!< UL Interference and Noise Level IE
	// Extended-2 DIUC code, Table 326—Extended-2 DIUC code assignment for DIUC = 14 
	DIUC_E2_MBS_MAP,			//!< MBS MAP IE
	DIUC_E2_HO_ANCH_ACT,		//!< HO Anchor Active DL MAP IE
	DIUC_E2_HO_ACT_ANCH,		//!< HO Active Anchor DL MAP IE
	DIUC_E2_HO_CID_TRANSL,		//!< HO CID Translation MAP IE
	DIUC_E2_MIMO_ANOTH,			//!< MIMO in Another BS IE
	DIUC_E2_MMIMO_BASIC,		//!< Macro-MIMO DL Basic IE
	DIUC_E2_SKIP,				//!< Skip IE
	DIUC_E2_HARQ_DLMAP,			//!< HARQ DL MAP IE
	DIUC_E2_HARQ_ACK,			//!< HARQ ACK IE
	DIUC_E2_ENH_DLMAP,			//!< Enhanced DL MAP IE
	DIUC_E2_CLOOP_MIMO_ENH,		//!< Closed-loop MIMO DL Enhanced IE
	DIUC_E2_MIMO_BASIC,			//!< MIMO DL Basic IE
	DIUC_E2_MIMO_ENH,			//!< MIMO DL Enhanced IE
	DIUC_E2_PHARQ_DLMAP,		//!< Persistent HARQ DL MAP IE
	DIUC_E2_AAS_SDMA,			//!< AAS SDMA DL IE
	DIUC_E2_EXT3,				//!< Extended-3 DIUC
	// Extended-3 DIUC code, Table 328—Extended-3 DIUC code assignment for Extended-2 DIUC = 15 
	DIUC_E3_PWR_BOOST,			//!< Power Boosting IE

	DIUC_E_FIRST = DIUC_E_CHAN_MEAS,	//!< First Extended DIUC
	DIUC_E2_FIRST = DIUC_E2_MBS_MAP,	//!< First Extended-2 DIUC
	DIUC_E3_FIRST = DIUC_E3_PWR_BOOST,	//!< First Extended-3 DIUC
};



/*****************************************************************************
Particular IE of DL-MAP
*****************************************************************************/

const int		dlmapMaxCid = 256;		//!< Max number of CIDs in IE of DL-MAP/UL-MAP

struct DlmapIeProf {
	int				numCid;			//!< number of CIDs
	int				aCid[dlmapMaxCid];	//!< CIDs
	BurstParam		param;			//!< burst params
};


struct DlmapIeStcDlzone {
	int				offs;			//!< start of zone offset
	Zone			zone;			//!< permutation zone
	bool			useAllSc;		//!< use all SC
	int				stc;			//!< STC
	int				matrix;			//!< matrix
	int				dlPermBase;		//!< DL permutation base
	int				prbsId;			//!< PRBS ID
	int				amcType;		//!< AMC type
	bool			isMidambPres;	//!< is MIMO midamble present at the first symbol in STC
	bool			isMidambBoost;	//!< is midamble boosting 3 dB
	bool			is3Ant;			//!< is 3 antennas, 2 otherwise
	bool			isDedicPilot;	//!< is Dedicated Pilots
};



//! Sync field, Table 319—OFDMA PHY Synchronization Field
struct DlmapOfdmaSync {
	int				frmDur;			//!< Frame Duration Code - 8 bit
	int				frmNum;			//!< Frame Number - 24 bit
};



//! DL-MAP IE, Table 321—OFDMA DL-MAP IE format
struct DlmapOfdmaIe {
	Diuc			diuc;			//!< DIUC
	union {
		DlmapIeProf			burstProf;		//!< Different burst profiles for DIUC 0-12
		DlmapIeStcDlzone	stcDlZone;		//!< STC Zone IE
	} b;
};

const int		dlmapMaxIe = 256;		//!< Max number of IEs in DL-MAP/UL-MAP

//!  DL-MAP format, currently Compressed only, Table 431—Compressed DL-MAP message format
struct DlmapMsg {
	bool			isCompr;		//!< is compressed DL-MAP
	bool			isUlmapApp;		//!< is UL-MAP appended - 1 bit
	bool			isPartChang;	//!< is FDD partition change - 1 bit
	int				msgLen;			//!< MAP message length - 11 bit
	int				cid;			//!< CID
	DlmapOfdmaSync	sync;			//!< PHY Synchronization Field variable See appropriate PHY specification.
	int				dcdCount;		//!< DCD Count - 8 bit
	int				operId;			//!< Operator ID - 8/24 bit
	int				sectId;			//!< Sector ID - 8/24 bit
	int				numSym;			//!< No. OFDMA symbols - 8 bit For TDD, the number of OFDMA symbols in the DL subframe including all AAS/permutation z one and including the preamble. For FDD, see 8.4.4.2.2.
	int				ieCount;		//!< DL IE count - 8 bit
	DlmapOfdmaIe	aIe[dlmapMaxIe];	//!< Information elements - DL-MAP_IE() variable See corresponding PHY specification.
};




#endif //#ifndef _MACMSG_H_


