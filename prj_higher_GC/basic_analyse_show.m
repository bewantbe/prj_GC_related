
function basic_analyse_show(ba, st_verbose)
  
oGC     = ba.oGC;
oDe     = ba.oDe;
R       = ba.R;
aic_od  = ba.aic_od;
bic_od  = ba.bic_od;
zero_GC = ba.zero_GC;
oAIC    = ba.oAIC;
oBIC    = ba.oBIC;
len     = ba.len;
p       = ba.p;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print out data
gc_scale = 1e-4;
st_gc_scale = sprintf('%.1e',gc_scale);
fprintf('bo:%2d, ao:%2d\n', bic_od, aic_od);
disp('var (\Sigma) at bic_od:');
disp(oDe(:,:,bic_od));
format 'bank'
  disp(['GC(od=' num2str(bic_od) '(bic))/' st_gc_scale ' and /mean(GC0) :']);
  sg1 = num2str(oGC(:,:,bic_od)/gc_scale, ' %6.2f');
  sg2 = num2str(oGC(:,:,bic_od)/(bic_od/len), ' %6.2f');
  disp(cat(2, char(' '*ones(p,2)), sg1, char(' '*ones(p,3)), char('|'*ones(p,1)), char(' '*ones(p,3)), sg2));
  disp('non-zero test (at bic_od):');
  disp(gc_prob_nonzero(oGC(:,:,bic_od),bic_od,len));
  disp('confidence intervals (at bic_od):');
  [gc_lower, gc_upper] = gc_prob_intv(oGC(:,:,bic_od), bic_od, len);
  st_gclu = char(arrayfun(@(x,y)sprintf("  %.2f ~ %.2f", x,y), gc_lower'/gc_scale, gc_upper'/gc_scale, 'UniformOutput', false));
  disp(reshape(st_gclu',size(st_gclu,2)*p,[])');
  disp(['GC(od=zero)/' st_gc_scale ':']);
  disp(zero_GC/gc_scale);
format 'short'
disp('var ratio (at bic_od): var(x)/var(\epsilon), var(y)/var(\eta)');   % for 2-var only
disp([num2str(R(1,1)/oDe(1,1,bic_od)), ' ', num2str(R(2,2)/oDe(2,2,bic_od))]);

