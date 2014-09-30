function Y = resize3DMat_v2(Y,xht,xwd)
% this function is adopted from resize3DMat; the difference is that instead
% of taking whole matrix X as input, it just takes hgt and wdt as inputs

numdims = size(Y,3);
if xht ~= size(Y,1) || xwd ~= size(Y,2)     % if both do not have same dimensions
    Yr = zeros(xht, xwd, numdims);
    for i=1:numdims, Yr(:,:,i) = imresize(Y(:,:,i), [xht xwd], 'nearest'); end
    Y = Yr;
    clear Yr;
end
