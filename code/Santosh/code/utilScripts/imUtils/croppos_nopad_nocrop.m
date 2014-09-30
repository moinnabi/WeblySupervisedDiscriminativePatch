function [im, box, x1, y1] = croppos_nopad_nocrop(im, box)
% taken from croppos_nopad
% not doing the cropping in case it goes outside image limits as I want to
% retrain the zero paddinng that was 
padx = 0; pady = 0;
%x1 = max(1, round(box(1) - padx));
%y1 = max(1, round(box(2) - pady));
%x2 = min(size(im, 2), round(box(3) + padx));
%y2 = min(size(im, 1), round(box(4) + pady));
x1 = round(box(1) - padx);
y1 = round(box(2) - pady);
x2 = round(box(3) + padx);
y2 = round(box(4) + pady);

%im = im(y1:y2, x1:x2, :);
im = uint8(subarray(im, y1, y2, x1, x2, 0));   % pad with 0 as featpyramid also does so

box([1 3]) = box([1 3]) - x1 + 1;
box([2 4]) = box([2 4]) - y1 + 1;
