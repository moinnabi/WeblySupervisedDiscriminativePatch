#include <math.h>
#include "mex.h"
#include "my_arithmetic_sse_double.h"

/* See lbfgs.m for details! */
/* This function may not exit gracefully on bad input! */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	/* Variable Declarations */

	double *s, *y, *g, *H, *d, *ro, *alpha, *beta, *qq, *r;
	int nVars,nSteps,lhs_dims[2];
	double temp;
	int ii,j;

	/* Get Input Pointers */
	g = mxGetPr(prhs[0]);
	s = mxGetPr(prhs[1]);
	y = mxGetPr(prhs[2]);
	H = mxGetPr(prhs[3]);

	/* Compute number of variables (p), rank of update (d) */

	nVars = mxGetDimensions(prhs[1])[0];
	nSteps = mxGetDimensions(prhs[1])[1];

	/* Allocated Memory for Function Variables */
	ro = mxCalloc(nSteps,sizeof(double));
	alpha = mxCalloc(nSteps,sizeof(double));
	beta = mxCalloc(nSteps,sizeof(double));
	qq = mxCalloc(nVars*(nSteps+1),sizeof(double));
	r = mxCalloc(nVars*(nSteps+1),sizeof(double));

	/* Set-up Output Vector */
	lhs_dims[0] = nVars;
	lhs_dims[1] = 1;
	plhs[0] = mxCreateNumericArray(2,lhs_dims,mxDOUBLE_CLASS,mxREAL);
	d = mxGetPr(plhs[0]);

	/* ro = 1/(y(:,i)'*s(:,i)) */
	for(ii=0;ii<nSteps;ii++)
	{
		/*
		temp = 0;
		for(j=0;j<nVars;j++)
		{
			temp += y[j+nVars*ii]*s[j+nVars*ii];
		}
		*/
		vecdot_odd_unaligned(&temp, &y[nVars*ii], &s[nVars*ii], nVars);
		ro[ii] = 1/temp;
	}

	/* qq(:,k+1) = g */
	/*
	for(ii=0;ii<nVars;ii++)
	{
		qq[ii+nVars*nSteps] = g[ii];
	}
	*/
	veccpy_odd_unaligned(&qq[nVars*nSteps], &g[0], nVars);

	for(ii=nSteps-1;ii>=0;ii--)
	{
		/* alpha(ii) = ro(ii)*s(:,ii)'*qq(:,ii+1) */
		/*
		alpha[ii] = 0;
		for(j=0;j<nVars;j++)
		{
			alpha[ii] += s[j+nVars*ii]*qq[j+nVars*(ii+1)]; 
		}
		*/
		vecdot_odd_unaligned(&alpha[ii], &s[nVars*ii], &qq[nVars*(ii+1)], nVars);
		alpha[ii] *= ro[ii];

		/* qq(:,ii) = qq(:,ii+1)-alpha(ii)*y(:,ii) */
		/*
		for(j=0;j<nVars;j++)
		{
			qq[j+nVars*ii]=qq[j+nVars*(ii+1)]-alpha[ii]*y[j+nVars*ii];
		}
		*/
		vec3add_odd_unaligned(&qq[nVars*ii], &qq[nVars*(ii+1)], &y[nVars*ii], -1*alpha[ii], nVars);
	}

	/*  r(:,1) = qq(:,1) */
	for(ii=0;ii<nVars;ii++)
	{
		r[ii] = H[0]*qq[ii];
	}
	/*veccpymul_odd_unaligned(&r[0], &qq[0], H[0], nVars);*/
	/*veccpy_odd_unaligned(&r[0], &qq[0], nVars);
	vecscale_odd_unaligned(&r[0], H[0], nVars);*/

	for(ii=0;ii<nSteps;ii++)
	{
		/* beta(ii) = ro(ii)*y(:,ii)'*r(:,ii) */
		/*
		beta[ii] = 0;
		for(j=0;j<nVars;j++)
		{
			beta[ii] += y[j+nVars*ii]*r[j+nVars*ii];
		}
		*/
		vecdot_odd_unaligned(&beta[ii], &y[nVars*ii], &r[nVars*ii], nVars);
		beta[ii] *= ro[ii];

		/* r(:,ii+1) = r(:,ii) + s(:,ii)*(alpha(ii)-beta(ii)) */
		/*
		for(j=0;j<nVars;j++)
		{
			r[j+nVars*(ii+1)]=r[j+nVars*ii]+s[j+nVars*ii]*(alpha[ii]-beta[ii]);
		}
		*/
		vec3add_odd_unaligned(&r[nVars*(ii+1)], &r[nVars*ii], &s[nVars*ii], (alpha[ii]-beta[ii]), nVars);
	}

	/* d = r(:,k+1) */
	/*
	for(ii=0;ii<nVars;ii++)
	{
		d[ii]=r[ii+nVars*nSteps];
	}
	*/
	veccpy_odd_unaligned(&d[0], &r[nVars*nSteps], nVars);

	/* Free Memory */
	mxFree(ro);
	mxFree(alpha);
	mxFree(beta);
	mxFree(qq);
	mxFree(r);

}
