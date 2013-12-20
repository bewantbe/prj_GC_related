
function ba = basic_analyse(X, s_od, b_show)

[p,len] = size(X);

[oGC, oDe, R] = AnalyseSeriesFast(X, s_od, 0);
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);

ba.s_od    = s_od;
ba.oGC     = oGC;
ba.oDe     = oDe;
ba.R       = R;
ba.aic_od  = aic_od;
ba.bic_od  = bic_od;
ba.zero_GC = zero_GC;
ba.oAIC    = oAIC;
ba.oBIC    = oBIC;
ba.len     = len;
ba.p       = p;

if exist('b_show','var') && b_show~=0
  basic_analyse_show(ba);
end
