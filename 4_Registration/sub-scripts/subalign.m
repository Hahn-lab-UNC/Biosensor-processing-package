function b=subalign(aa2, xshift, yshift)

% This function takes in the to be shifted image, the horizontal and
% verticle subpixel shifts and returns the shifted image.
%
% Author:  Feimo Shen

xsh=abs(xshift);
ysh=abs(yshift);
ker=[xsh, 1-xsh];

if xshift<=0   % shift to the left
    b=conv2(double(aa2),ker,'same');
else    % shift to the right
    b=conv2(double(fliplr(aa2)),ker,'same');
    b=fliplr(b);
end

ker=[ysh; 1-ysh];
if yshift<=0   % shift up
    b=conv2(double(b),ker,'same');
else    % shift down
    b=conv2(double(flipud(b)),ker,'same');
    b=flipud(b);
end

%imwrite(uint16(b),'shf.tif','tif','Compression','none');