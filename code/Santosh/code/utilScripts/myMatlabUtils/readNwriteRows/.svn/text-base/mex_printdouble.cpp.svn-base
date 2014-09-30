
#include "mex.h"
#include <stdio.h>


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
 
  int strlen; 
  char* filename;
  char* opentype;
  double* data;
  int ndata;
  int n;
  FILE* fid; 
  int linelen;
  int k;
  int status;
  
  /* check for the proper no. of input and outputs */
  if (nrhs != 4)
    mexErrMsgTxt("4 input arguments are required: filname fopen_mode data linelen");
  if (nlhs>1)
    mexErrMsgTxt("Too many outputs");
  
  // Read Inputs
  strlen = mxGetN(prhs[0])*sizeof(mxChar)+1;
  filename = (char*)mxMalloc(strlen);  
  mxGetString(prhs[0], filename, strlen);     
  
  strlen = mxGetN(prhs[1])*sizeof(mxChar)+1;
  opentype = (char*)mxMalloc(strlen);  
  mxGetString(prhs[1], opentype, strlen);   
  
  ndata = mxGetNumberOfElements(prhs[2]);
  data = (double*)mxGetData(prhs[2]);
    
  linelen = (int)mxGetScalar(prhs[3]);  
  fid = fopen(filename, opentype);
  
  if (fid==0)
    printf("Failed to open %s\n", filename, fid);
  else {

      for (n=0; n<ndata; n+=linelen) {
          for (k=0; k<linelen; k++) {
          /*printf("%d\n", n);*/
              fprintf(fid, "%g ", (double)data[n+k]);
          }
          fprintf(fid, "\n");
      }
      fclose(fid);
  }    
  
  mxFree(filename);
  mxFree(opentype);  
  
}
  
