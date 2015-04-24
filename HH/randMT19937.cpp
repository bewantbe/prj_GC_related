// mex randMT19937
// CXXFLAGS="-O3 -fopenmp -std=c++11"  LDFLAGS=" -fopenmp" mkoctfile --mex randMT19937.cpp
#include <mex.h>
#include <stdio.h>
#include <stdint.h>
#include <random>

#define HELP_MSG \
"Usage: randMT19937(m, n)\n"

void ShowUsage()
{
  mexErrMsgTxt(HELP_MSG);
}

// declare globally, so persist during Octave running
std::random_device rd;
std::mt19937_64 eng(rd());  // gcc4.8 simd_fast_mersenne_twister_engine
std::uniform_real_distribution<> unif_dis(0, 1);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  size_t m = 0, n = 0;  // number of rows and columns
  if (nrhs == 1) {
    if (!mxIsNumeric(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1) {
      ShowUsage();
    }
    double tmp = mxGetScalar(prhs[0]);
    if (tmp < 0) {
      ShowUsage();
    }
    m = n = (size_t)tmp;
  } else if (nrhs == 2) {
    if (!mxIsNumeric(prhs[0]) || mxGetNumberOfElements(prhs[0])!=1
      ||!mxIsNumeric(prhs[1]) || mxGetNumberOfElements(prhs[1])!=1) {
      ShowUsage();
    }
    double tmp1 = mxGetScalar(prhs[0]);
    double tmp2 = mxGetScalar(prhs[1]);
    if (tmp1 < 0 || tmp2 < 0) {
      ShowUsage();
    }
    m = (size_t)tmp1;
    n = (size_t)tmp2;
  } else {
    ShowUsage();
  }
  plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
  double *R = mxGetPr(plhs[0]);
  size_t s = m*n;
  for (size_t k = 0; k < s; k++) {
    R[k] = unif_dis(eng);
  }
//  uint32_t n = BKDRHash(mxArrayToString(prhs[0]));
//  char hash_st[9];  /* 32bit number in hex form */
//  sprintf(hash_st, "%.8X", n);
//  plhs[0] = mxCreateString(hash_st);
}
