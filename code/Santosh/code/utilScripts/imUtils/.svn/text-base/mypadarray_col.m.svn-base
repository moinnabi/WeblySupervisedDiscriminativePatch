function im = mypadarray_col(im, destim)

imsiz = size(im);
dimsiz = size(destim);

rowsiz = dimsiz(1)-imsiz(1);
%colsiz = dimsiz(2)-imsiz(2);
rowsiz_pre = floor(rowsiz/2);
if mod(rowsiz,2) ~= 0    
    rowsiz_post = rowsiz_pre+1;
else    
    rowsiz_post = rowsiz_pre;
end
% colsiz_pre = floor(colsiz/2);
% if mod(rowsiz,2) ~= 0    
%     colsiz_post = colsiz_pre+1;
% else    
%     colsiz_post = colsiz_pre;
% end
colsiz_post = 0;
colsiz_pre = 0;

if rowsiz_pre < 0   % need to shrink
    rowsiz_pre = 0; rowsiz_post = 0;
    im = imresize(im, [size(destim, 1) size(im,2)]);
else    
    im = padarray(im, [rowsiz_pre colsiz_pre], 255, 'pre');
    im = padarray(im, [rowsiz_post colsiz_post], 255, 'post');
end