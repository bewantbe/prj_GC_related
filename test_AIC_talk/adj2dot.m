% Use it like
%    network_adjacency_matrix = rand(10)>0.4;
%    file_name = 'aaaaa';
%    adj2dot(network_adjacency_matrix, file_name);
%
% reference: http://graphviz.org

function adj2dot(network, basename, b_fix, node_name)

gheader0 = {
'digraph "G" {',
'  rankdir = "LR"',
'  node [',
'    fontname = "Arial"',
%'    label = ""',
'    shape = "circle"',
'    width = 0.5',
'    height = 0.5',
'    color = "black"',
'  ]',
'  edge [',
'    color = "black"',
'    weight = 2',
'  ]',
};

%'    label = "\N"',

% draw directional graph through GraphViz
fid = fopen([basename,'.dot'], 'w');

% output header information
gheader = gheader0;
gheader{1} = strrep(gheader{1}, '"G"', ['"', basename, '"']);

cellfun(@(st)fprintf(fid, '%s\n', st), gheader);
fprintf(fid, '\n');

% output edges (connections)
[conn_row, conn_col] = find(network);
arrayfun(...
  @(ii,jj) fprintf(fid, '  "%d" -> "%d";\n', jj,ii), ...
  conn_row, conn_col);

if ~exist('b_fix', 'var') || length(b_fix(:))==1 && ~b_fix
    prog = 'dot';
else
    n = size(network,1);
    if length(b_fix(:))==1
    % output node position
        for k=1:n
        %  if (mod(k,2)==1)
        %    z = 0.15*n*exp(2*pi*I*k/n);
        %  else
        %    z = 0.2*n*exp(2*pi*I*k/n);
        %  end
          z = 0.2*n*exp(2*pi*1i*(k/n-0.25));
          fprintf(fid, '  "%d" [pos = "%f,%f!"]\n', k, real(z), imag(z));
        end
    else
        if exist('node_name', 'var')
            for k=1:n
                fprintf(fid, '  "%s" [pos = "%f,%f!"]\n',...
                             node_name{k}, b_fix(k, 1), b_fix(k, 2));
            end
        else
            for k=1:n
                fprintf(fid, '  "%d" [pos = "%f,%f!"]\n',...
                             k, b_fix(k, 1), b_fix(k, 2));
            end
        end
    end
    prog = 'neato';
end

fprintf(fid,'}\n');
fclose(fid);

if ~exist('b_fix', 'var') && size(network,1) <= 3
    % use x,y,z instead of 1,2,3
    system(sprintf('sed -i s/\\"1\\"/\\"x\\"/ "%s"', [basename,'.dot']));
    system(sprintf('sed -i s/\\"2\\"/\\"y\\"/ "%s"', [basename,'.dot']));
    system(sprintf('sed -i s/\\"3\\"/\\"z\\"/ "%s"', [basename,'.dot']));
end

% convert to picture
%prog = 'circo'; % alternatives: 'twopi', 'dot'
%prog = 'twopi';
pic_format = 'eps';
%pic_format = 'png';
system([prog,' -T',pic_format,' ',basename,'.dot -o ',basename,'.',pic_format]);

