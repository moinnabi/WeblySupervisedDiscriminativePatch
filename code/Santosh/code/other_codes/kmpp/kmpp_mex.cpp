#include <mex.h>
#include "KMeans.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *X, *centers, *v;
	int *Idx;
	float restarts, k, n,dim;
	double blah;
	
	if (nrhs == 0)	// print help info
	{
		mexPrintf("Usage: [Idx clusCentMat v] = kmeans(X, n, dim, k, restarts);\n");
		mexPrintf("where X is an array of size n*dim where X[d*i + j] gives coord j of point i\n");		
		mexPrintf("example: a=rand(10,30); [Idx, clus, v] = kmpp_mex(a, 10, 30, 3, 4);\n");
		//[Idx, clus] = kmpp_mex(a, 10, 30, 3, 4);
		return;
	}

	if (nrhs != 5){
		mexPrintf("at least five input arguments expected.");
		return;
	}
	
	X = mxGetPr(prhs[0]);
	n = (float) mxGetScalar(prhs[1]);
	dim = (float) mxGetScalar(prhs[2]);
	k = (float) mxGetScalar(prhs[3]);
	restarts = (float) mxGetScalar(prhs[4]);	
	//mexPrintf("%f %f\n", k, restarts);	

	//n = mxGetM(prhs[0]);
	//dim = mxGetN(prhs[0]);
			
	plhs[0] = mxCreateNumericMatrix((int) n, 1, mxINT16_CLASS, 0);
	plhs[1] = mxCreateNumericMatrix((int) k, (int) dim, mxDOUBLE_CLASS, 0);	
	//plhs[2] = mxCreateNumericMatrix(1, 1, mxDOUBLE_CLASS, 0);	
	Idx = (int *)mxGetPr(plhs[0]);
	centers = mxGetPr(plhs[1]);
	//v = mxGetPr(plhs[2]);
		
	mexPrintf("n=%d;k=%d;d=%d;restarts=%d\n", (int)n, (int)k, (int)dim, (int)restarts);		
	blah = RunKMeansPlusPlus((int)n, (int)k, (int)dim, X, (int)restarts, centers, Idx);
	// debuggin info (remove it later)
	mexPrintf("%f %f %f\n", X[0], X[200], X[299]);
	mexPrintf("%d %d %d\n", Idx[0], Idx[5], Idx[9]);
	mexPrintf("%f %f %f\n", centers[0], centers[31], centers[89]);
		
	return;
}
