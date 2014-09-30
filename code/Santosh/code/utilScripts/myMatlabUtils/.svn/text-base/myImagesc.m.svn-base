function myImagesc(im)

% make all vals positive
minval = min(im(:));
im = im - minval;

% make them between 0-1
maxval = max(im(:));
im = im/maxval;

imagesc(im);
