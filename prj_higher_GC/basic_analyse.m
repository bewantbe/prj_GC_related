
function ba = basic_analyse(X, s_od)

[p,len] = size(X);

[oGC, oDe, R] = AnalyseSeries(X, s_od, 0);
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% print out data
%fprintf('bo:%2d, ao:%2d\n', bic_od, aic_od);
%disp('var (\Sigma) at bic_od:');
%disp(oDe(:,:,bic_od));
%format 'bank'
  %disp(['GC(od=', num2str(bic_od), '(bic))*1e4:']);
  %disp(1e4*oGC(:,:,bic_od));
  %disp('non-zero test (at bic_od):');
  %disp(gc_prob_nonzero(oGC(:,:,bic_od),bic_od,len));
  %disp('confidence intervals (at bic_od):');
  %[gc_lower, gc_upper] = gc_prob_intv(oGC(:,:,bic_od), bic_od, len);
  %st_gclu = char(arrayfun(@(x,y)sprintf("  %.2f ~ %.2f", x,y), gc_lower'*1e4, gc_upper'*1e4, 'UniformOutput', false));
  %disp(reshape(st_gclu',size(st_gclu,2)*p,[])');
  %disp('GC(od=zero)*1e4:');
  %disp(1e4*zero_GC);
%format 'short'
%disp('var ratio (at bic_od): var(x)/var(\epsilon), var(y)/var(\eta)');   % for 2-var only
%disp([num2str(R(1,1)/oDe(1,1,bic_od)), ' ', num2str(R(2,2)/oDe(2,2,bic_od))]);

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

basic_analyse_show(ba);
