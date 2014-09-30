function maxmap = imresizeMax(cim, maximsize)
% maxmap = imresizeMax(cim, maxsize)
% 
% Downsample (or upsample) cim to maxsize so that each pixel of maxmap
% contains the maximum value of the corresponding values of cim

if maximsize<max(size(cim))
    sf = maximsize/max(size(cim));
    fil = ones(ceil(1/sf));
    nf = numel(fil);         
    maxmap = ordfilt2m(cim, nf, fil);   
    maxmap = imresize(maxmap, sf, 'nearest');
else
    maxmap = imresize(cim, maxsize, 'nearest');
end


%% ordfilt2 for multiple bands
function im2 = ordfilt2m(im, ord, fil)

if size(im, 3)==1
    im2 = ordfilt2(im, ord, fil);
else
    im2 = zeros(size(im));
    for k = 1:size(im, 3)
        im2(:, :, k) = ordfilt2(im(:, :, k), ord, fil);
    end
end