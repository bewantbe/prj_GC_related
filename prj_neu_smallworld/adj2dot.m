%

function adj2dot(network, basename)

gheader0 = {
'digraph "G" {',
'  node [',
'    fontname = "Arial"',
'    label = ""',
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

% output node position
n = size(network,1);
for k=1:n
%  if (mod(k,2)==1)
%    z = 0.15*n*exp(2*pi*I*k/n);
%  else
%    z = 0.2*n*exp(2*pi*I*k/n);
%  end
  z = 0.2*n*exp(2*pi*I*k/n);
  z = z*0.5;
  fprintf(fid, "  \"%d\" [pos = \"%f,%f!\"]\n", k, real(z), imag(z));
end

fprintf(fid,'}\n');
fclose(fid);

% convert to picture
%prog = 'circo'; % alternatives: 'twopi', 'dot'
prog = 'neato';
pic_format = 'eps';
%pic_format = 'png';
system([prog,' -T',pic_format,' ',basename,'.dot -o ',basename,'.',pic_format]);

