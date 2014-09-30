function warped = warppos_img_noBdrAdded(pos, fsize, sbin)
% Warp positive examples to fit model dimensions.
%   warped = warppos(model, pos)
%
%   Used for training root filters from positive bounding boxes.
%
% Return value
%   warped  Cell array of images
%
% Arguments
%   model   Root filter only model
%   pos     Positive examples from pascal_data.m

pixels = fsize * sbin;
numpos = length(pos);
warped = cell(numpos,1);
cropsize = (fsize+2) * sbin;
%par
for i = 1:numpos    
%  img = imreadx(pos(i)); %by Santosh
    img = pos(i).im; %edited by moin
  [ht wd dp] = size(img);
  %padx = sbin * wd / pixels(2); pady = sbin * ht / pixels(1);
  padx = 0; pady = 0;
  x1 = round(1-padx);
  x2 = round(wd+padx);
  y1 = round(1-pady);
  y2 = round(ht+pady);
  window = subarray(img, y1, y2, x1, x2, 1);
  warped{i} = imresize(window, cropsize, 'bilinear');
end
