function displayPosStruct2(pos, dispdir)

mymkdir(dispdir); 
for i=1:length(pos)
    myprintf(i,10);
    im = imreadx(pos(i));
    im = draw_box_image(im,getbboxFromPos(pos(i)));
    imwrite(im, [dispdir '/' num2str(i, '%04d') '.jpg']);
end
myprintfn;
