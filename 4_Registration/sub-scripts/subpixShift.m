function [xoffset, yoffset]=subpixShift(a)

% This function computes the pixel shift needed in real numbers.
% calls:  maxArray.m
% max shift allowed is 21 pixels.
%
% Author:  Feimo Shen

siz=size(a);
hillsize=21;
subpxn=20;
peri=(hillsize-1)/2;
a=a((siz(1)+1)/2-peri:(siz(1)+1)/2+peri, (siz(2)+1)/2-peri:(siz(2)+1)/2+peri);
siz=size(a);
x=1:(1/subpxn):siz(2);
y=1:(1/subpxn):siz(1);
b=interp2(1:siz(2),(1:siz(1))',double(a),x,y','cubic');
peak=(maxArray(b)-1)/subpxn+1;
shift=peak-(hillsize+1)/2;
xoffset=-shift(2);
yoffset=-shift(1);

