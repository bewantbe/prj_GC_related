// mex getcovpdhded.cpp
//In octave
// CXXFLAGS='-O3 -march=native -fopenmp -std=c++11'  LDFLAGS='-march=native -fopenmp -lblas' mkoctfile --mex getcovzpdhded_armadillo.cpp
#include <mex.h>

#include <armadillo>
// use Col Major

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  if (nrhs != 4 || ! mxIsNumeric(prhs[3])) {
    mexErrMsgTxt("getcovpdhded(X, t_bg, t_ed, m)");
  }
  size_t p    = (size_t)mxGetM(prhs[0]);  // mrows
  size_t len  = (size_t)mxGetN(prhs[0]);  // ncols
  size_t t_bg = (size_t)mxGetScalar(prhs[1]);
  size_t t_ed = (size_t)mxGetScalar(prhs[2]);
  int m       =    (int)mxGetScalar(prhs[3]);
  if (m+1 > len) {
    mexErrMsgTxt("m too large!");
  }
  if (t_bg < m+1) {
    mexErrMsgTxt("t_bg too small!");
  }
  if (t_ed > len-m) {
    mexErrMsgTxt("t_ed too large!");
  }
  t_bg = t_bg - 1;

  const arma::mat X(mxGetPr(prhs[0]),p,len, false, true);

  size_t m1   = m + 1;
  plhs[0] = mxCreateDoubleMatrix(m1*p, m1*p, mxREAL);
  arma::mat covz(mxGetPr(plhs[0]), m1*p, m1*p, false, true);
  for (int i1=0; i1<=m; i1++) {
    for (int i2=0; i2<=m; i2++) {
      int k=i2-i1;
      int k_pos = k*(k>0);
      int k_neg = k*(k<0);
      //mexPrintf("for: i1=%d, i2=%d\n", i1, i2);
      //mexPrintf("p1=%d~%d", m-i1, t_bg+k_neg-1);
      //mexPrintf("p2=%d~%d", t_ed+k_neg, len-i1-1);
      //fflush(stdout);
      covz.submat(i1*p,i2*p,(i1+1)*p-1,(i2+1)*p-1) =
        X.submat(0,m-i1, p-1,t_bg+k_neg-1) * 
        X.submat(0,m-i2, p-1,t_bg-k_pos-1).t() +
        X.submat(0,t_ed+k_neg, p-1,len-i1-1) *
        X.submat(0,t_ed-k_pos, p-1,len-i2-1).t();
    }
  }
}
