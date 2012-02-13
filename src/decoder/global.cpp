/****************************************************************************/
/*! \file		global.cpp
	\brief		Global WIMAX defines
	\author		Iliya Voronov, iliya.voronov@gmail.com
	\version	0.1

	Global WIMAX defines, tables, utility functions etc.

	TODO:
	1. Single DL PUSC is implemented only

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

#include "global.h"


const int	aFftSzTbl[FFT_ENUM_NUM] = {
//	128,		// FFT_TYPE_128
//	512,		// FFT_TYPE_512
	1024,		// FFT_TYPE_1024
//	2048		// FFT_TYPE_2048
};


const int	aSymPerTsTbl[ZONE_NUM] = {
	2,			// ZONE_DL_PUSC
	1,			// ZONE_DL_FUSC
	3,			// ZONE_AMC
	1,			// ZONE_DL_OPT_FUSC
};



const BurstParam	fchBurstParam = { 
	0,				// fstTs
	0,				// fstSch
	0,				// lstTs
	3,				// lstSch
	SHAPE_RECT,		// shape
	REPEAT_4,		// repet
	MODUL_QPSK,		// modul
	FEC_CC,			// fec
	FEC_1_2,		// rate
	BOOST_NORM,		// boost
	true			// isFch
};

const BurstParam	dlmapDefBurstParam = { 
	0,				// fstTs
	4,				// fstSch
	0,				// lstTs
	3,				// lstSch
	SHAPE_CONT_SCH,	// shape
	REPEAT_4,		// repet
	MODUL_QPSK,		// modul
	FEC_CC,			// fec
	FEC_1_2,			// rate
	BOOST_NORM,		// boost
	false			// isFch
};








