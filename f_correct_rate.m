
function p_guess_correct = f_correct_rate(m, len, F1, p_val)

gc_cut = chi2inv(1-p_val, m)/len;
p_H0_significant = chi2_cdf(len*gc_cut, m, 0);
p_H1_nonsignificant = chi2_cdf(len*gc_cut, m, len*F1);
% if independent
p_guess_correct = p_H0_significant * (1-p_H1_nonsignificant);

