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
	FFT_Init( &m_fft_state ); 
	m_pWimaxDecoders = NULL; 

	int j; 
	Complex<float> zero(0); 
	for(i=0; i<2; i++)
		for(j=0; j<FFT_SIZE; j++)
			m_pilots_shifted[i][j] = zero; 

	for(i=0; i<2; i++)
	{
		for(j=0; j<NUM_PILOTS; j++)
		{
			m_pilots_shifted[i][pilots_pos[i][j]] = Complex<float>(1,0); 
		}
	}
	m_pWimaxDecoders = new Decoder( FFT_SIZE );
}

int tWiMax_Dem::GetSamples( Complex<int16_t> *psamples, /*	complex samples in the interleaved order
															real sample is first */
							int n,						/*	number of complex samples */
							tWiMax_Status *pstatus)
{
	
	static int samples_count = -n;
	static int test_cnt = 1; 
	int i; 


	pstatus->pDecRes = NULL; 

	assert(n*2 < INBUF_SIZE); 
	assert(n==(FFT_SIZE+GI_LENGTH)); 

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
				
				int offset = find_preamble(p, 341); 				
				if( offset >= 0)
				{
					// print sample number which starts the preamble
#if 0
					// for input block size = 1024
					printf("Preamble detected: %d\n", samples_count+offset -FIND_PREAMBLE_DELAY*2- (GI_LENGTH/2)); 
#else
					// for input block size = 1024+128
					printf("Preamble detected: %d\n", 256 + samples_count+offset -FIND_PREAMBLE_DELAY*2- (GI_LENGTH/2)); 
#endif
					m_pFrame = p + offset -FIND_PREAMBLE_DELAY*2- (GI_LENGTH/2) - 1; 
					
					ProcessPreamble(); 
					m_state=/*WIMAX_DEM_IDLE;*/WIMAX_DEM_WORK;
					m_frames_counter =0;
				} //if( offset >= 0)
				samples_count+=341; 
				i += 341;
			}
			m_num_remaining_samples = n-i; 
			
		break; 
		
		case WIMAX_DEM_WORK:
			samples_count += n; 
			
			ProcessFrame(); 
			pstatus->procRes = m_pWimaxDecoders->procSym( m_frame_fd, m_chest.m_current_H );
			m_frames_counter++;

			if(m_frames_counter==4)
			{
				pstatus->pDecRes = m_pWimaxDecoders->getDecRes();
				m_state = WIMAX_DEM_IDLE;
			}
		break; 
	}
	
	return 0; 
}

void tWiMax_Dem::ProcessFrame()
{
	//static FILE *fp_test = NULL; 
	//if(fp_test==NULL)
	//{
	//	fp_test = fopen("test.bin", "wb"); 
	//}

	// Correct carrier offset (in time domain)
	m_carrier_phase += m_cfo*(FFT_SIZE+GI_LENGTH); 
	mpy_by_cexp( m_pFrame, FFT_SIZE, m_tmp_frame, -m_carrier_phase, -m_cfo); 

	FFT_fwd(&m_fft_state, m_tmp_frame, m_frame_fd);  
	fftshift(m_frame_fd, FFT_SIZE); 	

	// Correct timing offset (in frequency domain)
	mpy_by_cexp(m_frame_fd, FFT_SIZE, m_frame_fd, 2*M_PI/1024*(GI_LENGTH/2), 2*M_PI/1024*(GI_LENGTH/2));  
	mpy_by_cexp(m_frame_fd, FFT_SIZE, m_frame_fd, -m_phase_trend, -m_phase_trend); 

	// Generate sequence of the pilots for current frame
	memset(m_current_pilots, 0, sizeof(m_current_pilots)); 
	m_pWimaxDecoders->phyDerand2(&m_pilots_shifted[m_frames_counter&1][SC_FIRST], 
														&m_current_pilots[SC_FIRST], 
														m_frames_counter&1, 
														m_frames_counter>>1); 
		
	// Update a estimation of the CR
	float dcfo = m_chest.Update(m_frame_fd, m_current_pilots) ; 

	//fwrite(m_frame_fd, sizeof(m_frame_fd[0]), 1024, fp_test); 
	//fwrite(m_chest.m_current_H, sizeof(m_frame_fd[0]), 1024, fp_test); 
	//fflush(fp_test); 

	
	// Ajust value of CFO
	m_cfo += 0.7f*dcfo/(FFT_SIZE+GI_LENGTH); 
}

void tWiMax_Dem::ProcessPreamble()
{
	FFT_fwd(&m_fft_state, m_pFrame, m_frame_fd);  
	fftshift(m_frame_fd, FFT_SIZE); 	
	mpy_by_cexp(m_frame_fd, FFT_SIZE, m_tmp_frame, 2*M_PI/1024*(GI_LENGTH/2), 2*M_PI/1024*(GI_LENGTH/2));  

	int int_CFO; 
	int preamble_index = detect_preamble_fd(m_tmp_frame, 2, &int_CFO); 
	int segment = preamble_index/32; 
	// Estimate fractional part of the CFO 
	float CFO_frac = m_cfo_estimator.Estimate(m_frame_fd, segment+int_CFO); 
	// Add integer part of the CFO   
	m_cfo = CFO_frac+2*int_CFO*M_PI/1024; 

	// Compensate the CFO for preamble in the time domain
	mpy_by_cexp( m_pFrame, FFT_SIZE, m_tmp_frame, 0, -m_cfo);  
	FFT_fwd(&m_fft_state, m_tmp_frame, m_frame_fd);  
	mpy_by_cexp(m_frame_fd, FFT_SIZE, m_frame_fd, 2*M_PI/1024*(GI_LENGTH/2), 2*M_PI/1024*(GI_LENGTH/2));

	fftshift(m_frame_fd, FFT_SIZE); 	
	m_carrier_phase = 0; 
	// precise timing correction
	m_phase_trend = find_phase_trend(m_frame_fd, preamble_index); 
	mpy_by_cexp(m_frame_fd, FFT_SIZE, m_frame_fd, -m_phase_trend, -m_phase_trend); 

	m_pWimaxDecoders->startNewFrm( preamble_index );
	m_chest.Start(m_frame_fd, preamble_index);
}

// The general idea is to make the phase of the OFDM  symbol more  smooth.
float tWiMax_Dem::find_phase_trend(Complex<float> *pframe, int preamble_idx)
{
	const float *pref = preambles_freq_shifted[preamble_idx]; 
	Complex <float> acc(0); 
	int i; 
	for(i = 3; i<FFT_SIZE; i++)
	{
		Complex <float> t = pref[i-3] * pframe[i-3]; 
		acc += ( pref[i] * pframe[i]) * t.conj(); 
	}
	return acc.arg()/3; 
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
	FFT_Free( &m_fft_state ); 
	delete m_pWimaxDecoders;
}
/*
	return preamble index 
*/
int tWiMax_Dem::detect_preamble_fd( Complex<float> *sig_in_freq_shifted, 
							int max_offset,		/* max integer CFO */ 
							int *est_offset)	/* finded integer CFO */ 
{
	int n, j, m, s; 
	float max_sum_abs = -1;
	int  preamble_index; 
	for(n=-max_offset; n<=max_offset; n++)//for n = -max_offset:max_offset
	{
		for(j = 0; j <NUM_PREAMBLES; j++)//num_preambles
		{
			//tmp  = fftshift(preamble_freq(j, :)); 
			const float *p = preambles_freq_shifted[j] + 32; 
			float sum_abs = 0; 
			Complex <float> *pin = sig_in_freq_shifted + 32 + n ; 
			
			for( m=0; m < (1024-64)/32; m++)
			{
				Complex <float> sum(0,0); 
				for( s=0; s<32; s++)
				{
					sum += (*p++) * (*pin++); 
				}
				sum_abs += sum.abs(); 
			}

			if(sum_abs > max_sum_abs)
			{
				max_sum_abs = sum_abs;
				preamble_index = j; 
				*est_offset = n; 
			}
		}
	}	
/*
	if(m_pWimaxDecoders != NULL)
		delete 	m_pWimaxDecoders; 
*/
	return preamble_index; 
}
