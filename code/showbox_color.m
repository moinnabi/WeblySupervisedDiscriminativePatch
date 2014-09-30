function showbox_color(im,bbox,color,width,style,transparent)
%by Moin Nabi
bbox_num = size(bbox,1);
if ~transparent
    imshow(im);
    hold;
else
    hold;
end
for i = 1:bbox_num
    rect = [ bbox(i,1) , bbox(i,2) , bbox(i,3)-bbox(i,1) , bbox(i,4)-bbox(i,2)];
    rectangle('Position',rect,'EdgeColor',color(i),'LineWidth',width,'LineStyle',style);
end