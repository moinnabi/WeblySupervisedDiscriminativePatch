function im = imresizeQuick(im, imsize, type)

if size(im, 1)==imsize(1) && size(im, 2)==imsize(2)
    return;
else
    
    if ~exist('type', 'var') || isempty(type)
        type = 'nearest';
    end
    im = imresize(im, imsize, type);
end