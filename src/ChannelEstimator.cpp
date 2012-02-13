#include "ChannelEstimator.h"
#include "dsp_utils.h"
#include "wimax_consts.h"

extern const float preambles_freq_shifted[NUM_PREAMBLES][1024]; 

static void FillTailes(Complex<float> *tmp)
{
	int i,j;
	for(i=0; i<SC_FIRST; i++)
	{
		tmp[i] = Complex<float>(0); 
	}

	for(i = SC_LAST + 1; i<FFT_SIZE; i++)
	{
		tmp[i] = Complex<float>(0); 
	}

	Complex<float> *pstart, *pend; 
	pstart = &tmp[SC_FIRST-14]; 
	pend   = &tmp[SC_LAST+1]; 

	for(j = 0; j < LEN_SMOOTHER_WND/14; j++)
	{
		for(i=0; i<14; i++)
		{
			pstart[i] = tmp[SC_FIRST + i]; 
			pend[i]   = tmp[SC_LAST-14 + i]; 
		}
		pstart-=14; 
		pend  +=14; 
	}

}

void tChannelEstimator::Start(Complex<float> *pframe, int preamble_idx)
{
	int i; 
	float gain = SQRT_2; 
	for(i = 0; i<FFT_SIZE; i++)
	{
		m_tmp[i] = gain * pframe[i] * preambles_freq_shifted[preamble_idx][i]; 
	}


	// Add virtual pilot near DC for avoid dip in the channel estimation 
	for(i=FFT_SIZE/2; i<FFT_SIZE/2+6; i++)
	{
		if(preambles_freq_shifted[preamble_idx][i]!=0) 
			break; 
	}	
	m_tmp[i-3] = (m_tmp[i] + m_tmp[i-6])* 0.5f; 

	FillTailes(m_tmp); 

	conv(m_tmp, FFT_SIZE, SMOOTHER_WND, LEN_SMOOTHER_WND, m_tmpH); 
	for(i=0; i<FFT_SIZE; i++)
	{
		m_current_H[i] = m_tmpH[LEN_SMOOTHER_WND/2+i]; 
		m_instant_H[i] = m_tmpH[LEN_SMOOTHER_WND/2+i]; 
	}

}

float tChannelEstimator::Update(Complex<float> *pframe, Complex<float> *pref)
{
	int i; 
	float gain = 7; 
	float td_sm_factor = 0.2f; 
	Complex <float> acc(0); 

	for(i = SC_FIRST; i<N_TOTAL_SC; i++)
	{
		m_tmp[i] = gain*pframe[i]*pref[i].conj();
	}

	FillTailes(m_tmp); 
	// A filtering in the frequency direction 
	conv(m_tmp, FFT_SIZE, SMOOTHER_WND, LEN_SMOOTHER_WND, m_tmpH); 

	for(i=0; i<FFT_SIZE; i++)
	{
	
		acc += m_tmpH[LEN_SMOOTHER_WND/2+i] * m_instant_H[i].conj(); 
	// A filtering in the time direction 
		m_current_H[i] += td_sm_factor*( m_tmpH[LEN_SMOOTHER_WND/2+i] - m_current_H[i]); 

		m_instant_H[i] = m_tmpH[LEN_SMOOTHER_WND/2+i]; 
	}
	// return phase shift
	return acc.arg(); 
}

void tChannelEstimator::Get(Complex<float> *pH, int delay = 0)
{
	int i; 
	for(i=0; i<FFT_SIZE; i++)
	{
		pH[i] = m_current_H[i]; 
	}
}