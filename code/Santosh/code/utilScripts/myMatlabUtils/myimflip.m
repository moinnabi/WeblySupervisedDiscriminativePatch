function newim=myimflip(im,fmode)

for j=1:size(im,3)
    if strcmp(fmode, 'ud')
        newim(:,:,j) = flipud(im(:,:,j));
    elseif strcmp(fmode, 'lr')
        newim(:,:,j) = fliplr(im(:,:,j));
    end
end