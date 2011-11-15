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

#include <assert.h>
#include <math.h>
#include "wimax_dem.h"

//#define WRITE_ACOR_FILE
#undef WRITE_ACOR_FILE

void tWiMax_Dem::SetDefaultParams(tWiMax_Params *p)
{
	p->Tg_samples=128;
	p->Ts_samples=1024;
	p->PD_delay_samples = 341;
}
	
tWiMax_Dem::tWiMax_Dem(tWiMax_Params *params)
{	
	int i; 
	if ( params!=NULL )
	{
		m_params = *params; 
	}
	else
	{
		SetDefaultParams( &m_params ); 
	}

	m_state = WIMAX_DEM_IDLE; 
	
	
	for( i=0; i < INBUF_SIZE; i++)
	{
		m_input_buf[i] = 0; 
	}

	for( i=0; i<R_DL_LENGTH; i++)
	{
		m_dl_R[i] = 0;		
		m_dl_en[i] = 0; 
		m_dl_R_tone_reject[i] = 0;
	}
	//m_R_re = m_R_im = m_En = 0 ; 
	m_pcurrent_sample = m_input_buf + INBUF_OFFSET; 
	m_num_remaining_samples = 0;
	m_R=0; 
	m_En = 0; 
	m_R_tone_reject = 0; 

	m_pcic_En = new tCIC_flt <float> (GI_LENGTH); 
	assert(m_pcic_En); 
	m_pcic_R = new tCIC_flt <Complex <float> > (GI_LENGTH); 
	assert(m_pcic_R); 
	m_pcic_Tone_r = new tCIC_flt <Complex <float> > (GI_LENGTH); 
	assert(m_pcic_Tone_r); 
	
	m_peak_diff_r2 = 0; 
	m_stored_energy = 0;
	m_fp_threshold = 0.5; 
	m_pd_counter = 0; 

}

int tWiMax_Dem::GetSamples( Complex<int16_t> *psamples, /*	complex samples in the interleaved order
													real sample is first */
							int n,             /*	number of complex samples */
							tWiMax_Status *pstatus)
{
	static int test_cnt = 1; 
	int i; 


	assert(n*2 < INBUF_SIZE); 
	assert(n==FFT_SIZE); 

	Complex<int16_t> *pdst = m_input_buf; 
	Complex<int16_t> *psrc = m_input_buf +  n; 
	for (i=0; i < INBUF_SIZE-n; i++)
	{
		// Shift old samples
		 *pdst++ = *psrc++; 
	}

	for (i =0; i<n; i++)
	{
		// Put new samples into end of the buffer
		*pdst++ =  *psamples++;  
	}

	//State machine of the WiMax receiver 
	switch( m_state)
	{
		case WIMAX_DEM_IDLE:

			i = -m_num_remaining_samples;
			//data is processed in blocks of 1024/3 = 341 samples
			while( (n-i) >= 341)//for(i=-m_num_remaining_samples; i<n; i+=341)
			{
				Complex<int16_t> *p = m_input_buf+INBUF_OFFSET+i; 
				//Counter input samples is taken into account
				// delay the input buffer is needed only for the interaction of Matlab
				static int samples_count = -1024;
				int offset = find_preamble(p, 341); 				
				if( offset >= 0)
				{
					// print sample number which starts the preamble
					printf("Preamble detected: %d\n", samples_count+offset -FIND_PREAMBLE_DELAY*2- (GI_LENGTH/2)); 
				}
				samples_count+=341; 
				i += 341;
			}
			m_num_remaining_samples = n-i; 
			
		break; 

		case WIMAX_DEM_PREAMBLE:
			m_state = WIMAX_DEM_IDLE;
		break; 
	}
	
	return 0; 
}

/*
	Calculate autocorrelations for the find preamble
	Uses the fact that the preamble is a sequence repeated three times 
	(time domain).

	Input: 
		x - complex samples, 16 bits
		num - number of the samples

	Outputs:
		tWiMax_Dem::m_fp_scratch.en_buf is  energy of the signal
		tWiMax_Dem::m_fp_scratch.m_dl_R is  autocorrelation of the signal 
		tWiMax_Dem::m_fp_scratch.R_tone_rj_buf is the additional 
		autocorrelator, used for prevent false triggering in tone interference							
*/

int tWiMax_Dem::calc_acorr(Complex<int16_t> *x, int num)
{
	int i; 
	// size of the samples block is 341 = 1024/3
	assert(num==FFT_SIZE/3); 

	Complex<int16_t> *pleft = x;
	Complex<int16_t> *pcentre  = x		+ m_params.PD_delay_samples;
	Complex<int16_t> *pright   = x		+ m_params.PD_delay_samples*2;
	Complex<int16_t> *ptone_rej= pcentre + 277; // magic offset

	for(i=0; i < num; i++)
	{
		float tmp_en;

		Complex <float> left(pleft->real(), pleft->imag()), 
						centre(pcentre->real(), pcentre->imag()), 
						right(pright->real(),  pright->imag()),
						trj(ptone_rej->real(), ptone_rej->imag()); 
		
		Complex <float> tmp, tmp1; 

		tmp = 2.0f*(left.conj() * centre + centre.conj()*right); 
		tmp_en = left.norm2() + 2*centre.norm2() + right.norm2(); 
		tmp1 = 4.0f * centre.conj() * trj; 

		pleft++; pcentre++; pright++; ptone_rej++; 


		m_R += tmp - m_dl_R[i]; 
		m_R_tone_reject += tmp1 - m_dl_R_tone_reject[i]; 
		m_En += tmp_en - m_dl_en[i]; 			
		
		m_fp_scratch.en_buf[i] = m_En; 
		m_fp_scratch.R_tone_rj_buf[i] = m_R_tone_reject; 
		m_fp_scratch.R_buf[i] = m_R; 

		assert(m_En>=0);

		m_dl_R[i]  = tmp;
		m_dl_en[i] = tmp_en; 	
		m_dl_R_tone_reject[i] = tmp1;
	}

	Complex <float> *r = m_fp_scratch.R_buf; 
	float *e = m_fp_scratch.en_buf; 
	Complex <float> *t = m_fp_scratch.R_tone_rj_buf; 

	//do inplace filtering  outputs of the autocorrelators
	int m = m_pcic_En->filtering(e, num, e); 
	m_pcic_R->filtering(r, num, r); 
	m_pcic_Tone_r->filtering(t, num, t); 

	// return number of the filtered samples
	// may be differ from num
	return m; 
}
/*
 Detect of presence of the preamble
 If the  preamble  presented return offset in the samples
 (value >=0) otherwise return -1;
*/
int tWiMax_Dem::find_preamble(Complex<int16_t> *x, int n)
{ 
	
	int isPreambleDetected = -1;
	int i;
 
#ifdef WRITE_ACOR_FILE
	// file for debug
	static FILE *fp_test = NULL; 
	if( fp_test==NULL )
	{
		fp_test = fopen("out_acor.pcm", "wb");  
	}
#endif 

	int m = calc_acorr(x, n); 
	// get pointers to autocorrelators results
	Complex <float> *r = m_fp_scratch.R_buf; 
	float *e = m_fp_scratch.en_buf; 
	Complex <float> *t = m_fp_scratch.R_tone_rj_buf; 
	
	for(i=0; i<m; i++)
	{
		float diff_r2, en2; 
 
#ifdef WRITE_ACOR_FILE
		short test16;
#endif
/*
		diff_r2 is  the energy at the main autocorrelator output minus 
		energy of the additional autocorrelator. 
		If there is a tonal interference value t[i].norm2 comparable 
		in magnitude to the r[i].norm2(). This prevents an erroneous 
		operation of the detector. 
*/
		diff_r2 = r[i].norm2() - t[i].norm2(); 
		en2 = e[i]*e[i];

		// peak detector
		if ( m_peak_diff_r2 < diff_r2)
		{
			 m_peak_diff_r2 = diff_r2; 
			 m_stored_energy = en2; 
			 m_pd_counter = 0; 			
		}
		else
		{
			m_pd_counter++; 
			if(m_pd_counter == FIND_PREAMBLE_DELAY)
			{
				if(m_peak_diff_r2 > m_fp_threshold*m_stored_energy)
				{
					m_peak_diff_r2 = 0;
					m_stored_energy = 1; 
					m_pd_counter = 0;					
				
				// frame start position is 
				//	x - (isPreambleDetected + FIND_PREAMBLE_DELAY)
#ifdef WRITE_ACOR_FILE
				// easy look into the *pcm file the time of detection of the preamble
					test16 = - 10000; 
					fwrite(&test16, sizeof(test16), 1, fp_test); 		
#endif
					isPreambleDetected = i; 
				}
				m_peak_diff_r2 = 0;
				m_stored_energy = 1; 
				m_pd_counter = 0;
			}
		}
#ifdef WRITE_ACOR_FILE					
		if(diff_r2>0)
		{
			test16 = short(20000 * sqrtf(diff_r2)/(e[i]+1)); 
		}
		else
		{
			test16 = 0; 
		}
		fwrite(&test16, sizeof(test16), 1, fp_test); 		
#endif
	}
	return isPreambleDetected;
}


	
tWiMax_Dem::~tWiMax_Dem()
{	
	delete m_pcic_En; 
	delete m_pcic_R; 
	delete m_pcic_Tone_r; 
}