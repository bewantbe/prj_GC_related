
function line_mean_bar(x, y, hw, varargin)

lX = [
x x;
x-hw x-hw;
x+hw x+hw;
x-hw x+hw;
]';
lY = [
0 y*1.4;
y*0.93 y*1.07;
y*0.93 y*1.07;
y y
]';
line(lX, lY, varargin{:});
