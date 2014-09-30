#include <math.h>
#include "mex.h"
#include "my_arithmetic_sse_double.h"

/* See lbfgs.m for details! */
/* This function may not exit gracefully on bad input! */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* Variable Declarations */
	double *s, *y, *constval, *d; 
	int nVars,lhs_dims[2];

	/* Get Input Pointers */
	s = mxGetPr(prhs[0]);
	y = mxGetPr(prhs[1]);
	constval = mxGetPr(prhs[2]);

	nVars = mxGetDimensions(prhs[1])[0];

	/* Set-up Output Vector */
	lhs_dims[0] = nVars;
	lhs_dims[1] = 1;
	plhs[0] = mxCreateNumericArray(2,lhs_dims,mxDOUBLE_CLASS,mxREAL);
	d = mxGetPr(plhs[0]);

	vec3add_odd(&d[0], &s[0], &y[0], constval[0], nVars);
}
