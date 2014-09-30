function [dist, imsq, filsq] = imsqdist(im, fil, imsq, filsq)

if ~exist('imsq', 'var') || isempty(imsq)
    imsq = imfilter(im.*im, ones(size(fil)), 'same');   
end

if ~exist('filsq', 'var') || isempty(filsq)
    filsq = sum(fil(:).^2);
end

dist = imsq-2*imfilter(im, fil, 'same')+filsq;