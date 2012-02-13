#ifndef _CFO_ESTIMATOR_H_
#define _CFO_ESTIMATOR_H_

#include "complex.h"
#define CFO_GRID_SIZE 9
#define SHIFT_MTX_NUM_COLS 7

class tCFO_Estimator
{
public:
	tCFO_Estimator(); 
	~tCFO_Estimator(); 
	float Estimate( Complex<float> *frame_shifted_fd, 
					int segment );  

	static const int grid_size; 
	static const int shift_fir_len; 
	static const float grid[CFO_GRID_SIZE]; 
	static const float shift_Mtx[CFO_GRID_SIZE * SHIFT_MTX_NUM_COLS * 2 ]; 

protected:
	static const int first_carrier_for_segment0; 
	static const int num_carriers_in_preamble; 

	Complex<float> frame_tmp2[SHIFT_MTX_NUM_COLS+1024]; 
}; 
#endif
