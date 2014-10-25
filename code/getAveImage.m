function aveImg = getAveImage(part,im_crop,vis_flg)

    figsize = 5;
    resImg = uint32(im_crop{1});
    if size(resImg,3) < 3
    	resImg = cat(3,resImg ,resImg, resImg);
    end;

    sumImg = resImg;
    [h , w, ~] = size(sumImg);
    for iii = 2 :   length(im_crop)
        resImg = imresize(im_crop{iii},[h,w]);
	if size(resImg,3) < 3
		resImg = cat(3,resImg ,resImg, resImg);
	end;
        sumImg = sumImg + uint32(resImg);
    end
    aveImg = sumImg / length(im_crop);
    if vis_flg
        subplot(figsize,figsize,4); showboxes(uint8(aveImg),[0 0 0 0]); %imshow(uint8(aveImg));
        
%         category = 'horse';
%         dir_class = 'mountain_horse_super';
%         component = 1;
%         savehere = ['/home/moin/Desktop/UW/all_UW/eccv14/data/part_selected/',category,'/',dir_class,'/',num2str(component),'/'];
%         mkdir([savehere,'figures/']);
%         saveas(gcf, [savehere,'figures/','averagePatches_llda-',num2str(part),'.png']);
%         close all;        
        
    end

end
