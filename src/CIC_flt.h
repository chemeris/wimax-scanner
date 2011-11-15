/*
 Copyright (C) 2011  Alexey Ostapenko

 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.

 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.

 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301
 USA

	CIC filter 
*/

#ifndef _CIC_FLT_H_
#define _CIC_FLT_H_

#include <assert.h>
#include "Complex.h"

template<class tCicDataType> class tCIC_flt 
{
	public:
	tCIC_flt(	int len=0, 
				int decimation_factor=1,
				int order=1  )
	{
		if(order!=1)
		{
			// other orders not implemented yet
			assert(!"\nThe CIC order must be 1"); 
		}
		if (len==0)
		{
			m_pdl = NULL; 
		}
		else
		{
			m_pdl = new tCicDataType[len]; 
			int i; 
			for (i=0; i<len; i++)
			{
				m_pdl[i] = 0;
			}
		}
		m_last_data_ind = 0;
		m_acc = 0; 
		m_len = len; 
		m_df = decimation_factor; 
		m_dec_cnt = 0; 
	}

	~tCIC_flt()
	{
		if( m_pdl != NULL)
		{
			delete [] m_pdl; 
		}
	}

	// return number of the output samples
	int filtering(	tCicDataType *pin_samples, 
					int num_in_samples, 
					tCicDataType *pout_samples // pointer to output buffer, 
											   // size of output buffer must be 
											   // >= 1+num_in_samples/decimation_factor
											   )
	{
		int i; 
		int c =0; 

		tCicDataType t;

		assert(m_len); 		
		for(i=0; i<num_in_samples; i++)
		{
			// simplest and slowest realization of  the CIC filter
			// possible more effective fixed point realization
			t = pin_samples[i]; 
			m_acc += t - m_pdl[m_last_data_ind]; 
			m_pdl[m_last_data_ind] = t;

			m_last_data_ind++; 
			if(m_last_data_ind>= m_len) m_last_data_ind -= m_len; 

			m_dec_cnt++; 
			if(m_dec_cnt == m_df)
			{
				*pout_samples++ = m_acc; 
				c++; 
				m_dec_cnt=0; 
			}
		}
		return c; 
	}

protected:
	tCicDataType *m_pdl;// pointer to delay line
	int m_df;			// decimation factor
	int m_len;			// filter length
	tCicDataType m_acc; 
	int m_last_data_ind;  // 
	int m_dec_cnt; 


}; 

#endif //#ifndef _CIC_FLT_H_