#ifndef _CHANNEL_ESTIMATOR_H_
#define _CHANNEL_ESTIMATOR_H_

#include "wimax_consts.h"
#include "complex.h"

/**
* OFDM Channel Estimator.
*
* Channel estimator has very simple structure and works like many other
* OFDM estimators do:
*  1. Estimations from OFDM pilots are smothed and then.
*  2. Smoother estimations are interpolated to non-pilot sub-carriers
*     by convolution with the Hamming window.
*  3. Interpolated data is filtered in time (i.e. smoothed over OFDM symbols)
*     with a filter like y(n) = (1-k)*y(n-1) + k*x(k), where n is an OFDM symbol,
*     and k is some number < 1.
*/
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
