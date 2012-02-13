#ifndef _DSP_UTILS_H_
#define _DSP_UTILS_H_

#define USE_FFTW 1

#ifdef  USE_FFTW
#include "fftw3.h"
#else
#include <ipp.h>
#endif

#include <memory.h>
#include "complex.h"

#ifndef __GNUC__
// for MSVC compiler
//typedef long           int32_t;
#else

#endif

typedef short          int16_t;

void circ_shift_left( void *pscr, 
					       void *parray, 
					       int size_array_elements, 					   
					       int shift_elements, 
					       int size_of_element); 

struct tFFT_State
{
#ifdef  USE_FFTW
	fftw_complex *in, *out;
    fftw_plan p;
#else
	IppsFFTSpec_C_32fc* ppFFTSpec; 
	Ipp8u* pBuffer; 
#endif
}; 

void FFT_Init(tFFT_State *pFFT_State); 
void FFT_Free(tFFT_State *pFFT_State); 
void FFT_fwd(tFFT_State *pFFT_State,  Complex<int16_t> *pin,  Complex<float> *pout); 
void FFT_fwd(tFFT_State *pFFT_State,  Complex<float> *pin,  Complex<float> *pout); 

void fftshift(Complex<float> *pinout, int fft_size);

void conv(Complex<float> *x, int len_x, 
		  Complex<float> *y, int len_y,  
		  Complex<float> *z); 

void conv(Complex<float> *x, int len_x, 
		  const float *y, int len_y,  
		  Complex<float> *z); 

float VectNorm2(Complex<float> *x, int num_iter, int step); 

void mpy_by_cexp(Complex<float> *pin, int len_in, 
				 Complex<float> *pout, 
				 float start_phase, 
				 float phase_increment);


void mpy_by_cexp(Complex <int16_t> *pin, int len_in, 
				 Complex<float> *pout, 
				 float start_phase, 
				 float phase_increment); 
#endif
