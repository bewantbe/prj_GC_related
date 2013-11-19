% assume F0 = 0

function len_min = solve_gc_min_len(od, F1, wantted_correct_rate, p_val)
%od = 17;
%len = 2*1e5;
%F1 = 1.592e-4;
%wantted_correct_rate = 0.9

if ~exist('wantted_correct_rate', 'var')
  wantted_correct_rate = 0.9;
end

if ~exist('p_val', 'var')
  p_val = 1e-2;
end

fcr = @(len) f_correct_rate(od, len, F1, p_val) - wantted_correct_rate;
 
len_guess = (1.153+sqrt(od-0.513)/1.917) * 10.002/F1;  % for p_val=0.01, wantted correct rate = 0.9

len_min = fzero(fcr, len_guess);

