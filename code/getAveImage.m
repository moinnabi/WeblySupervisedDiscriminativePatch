function aveImg = getAveImage(part,im_crop,vis_flg)

    figsize = 5;
    sumImg = uint32(im_crop{1});
    [h , w, ~] = size(sumImg);
    for iii = 2 :   length(im_crop)
        resImg = imresize(im_crop{iii},[h,w]);
        sumImg = sumImg + uint32(resImg);
    end
    aveImg = sumImg / length(im_crop);
    if vis_flg
        subplot(figsize,figsize,4); imshow(uint8(aveImg));
        
%         category = 'horse';
%         dir_class = 'mountain_horse_super';
%         component = 1;
%         savehere = ['/home/moin/Desktop/UW/all_UW/eccv14/data/part_selected/',category,'/',dir_class,'/',num2str(component),'/'];
%         mkdir([savehere,'figures/']);
%         saveas(gcf, [savehere,'figures/','averagePatches_llda-',num2str(part),'.png']);
%         close all;        
        
    end

end