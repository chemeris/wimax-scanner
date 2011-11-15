/*
	WiMax receiver simple testbench
*/
#include <stdio.h>
#include "wimax_dem.h"
#include "CIC_flt.h"

int main(int argn, char *argv[] )
{

	fprintf(stderr, "\nbuild time = %s \n", __TIME__);
	tWiMax_Dem dem; 

	FILE *fp_in = fopen(argv[1], "rb"); 

	if(fp_in==NULL)
	{
		fprintf(stderr, "\nERROR: Can't open input file %s", argv[1]); 
	}

	int16_t in_data[2048]; 
	int j=0, i=0, k = 0; 

	while(fread(in_data, sizeof(in_data[0]), 2048, fp_in)==2048)//for (j=0; j<25; j++)
	{
		int16_t *pin = in_data; 

		dem.GetSamples((Complex <int16_t> *)in_data, 1024, NULL); 
	}

	fclose(fp_in); 
	return 0;
}