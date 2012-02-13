
#include "dsp_utils.h"
#include "wimax_consts.h"

void circ_shift_left(	   void *pscr, 
					       void *parray, 
					       int size_array_elements, 					   
					       int shift_elements, 
					       int size_of_element)
{

	int ncopy_first = (size_array_elements - shift_elements); 
	int16_t *ptmp = (int16_t*)pscr; 

	memcpy(ptmp, ((int16_t*)parray) + shift_elements*size_of_element/sizeof(int16_t), ncopy_first*size_of_element); 
	ptmp += ncopy_first*size_of_element/sizeof(int16_t); 
	memcpy(ptmp, parray, size_of_element*shift_elements); 
	memcpy(parray, pscr, size_array_elements*size_of_element);
}
/*
ippsFFTInitAlloc_C_32fc(IppsFFTSpec_C_32fc** ppFFTSpec, int order,
int flag, IppHintAlgorithm hint);
*/

void FFT_Init(tFFT_State *pFFT_State)
{
#ifdef  USE_FFTW
	pFFT_State->in = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * FFT_SIZE);
    pFFT_State->out = (fftw_complex*) fftw_malloc(sizeof(fftw_complex) * FFT_SIZE);
    pFFT_State->p = fftw_plan_dft_1d(FFT_SIZE, pFFT_State->in, pFFT_State->out, FFTW_FORWARD, FFTW_ESTIMATE);
#else
	int buf_size; 
	ippsFFTInitAlloc_C_32fc(&pFFT_State->ppFFTSpec, 
					10, //int order, transform size is 2^10 = 1024
					IPP_FFT_NODIV_BY_ANY, 
					ippAlgHintNone);	
	ippsFFTGetBufSize_C_32fc(pFFT_State->ppFFTSpec, &buf_size); 

	pFFT_State->pBuffer = ippsMalloc_8u(buf_size);  
#endif
}


void FFT_Free(tFFT_State *pFFT_State)
{
#ifdef  USE_FFTW
	fftw_destroy_plan(pFFT_State->p);
    fftw_free(pFFT_State->in); 
	fftw_free(pFFT_State->out);
#else
	ippsFFTFree_C_32fc(pFFT_State->ppFFTSpec); 
	ippsFree(pFFT_State->pBuffer); 
#endif
}

void FFT_fwd(tFFT_State *pFFT_State,  Complex<int16_t> *pin,  Complex<float> *pout)
{
#ifdef  USE_FFTW
	int i; 
	fftw_complex *src = pFFT_State->in; 
	fftw_complex *dst = pFFT_State->out; 
	for(i=0; i<FFT_SIZE; i++)
	{
		src[i][0] = pin->real(); 
		src[i][1] = pin->imag(); 		
		pin++ ; 		
	}

	fftw_execute(pFFT_State->p); 
	for(i=0; i<FFT_SIZE; i++)
	{
		pout[i] = Complex<float>(float(dst[i][0]), float(dst[i][1])); 
	}

#else
	int i; 
	for(i=0; i<1024; i++)
	{
		Complex <float> tmp(pin->real(), pin->imag()); 
		pin++ ; 
		pout[i]=tmp;		
	}

	ippsFFTFwd_CToC_32fc_I((Ipp32fc*)pout, pFFT_State->ppFFTSpec, pFFT_State->pBuffer);  
#endif
}

void FFT_fwd(tFFT_State *pFFT_State,  Complex<float> *pin,  Complex<float> *pout)
{
#ifdef  USE_FFTW
	int i; 
	fftw_complex *src = pFFT_State->in; 
	fftw_complex *dst = pFFT_State->out; 
	for(i=0; i<FFT_SIZE; i++)
	{
		src[i][0] = pin->real(); 
		src[i][1] = pin->imag(); 		
		pin++ ; 		
	}

	fftw_execute(pFFT_State->p); 
	for(i=0; i<FFT_SIZE; i++)
	{
		pout[i] = Complex<float>(float(dst[i][0]), float(dst[i][1])); 
	}
#else
	int i; 
	for(i=0; i<1024; i++)
	{
		pout[i]=*pin++;		
	}

	ippsFFTFwd_CToC_32fc_I((Ipp32fc*)pout, pFFT_State->ppFFTSpec, pFFT_State->pBuffer);  
#endif
}

void fftshift(Complex<float> *pinout, int fft_size)
{
	int i; 
	Complex<float> *pbeg = pinout, t0, t1; 
	Complex<float> *pmid = pinout + fft_size/2; 

	for(i=0; i<fft_size/2; i++)
	{
		t0 = *pbeg; 
		t1 = *pmid; 
		*pbeg++ = t1; 
		*pmid++ = t0; 
	}
}


/*
  convolution, result's size is len_x+len_y-1 
*/
void conv(Complex<float> *x, int len_x, 
		  Complex<float> *y, int len_y,  
		  Complex<float> *z)
{
	int i, j; 
	Complex<float> zero(0,0); 

	for(i = 0; i<len_y+len_x-1; i++)
	{
		z[i] = zero; 
		
		for(j=0; j<len_y; j++)
		{
			if( (i-j) >= 0 && (i-j) < len_x)
			{
				z[i] += y[j] * x[i-j]; //C_MAC( z[i], y[j], x[i-j]);  
			}
		}
	}
}

/*
  convolution, result's size is len_x+len_y-1 
*/
void conv(Complex<float> *x, int len_x, 
		  const float *y, int len_y,  
		  Complex<float> *z)
{
	int i, j; 
	Complex<float> zero(0,0); 

	for(i = 0; i<len_y+len_x-1; i++)
	{
		z[i] = zero; 
		
		for(j=0; j<len_y; j++)
		{
			if( (i-j) >= 0 && (i-j) < len_x)
			{
				z[i] += y[j] * x[i-j]; //C_MAC( z[i], y[j], x[i-j]);  
			}
		}
	}
}


float VectNorm2(Complex<float> *x, int num_iter, int step)
{
	int i; 
	float sum = 0;
	for(i=0; i<num_iter; i++)
	{
		sum += x->norm2(); 
		x +=step; 
	}
	return sum; 
}

void mpy_by_cexp(Complex <int16_t> *pin, int len_in, 
				 Complex<float> *pout, 
				 float start_phase, 
				 float phase_increment)
{
	int i; 
	for(i=0; i<len_in; i++)
	{
		Complex <float> cexp(cosf(start_phase), sinf(start_phase)); 
		Complex <float> tmp( pin[i].real(), pin[i].imag() ); 
		pout[i] = tmp *  cexp; 
		start_phase += phase_increment; 		
	}
}

void mpy_by_cexp(Complex <float> *pin, int len_in, 
				 Complex<float> *pout, 
				 float start_phase, 
				 float phase_increment)
{
	int i; 
	for(i=0; i<len_in; i++)
	{
		Complex <float> cexp(cosf(start_phase), sinf(start_phase)); 
		
		pout[i] = pin[i] *  cexp; 
		start_phase += phase_increment; 		
	}
}