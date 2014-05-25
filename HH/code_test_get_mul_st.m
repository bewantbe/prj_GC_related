% construct string for '--pr-mul', '--ps-mul', '--psi-mul'

function st = get_mul_st(pm, field_name)
    if isfield(pm, field_name)
        f = getfield(pm, field_name);
        if isnumeric(f)
            st = mat2str(f(:)');
            st = strrep(st,']','');
            st = strrep(st,'[','');
        elseif ischar(f)
            st = f;
        end
    else
        st = '';
    end
    st = strtrim(st);
    if ~isempty(st)
        st = [' --', strrep(field_name,'_','-'), ' ', st];
    end
end

pm.ps_mul = [];
pm.pr_mul = 1;
pm.psi_mul = [1 2 3];
pm.c2  = [4;5;6];
pm.d   = '4@4';
pm.f   = '  ';

fn = 'psi_mul';
fn = 'f';

st = get_mul_st(pm, fn)
whos('st')
