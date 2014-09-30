function show_all_ellipses(I, ellipses, color, ln_wid)


if nargin < 3
    color = 'r';
end

if nargin < 4
   ln_wid = 1.5;
end

num_pts = size(ellipses,1);

imshow(I);

for i=1:num_pts
    R = reshape(ellipses(i,5:8), [2 2]);
    D = diag(ellipses(i,3:4));
    if D(2,2) / D(1,1) > 3
        D(1,1) = D(2,2) / 3;
    end
    draw_ellipse(ellipses(i,1), ellipses(i,2), R * D, color, ln_wid);    
end
title(sprintf('%d ellipses', size(ellipses,1)));
