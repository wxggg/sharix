#ifndef _LIB_MATH_H
#define _LIB_MATH_H 

#include <types.h>

#define max(x, y) (x) > (y) ? (x) : (y)
#define min(x, y) (x) < (y) ? (x) : (y)

#define abs(x) 		(x) > 0 ? (x) : (-(x))
#define pow2(x) 	((x)*(x))
#define	pow3(x)		((x)*(x)*(x))

int pow(int x, int e);
double powlf(double x, int e);

#endif	