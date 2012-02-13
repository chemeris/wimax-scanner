#ifndef _CHANNEL_ESTIMATOR_H_
#define _CHANNEL_ESTIMATOR_H_

#include "wimax_consts.h"
#include "complex.h"

class tChannelEstimator
{
	public:
		tChannelEstimator()
		{}
		~tChannelEstimator()
		{}

		void Start(Complex<float> *pframe, int preamble_idx); 
		float Update(Complex<float> *pframe, Complex<float> *pref); 
		void Get(Complex<float> *pH, int delay ); 

	//protected:
		Complex<float> m_tmp[FFT_SIZE]; 
		Complex<float> m_tmpH[FFT_SIZE+ MAX_SMOOTHER_WND]; 
		Complex<float> m_current_H[FFT_SIZE]; 
		// instant estimation of the channel responce
		Complex<float> m_instant_H[FFT_SIZE]; 

};
#endif //#ifndef _CHANNEL_ESTIMATOR_H_
