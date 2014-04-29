%

cmdst='./raster_tuning -n 2 -t 1e4 -inf - -mat - --bin-save -o abc.dat';
system(cmdst);

output_name='abc.dat';
fid = fopen(output_name, 'r');
X = fread(fid, [p, Inf], 'double');
fclose(fid);


