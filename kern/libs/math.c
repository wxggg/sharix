#include <math.h>


int pow(int x, int e) {
	int ret = 1;
	for(int i=0; i<e; i++)
		ret *= x;

	return ret;
}

double powlf(double x, int e)
{
	double ret = 1.0;
	for(int i=0; i<e; i++)
		ret *= x;

	return ret;
}