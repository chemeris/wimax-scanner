/*
 Copyright (C) 2011  Alexey Ostapenko

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

	 WiMax demodulator
*/


#ifndef _WIMAX_DEM_H_
#define _WIMAX_DEM_H_

#include <stdio.h>
#include "Complex.h"
#include "dsp_utils.h"
#include "CIC_flt.h"

#define R_DL_LENGTH 512 /*complex samples*/
#define FFT_SIZE 1024
/* length of OFDM guard interval */
#define GI_LENGTH 128
#define INBUF_SIZE (FFT_SIZE*3)
#define INBUF_OFFSET (FFT_SIZE)

#define FIND_PREAMBLE_SCRATCH_LEN (FFT_SIZE/2)
#define FIND_PREAMBLE_DELAY (FFT_SIZE/3)

struct tFindPreambleScratch
{
	Complex <float> R_buf[FIND_PREAMBLE_SCRATCH_LEN]; 
	Complex <float> R_tone_rj_buf[FIND_PREAMBLE_SCRATCH_LEN]; 
	float en_buf[FIND_PREAMBLE_SCRATCH_LEN]; 
}; 


enum tWiMax_State 
{
	WIMAX_DEM_IDLE, 
	WIMAX_DEM_PREAMBLE,
	WIMAX_DEM_GET_FCH, 
	WIMAX_DEM_GET_DLMAP	
} ; 

class tWiMax_Params
{
public:
	int Tg_samples; 
	int Ts_samples; 
	int PD_delay_samples; 
}; 

class tWiMax_Status
{

}; 



class tWiMax_Dem
{
	public:		
		tWiMax_Dem(tWiMax_Params *params = NULL); 
		int GetSamples( Complex<int16_t> *psamples, /*complex samples in the interleaved order
										     real sample is first */
						int n,             /* number of input complex samples */
						tWiMax_Status *pstatus); 

	
	virtual	~tWiMax_Dem(); 

	void SetDefaultParams(tWiMax_Params *p); 

	protected:
// The CIC filter for autocorrelator output, 
// length of the this filter is equal length guard interval
	tCIC_flt <Complex <float> > *m_pcic_R; 
// The CIC filter for autocorrelator of tone rejector  
	tCIC_flt <Complex <float> > *m_pcic_Tone_r; 
// The CIC filter for energy
	tCIC_flt <float> *m_pcic_En; 
// Peak detectors parts
	float m_peak_diff_r2; 
	float m_stored_energy; 
	float m_fp_threshold;  // threhold of preamble detection 
	int   m_pd_counter; 

	
	int find_preamble(Complex<int16_t> *psamples, int n);
	int calc_acorr(Complex<int16_t> *psamples, int n);

	Complex<int16_t> m_input_buf[INBUF_SIZE]; 
	Complex<int16_t> *m_pcurrent_sample; 
	int m_num_remaining_samples; 

	Complex <float> m_dl_R [R_DL_LENGTH]; 
	Complex <float> m_dl_R_tone_reject[R_DL_LENGTH]; 
	float m_dl_en[R_DL_LENGTH]; 

	tFindPreambleScratch m_fp_scratch; 
	Complex <float> m_R, m_R_tone_reject; 
	float  m_En; 
	tWiMax_State m_state; 
	tWiMax_Params m_params; 

}; 


#endif //#ifndef _WIMAX_DEM_H_