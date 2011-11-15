#ifndef _DSP_UTILS_H_
#define _DSP_UTILS_H_
#include <memory.h>
#include "Complex.h"

#ifndef __GNUC__
// for MSVC compiler
typedef long           int32_t;
#else

#endif

typedef short          int16_t;

void circ_shift_left( void *pscr, 
					       void *parray, 
					       int size_array_elements, 					   
					       int shift_elements, 
					       int size_of_element); 

#endif
