#include <mex.h>
#include <stdio.h>   // for debug: printf()
#include <string.h>  // for memset()
#include <math.h>    // for exp()

const double G_L       = 0.05; // ms^-1
const double neu_sigma = 2.0;  // ms
const int c_state_length_filter_g = 2;
double coef1_FilterG;
double coef2_FilterG;
double CalCoefFilterG(double stv)
{
  coef1_FilterG = -exp(-G_L*stv) - exp(-stv/neu_sigma);
  coef2_FilterG = exp(-G_L*stv-stv/neu_sigma);
}
double FilterG(double v, double *v_state)
{
  double vout = v + coef1_FilterG*v_state[0] + coef2_FilterG*v_state[1];
  v_state[1] = v_state[0];
  v_state[0] = v;
  return vout;
}

// neu_volt_composer(Xv, ras[, stv])
void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
  if (nrhs!=2 && nrhs!=3) {
    mexErrMsgTxt("usage: neu_volt_composer(Xv, ras[, stv])\n");
  }

  const double *Xv  = mxGetPr(prhs[0]);    // p * len
  const double *ras = mxGetPr(prhs[1]);    // [neu_id, T_spike]*n_spike
  const size_t ras_len = mxGetN(prhs[1]);  // number of total spikes
  const size_t p   = mxGetM(prhs[0]);      // rows
  const size_t len = mxGetN(prhs[0]);      // cols
  double stv = 0.5;
  if (nrhs==3) {
    stv = mxGetScalar(prhs[2]);
  }
  CalCoefFilterG(stv);
  if (ras[ras_len*2-1] < 1e100) {
    mexErrMsgTxt("neu_volt_composer(): ras shold have a guard element!\nras=[ras;[0,1e300]];\n");
  }

  plhs[0] = mxCreateDoubleMatrix(p, len, mxREAL);

  int ras_id = 0;
  const double *p_Xv = Xv;
  const double *p_ras = ras+1;                // point to spike time
  double *p_v_out = mxGetPr(plhs[0]);
  double *arr_v_state = new double[p*c_state_length_filter_g];
  memset(arr_v_state, 0, sizeof(double)*p*c_state_length_filter_g);
  int *ref_period = new int[p];
  memset(ref_period, 0, sizeof(int)*p);

  for (size_t j=0; j<len; j++) {
    while (j*stv >= *p_ras) {   // if pass thresthold, reset filter state
      ref_period[int(*(p_ras-1))-1] = 4;  // avoid the spike region
      memset(arr_v_state+(int(*(p_ras-1))-1)*c_state_length_filter_g, 0, sizeof(double)*c_state_length_filter_g);
      p_ras += 2;
      ras_id ++;
    }
    for (size_t k=0; k<p; k++) {
      ref_period[k] -= ref_period[k]>0;
      *p_v_out++ = (ref_period[k]==0)*FilterG(*p_Xv++, arr_v_state+k*c_state_length_filter_g);
      //*p_v_out++ = FilterG(*p_Xv++, arr_v_state+k*c_state_length_filter_g);
    }
  }
  delete [] arr_v_state;
  delete [] ref_period;
}
