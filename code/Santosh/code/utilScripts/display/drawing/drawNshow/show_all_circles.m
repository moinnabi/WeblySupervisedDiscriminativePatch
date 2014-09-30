function show_all_circles(I, circles, color, ln_wid)

if nargin < 3
    color = 'r';
end

if nargin < 4
   ln_wid = 1.5;
end

imshow(I);
draw_circle(circles(:,1), circles(:,2), circles(:,3), color, ln_wid);
title(sprintf('%d circles', size(circles,1)));
