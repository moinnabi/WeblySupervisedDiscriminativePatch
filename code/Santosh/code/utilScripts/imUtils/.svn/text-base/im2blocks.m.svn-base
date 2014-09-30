function blocks = im2blocks(im, bs, method)
% blocks = im2blocks(im, bs, method)
% note: this is similar to im2col but is much faster when method is
% distinct

if ~exist('method') || isempty(method)
    method = 'sliding';
end

[imh, imw] = size(im);
 
if strcmp(method, 'distinct')
    im = padarray(im, [mod(imh, bs(1)) mod(imw, bs(2))], 'post');
    [imh, imw] = size(im);
    nh = floor(imh/bs(1));
    nw = floor(imw/bs(2));  
    [x, y] = meshgrid((1:bs(2):imw-bs(2)+1), (1:bs(1):imh-bs(1)+1));
elseif strcmp(method, 'sliding')
    nh = imh-bs(1)+1;
    nw = imw-bs(2)+1;    
    [x, y] = meshgrid(1:nw, 1:nh);
else
    error('invalid method: must be "distinct" or "sliding"');
end
y = y(:);
x = x(:);

blocks = zeros([nh*nw prod(bs)], class(im));
for k = 1:prod(bs)
    sx = floor((k-1)/bs(1));
    sy = mod(k-1, bs(1));
    yk = y+sy;
    xk = x+sx;
    blocks(:, k) = im(yk + (xk-1)*imh);
    %ind = yk>0 & xk>0 & yk<=imh & xk<=imw;
    %blocks(ind, k) = im(yk(ind) + (xk(ind)-1)*imh);
end
