
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
disp('var (\Sigma) at bic_od, var reduce ratio:');
s1=num2str(oDe(:,:,bic_od),' %9.3g');
s2=num2str(diag(diag(R)./diag(oDe(:,:,bic_od))),' %8.4g');
disp(cat(2, char(' '*ones(p,2)), s1,...
  char(' '*ones(p,3)), char('|'*ones(p,1)), char(' '*ones(p,3)), s2));

disp(['GC(od=' num2str(bic_od) '(bic))/' st_gc_scale...
      ' and /mean(GC0)'...
      ' and GC(od=zero)/' st_gc_scale ':']);
sg1 = num2str(oGC(:,:,bic_od)/gc_scale, ' %6.2f');
sg2 = num2str(oGC(:,:,bic_od)/(bic_od/len), ' %6.2f');
sg3 = num2str(zero_GC/gc_scale, ' %6.2f');
disp(cat(2, char(' '*ones(p,2)), sg1,...
  char(' '*ones(p,3)), char('|'*ones(p,1)), char(' '*ones(p,3)), sg2,...
  char(' '*ones(p,3)), char('|'*ones(p,1)), char(' '*ones(p,3)), sg3));

disp('confidence intervals (non-zero probability) at bic_od:');
[gc_lower, gc_upper] = gc_prob_intv(oGC(:,:,bic_od), bic_od, len);
st_gclu = char(arrayfun(@(x,y,z)sprintf("  %.2f ~ %.2f (%.2f)", x,y,z),...
  gc_lower'/gc_scale, gc_upper'/gc_scale, gc_prob_nonzero(oGC(:,:,bic_od),bic_od,len)', 'UniformOutput', false));
disp(reshape(st_gclu',size(st_gclu,2)*p,[])');

