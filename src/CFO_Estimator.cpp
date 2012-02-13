#include "CFO_Estimator.h"
#include "dsp_utils.h"


const int tCFO_Estimator::first_carrier_for_segment0 = 87; 
const int tCFO_Estimator::num_carriers_in_preamble = 284; 
const int tCFO_Estimator::grid_size = CFO_GRID_SIZE; 
const int tCFO_Estimator::shift_fir_len= SHIFT_MTX_NUM_COLS; 
const float tCFO_Estimator::grid[CFO_GRID_SIZE] = 
{
	-0.0034f,   
	-0.0025f,   
	-0.0017f,   
	-0.0008f,   
	-0.0000f,    
	0.0008f,    
	0.0017f,    
	0.0025f,    
	0.0034f
}; 

const float tCFO_Estimator::shift_Mtx[CFO_GRID_SIZE * SHIFT_MTX_NUM_COLS * 2 ] =
{
  -0.0129f,   0.0876f,  -0.0183f,   0.1219f,  -0.0308f,   0.2005f,  -0.0885f,   0.5647f,   0.1102f, - 0.6899f,   0.0349f, - 0.2140f,   0.0210f, - 0.1266f,
   0.0253f,   0.0861f,   0.0354f,   0.1220f,   0.0598f,   0.2085f,   0.2025f,   0.7145f,  -0.1406f, - 0.5021f,  -0.0515f, - 0.1860f,  -0.0312f, - 0.1142f,
   0.0486f,   0.0557f,   0.0697f,   0.0804f,   0.1239f,   0.1439f,   0.5722f,   0.6688f,  -0.2163f, - 0.2543f,  -0.0906f, - 0.1072f,  -0.0571f, - 0.0680f,
   0.0387f,   0.0174f,   0.0568f,   0.0257f,   0.1066f,   0.0487f,   0.8803f,   0.4054f,  -0.1401f, - 0.0651f,  -0.0648f, - 0.0303f,  -0.0421f, - 0.0199f,
   0.0000f, - 0.0000f,   0.0000f, - 0.0000f,   0.0000f, - 0.0000f,   1.0000f,   0.0000f,  -0.0000f, - 0.0000f,  -0.0000f, - 0.0000f,  -0.0000f, - 0.0000f,
  -0.0421f,   0.0199f,  -0.0648f,   0.0303f,  -0.1401f,   0.0651f,   0.8803f, - 0.4054f,   0.1066f, - 0.0487f,   0.0568f, - 0.0257f,   0.0387f, - 0.0174f,
  -0.0571f,   0.0680f,  -0.0906f,   0.1072f,  -0.2163f,   0.2543f,   0.5722f, - 0.6688f,   0.1239f, - 0.1439f,   0.0697f, - 0.0804f,   0.0486f, - 0.0557f,
  -0.0312f,   0.1142f,  -0.0515f,   0.1860f,  -0.1406f,   0.5021f,   0.2025f, - 0.7145f,   0.0598f, - 0.2085f,   0.0354f, - 0.1220f,   0.0253f, - 0.0861f,
   0.0210f,   0.1266f,   0.0349f,   0.2140f,   0.1102f,   0.6899f,  -0.0885f, - 0.5647f,  -0.0308f, - 0.2005f,  -0.0183f, - 0.1219f,  -0.0129f, - 0.0876f
};																								 
  

  
  
  
  

tCFO_Estimator::tCFO_Estimator()
{

}; 

tCFO_Estimator::~tCFO_Estimator()
{

}; 

float tCFO_Estimator::Estimate( 
					Complex<float> *frame_shifted_fd, 
					int segment )
{
	int k ; 
	
	float max_m = -1; 
	int i; 
	float m[CFO_GRID_SIZE]; 
	int carrier_start = first_carrier_for_segment0 + segment-1; 	
	const int tmp = carrier_start + shift_fir_len/2; 

	for(k = 0; k<CFO_GRID_SIZE; k++)
	{
// Frequency shift in the frequency domain is convolution   
		conv(frame_shifted_fd,	
				1024, 
				(Complex<float> *)&shift_Mtx[shift_fir_len*2*k], 
				shift_fir_len, 
				frame_tmp2);

		m[k] = VectNorm2(&frame_tmp2[tmp], num_carriers_in_preamble, 3);
		m[k] -= VectNorm2(&frame_tmp2[tmp+1], num_carriers_in_preamble, 3);
	    m[k] -= VectNorm2(&frame_tmp2[tmp+2], num_carriers_in_preamble, 3);

		if(m[k]>max_m)
		{
			max_m = m[k]; 
			i = k; 
		}
	}

	float x0, x1, x2; 
	float y0, y1, y2; 

	x0 = grid[i]; 
	y0 = m[i]; 

	if (i==0)
	{
		x1 = grid[i+1]; 
		y1 = m[i+1]; 
		x2 = grid[i+2]; 
		y2 = m[i+2];                 
	}
	else
	{
		if (i==grid_size-1)
		{
			x1 = grid[i-1]; 
			y1 = m[i-1]; 
			x2 = grid[i-2]; 
			y2 = m[i-2];                 
		}
		else
		{
			x1 = grid[i-1]; 
			y1 =  m[i-1]; 
			x2 = grid[i+1]; 
			y2 = m[i+1];         
		}
	}

// The parabolic interpolation on three points
	float k1 = (y0-y1)/(y0-y2); 
	float cfo = -0.5f*(k1*(x0*x0 - x2*x2) - (x0*x0 - x1*x1))/ ((x0-x1)-k1*(x0-x2)); 
	return cfo;
}
