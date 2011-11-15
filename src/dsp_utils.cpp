
#include "dsp_utils.h"


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
