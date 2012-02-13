/****************************************************************************/
/*! \file		global.h
	\brief		Global WIMAX defines
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Global WIMAX defines, tables, utility functions etc.

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

#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#include "comdefs.h"


/*****************************************************************************
Generale constants
*****************************************************************************/

/********** DL PUSC specific **********/
const int		dpGroupNum = 6;			//!< major groups number for DL PUSC
const int		dpScarPerSch = 24;		//!< subcarriers per subchannel
const int		dpMaxSchNum = 30;		//!< max subchannel number //// FFT11024
const int		dpMaxUsedScarNum = 841;	//!< max used subcarrier number //// FFT11024
const int		dpMaxSchScarNum = 720;	//!< max data sucarriers number //// FFT11024


const int		maxPreamIndex = 114;	//!< max preamble index
const int		maxSymPerTs = 3;		//!< max symbols per timeslot at single subcarrier
const int		maxUsedScarNum = dpMaxUsedScarNum;	//!< max used subcarrier number, including pilots and DC //// FFT 1024, PUSC
const int		maxSchScarNum = dpMaxSchScarNum;	//!< max data sucarriers number in all subchannels //// FFT11024, PUSC

const int		maxBitPerSym = 6;		//!< max number of bits per subchannel symbol
const int		maxBurstPerFrm = 64;	//!< max number of bursts per frame
const int		maxTsPerFrm = 44;		//!< max number of timeslots per frame
const int		maxSlotPerFrm = dpMaxSchNum * maxSymPerTs * maxTsPerFrm;	//!< max number of slots per frame //// FFT11024, PUSC

const int		maxScarPerSch = dpScarPerSch;		//!< max subcarrier per subchannel //// FFT11024, PUSC
const int		symPerSlot = 48;		//!< symbol per slot for all carrier of subchannel
const int		fchSzSl = 4;			//!< FCH size in slots
const int		maxConcSz = 10;			//!< max slot concatenation size



//! FFT types enum
enum FftEnum {
//	FFT_ENUM_128,			//!< 128
//	FFT_ENUM_512,			//!< 512
	FFT_ENUM_1024,			//!< 1024
//	FFT_ENUM_2048,			//!< 2048
	FFT_ENUM_NUM			//!< number of FFT enums
};

//! Subchannel allocation zone
enum Zone {
	ZONE_DL_PUSC,			//!< down linn PUSC zone
	ZONE_DL_FUSC,			//!< down link FUSC zone
	ZONE_AMC,				//!< down/up link AMC zone
	ZONE_DL_OPT_FUSC,		//!< down link optional permutation FUSC zone
//	ZONE_UL_PUSC,			//!< up link PUSC zone
	ZONE_NUM				//!< number of zone types
};


//! Repeat Type
enum RepeatType {
	REPEAT_1,				//!< No repetition
	REPEAT_2,				//!< Repetition of 2
	REPEAT_4,				//!< Repetition of 4
	REPEAT_6,				//!< Repetition of 6
	REPEAT_NUM				//!< number of repetition types
};

//! Modulation type
enum ModulType {
	MODUL_QPSK,				//!< QPSK
	MODUL_16QAM,			//!< 16 QAM
	MODUL_64QAM,			//!< 64 QAM
	MODUL_NUM				//!< number of modulation types
};

//! FEC type
enum FecType {
	FEC_CC,					//!< convolution code
	FEC_BTC,				//!< block turbo code
	FEC_CTC,				//!< convolution turbo code
	FEC_ZT_CC,				//!< zero terminated convolution code
	FEC_CC_WI,				//!< convolution code with optional interleaver
	FEC_LDPC,				//!< low density parity check
	FEC_TYPE_NUM			//!< number of FEC types
};

//! FEC rate
enum FecRate {
	FEC_1_2,				//!< rate 1/2
	FEC_2_3,				//!< rate 2/3
	FEC_3_4,				//!< rate 3/4
	FEC_5_6,				//!< rate 5/6
	FEC_RATE_NUM			//!< number of FEC rates
};

//! Boosting
enum Boosting {
	BOOST_NORM,				//!< no boosting
	BOOST_P6,				//!< +6dB
	BOOST_M6,				//!< -6dB
	BOOST_P9,				//!< +9dB
	BOOST_P3,				//!< +3dB
	BOOST_M3,				//!< -3dB
	BOOST_M9,				//!< -9dB
	BOOST_M12				//!< -12dB
}; 

const int		aPhyRandPrbsTap[] = { 9, 11 };		//!< Taps of Physical subcarrier randomization PRBS
const int		aBurstDataPrbsTap[] = { 14, 15 };	//!< Taps of Burst data randomization PRBS

//! Burst shape
enum BurstShape {
	SHAPE_RECT,				//!< rectangle
	SHAPE_CONT_SCH,			//!< 0-th subchannel after last subchannel, for example DL-MAP
//	SHAPE_CONT_TS			//!< UL bursts
};


//! DL burst params
struct BurstParam {
	int				fstTs;			//!< first timeslot number
	int				fstSch;			//!< first subchannel
	int				lstTs;			//!< last timeslot number
	int				lstSch;			//!< last subchannel
	BurstShape		shape;			//!< burst shape
	RepeatType		repeat;			//!< repeat
	ModulType		modul;			//!< modulation
	FecType			fec;			//!< FEC type
	FecRate			rate;			//!< FEC rate
	Boosting		boost;			//!< boosting
	bool			isFch;			//!< is FCH
};


//! Burst data
struct BurstData {
	const uint8 *	pBit;			//!< burst bits
	int				len;			//!< bit lenght
};



//! FCH message, Table 314—OFDMA DL Frame Prefix format for all FFT sizes except 128 
struct FchMsg {
	bool			aIsSchGrpUsed[dpGroupNum];		//!< is subchannel group used
	RepeatType		dlmapRepeat;	//!< DL-MAP repetition
	FecType			dlmapFec;		//!< DL-MAP FEC type
	int				dlmapLen;		//!< DL-MAP length in slots
};



/*****************************************************************************
Tables, descriptions etc
*****************************************************************************/



//! FFT size table
extern const int	aFftSzTbl[FFT_ENUM_NUM];

//! Number of symbol per timeslot table
extern const int	aSymPerTsTbl[ZONE_NUM];



//! FCH burst params
extern const BurstParam		fchBurstParam;

//! DL-MAP default burst param, should be updated with data from FCH
extern const BurstParam		dlmapDefBurstParam;


/*****************************************************************************
Handy functions
*****************************************************************************/

//! FFT size to type conversion
__inline FftEnum	fftSz2Type(	int		fftSz )
{
	for( int i = 0; i < ARRAY_SZ( aFftSzTbl ); i++ )
		if( aFftSzTbl[i] == fftSz )
			return (FftEnum)i;
	ASSERT( 0 );
	return FFT_ENUM_1024;
}


//! Repeat type to number conversion
__inline int		repeat2num(	RepeatType	type	)
{
	return ( type == REPEAT_1 ) ? 1 : type*2;
}

//! Modulation type to bit per symbol conversion
__inline int		modul2bps(	ModulType	modul	)
{
	return (modul+1)*2;
}

//! FEC rate type to rate value conversion
__inline float		fecrate2val(	FecRate	rate	)
{
	float	t = ( rate != FEC_5_6 ) ? (float)rate+1.f : 5.f;
	return t/(t+1.f);
}


//! Pack bits to integer value, MSB first, return integer value
__inline uint32		packBit(	const uint8 * *	ppBit,		//!< input bits
								int				len		)	//!< length
{
	uint32		t = 0;
	const uint8 *	pBit = *ppBit;
	ASSERT( len <= 32 );
	for( int i = 0; i < len; i++ )
		t = t<<1 | *pBit++;
	*ppBit += len;
	return t;
}




#endif //#ifndef _GLOBAL_H_


