#ifndef _WIMAX_CONSTS_H_
#define _WIMAX_CONSTS_H_

#define M_PI 3.14156f
#define SQRT_2 1.41421356f
#define NUM_PREAMBLES 114
#define NUM_PILOTS 120
#define N_TOTAL_SC 841
#define SC_FIRST 92
#define SC_LAST  932

#define R_DL_LENGTH 512 /*complex samples*/
#define FFT_SIZE 1024
/* length of OFDM guard interval */
#define GI_LENGTH 128
#define INBUF_SIZE (FFT_SIZE*3)
#define INBUF_OFFSET (FFT_SIZE)


#define FIND_PREAMBLE_SCRATCH_LEN (FFT_SIZE/2)
#define FIND_PREAMBLE_DELAY (FFT_SIZE/3)

#define MAX_SMOOTHER_WND  128
#define LEN_SMOOTHER_WND51 51

#define LEN_SMOOTHER_WND LEN_SMOOTHER_WND51
#define SMOOTHER_WND SmootherWnd51

#if MAX_SMOOTHER_WND < LEN_SMOOTHER_WND
#error MAX_SMOOTHER_WND < LEN_SMOOTHER_WND
#endif

extern const float SmootherWnd51[LEN_SMOOTHER_WND51]; 
extern const float preambles_freq_shifted[NUM_PREAMBLES][1024];
extern const int pilots_pos[2][NUM_PILOTS]; 


#endif //#ifndef _WIMAX_CONSTS_H_