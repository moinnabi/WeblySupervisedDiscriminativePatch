function mim = displayPosStruct(pos)

numpos = length(pos);
[im, mimg] = deal(cell(numpos,1));

for i = 1:numpos  
  %myprintf(i,10);
  im{i} = imreadx(pos(i));  
  mimg{i} = draw_box_image(im{i}, getbboxFromPos(pos(i))); 
end
res = 1000;
mim = montage_list(mimg, 2, [0 0 0], [res res 3]);