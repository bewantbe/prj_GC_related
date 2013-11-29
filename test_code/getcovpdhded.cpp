// mex getcovpdhded.cpp
#include <mex.h>

#define EIGEN_NO_DEBUG
#include <eigen3/Eigen/Dense>
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

  //mexPrintf("Ha\n");
  const Eigen::Map<const Eigen::MatrixXd> X(mxGetPr(prhs[0]),p,len);
  //mexPrintf("Ha1, len=%d\n", len);

  size_t m1   = m + 1;
  plhs[0] = mxCreateDoubleMatrix(m1*p, m1*p, mxREAL);
  Eigen::Map<Eigen::MatrixXd> covz(mxGetPr(plhs[0]), m1*p, m1*p);
  //mexPrintf("Ha2\n");
  for (int i1=0; i1<=m; i1++) {
    for (int i2=0; i2<=m; i2++) {
      int k=i2-i1;
      int k_pos = k*(k>0);
      int k_neg = k*(k<0);
      //int k_pos = k>0 ? k : 0;
      //int k_neg = k<0 ? k : 0;
      //mexPrintf("Ha3: i1=%d, i2=%d\n", i1, i2);
      //mexPrintf("len p1 = %d\n", t_bg+k_neg-(m-i1));
      //mexPrintf("len p1 = %d\n", t_bg-k_pos-(m-i2));
      //mexPrintf("len p2 = %d\n", len-i2-(t_ed-k_pos));
      covz.block(i1*p,i2*p,p,p) =
        X.block(0,m-i1, p,t_bg+k_neg-(m-i1)) * 
        X.block(0,m-i2, p,t_bg-k_pos-(m-i2)).transpose() +
        X.block(0,t_ed+k_neg, p,len-i1-(t_ed+k_neg)) *
        X.block(0,t_ed-k_pos, p,len-i2-(t_ed-k_pos)).transpose();
    }
  }
}
