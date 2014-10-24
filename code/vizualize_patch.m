function vizualize_patch(ps,patch_per_comp,voc_ng_train,fig_dir)
% This function is to show selected patch per each subcategory

%reloading
I=patch_per_comp.I; bbox=patch_per_comp.bbox; gtbox=patch_per_comp.gtbox;
ps_detect = patch_per_comp.ps_detect; ps_score = patch_per_comp.ps_score;
ng_detect = patch_per_comp.ng_detect; ng_score = patch_per_comp.ng_score;
patch_selected = patch_per_comp.patch_selected;
%
models_all = patch_per_comp.models_all; %models = patch_per_comp.models;
%
total_score = patch_per_comp.total_score;
disc_score = patch_per_comp.disc_score;
rep_score = patch_per_comp.rep_score;
%
numPatches = size(models_all,2); top_num_part = length(find(patch_per_comp.patch_selected));


%
% relpos_patch_normal = patch_per_comp.relpos_patch_normal;
% deform_param_patch = patch_per_comp.deform_param_patch;
% ps = patch_per_comp.ps;



%for i=1:length(I) I{i} = ['/home/moin/Desktop/UW/all_UW/cvpr_2015/data/result/horse/mountain_horse_super/1/Img/',I{i}(end-15:end)]; end;




visualization_score = total_score;
[~,sortIndex_part] = sort(visualization_score,'descend');
maxIndex_part = sortIndex_part(1:top_num_part);


%switch type
%    case 1 %Visualize
close all;
figure; clf;
figsize = 5;
part_selected_ind = find(patch_selected);

for part=1:min(25,length(part_selected_ind))
    pa = maxIndex_part(part);
    %subplot(sqrt(25),sqrt(25),part); showboxes(imread(I{pa}), [bbox{pa}(1:4); gtbox{pa}]);
    subplot(figsize,figsize,part); showbox_color(imread(I{pa}),gtbox{pa},'b',1,'-',0); showbox_color(imread(I{pa}),bbox{pa},'r',1,'--',1);
    
    str1 = {['DIS:',num2str(disc_score(pa),2),',REP:',num2str(rep_score(pa),2)]}; text(1,1,str1)
end
mkdir(fig_dir);
saveas(gcf, [fig_dir,'selectedPatches_all.jpg']);

%close all;

%     case 2
for part = 1:top_num_part
    close all;
    pa = maxIndex_part(part);
    
    figure;
    figsize = 5;
    top_num_img = min(figsize*(figsize-1),length(ps));
    
    [~,sortIndex_img] = sort([ps_score(:,pa);ng_score(:,pa)],'descend');
    maxIndex_img = sortIndex_img(1:top_num_img);
    
    %     [~,sortIndex_img] = sort(ps_score(:,pa),'descend'); %Just SubCat
    %     maxIndex_img = sortIndex_img(1:top_num_img);
    
    subplot(figsize,figsize,1); showbox_color(imread(I{pa}),gtbox{pa},'b',1,'-',0); showbox_color(imread(I{pa}),bbox{pa},'r',1,'-',1);
    str1 = {['REP:',num2str(rep_score(pa),2)]}; text(1,-30,str1)
    subplot(figsize,figsize,2); visualizeHOGpos(models_all{pa}.w)
    subplot(figsize,figsize,3); visualizeHOGneg(models_all{pa}.w)
    
    clear im_crop;
    imgind_pos = 1;
    
    if top_num_img >0
        for imgind = 1:top_num_img
            if maxIndex_img(imgind) <= length(ps)
                img = imread(ps{1,maxIndex_img(imgind)}.I);
                gt_bbox = ps{1,maxIndex_img(imgind)}.bbox(1:4);
                part_bbox = ps_detect{maxIndex_img(imgind)}.patches{pa}(1:4);
                
                im_crop{imgind_pos} = imcrop(img,[part_bbox(1),part_bbox(2),part_bbox(3)-part_bbox(1),part_bbox(4)-part_bbox(2)]);
                imgind_pos = imgind_pos +1;
                
                subplot(figsize,figsize,imgind+figsize);
                showbox_color(img,gt_bbox,'b',1,'-',0); showbox_color(img,part_bbox,'g',1,'--',1);
                str1 = {['Score:',num2str(ps_score(maxIndex_img(imgind),part),3)]}; text(1,-30,str1)
            else
                img = imread(voc_ng_train(maxIndex_img(imgind)-length(ps)).im);
                %gt_bbox = ps{1,maxIndex_img(imgind)}.bbox(1:4);
                part_bbox = ng_detect{maxIndex_img(imgind)-length(ps)}.patches{pa}(1:4);
                subplot(figsize,figsize,imgind+figsize);
                showboxes(img,part_bbox); rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','y','linewidth', 3);
            end
        end
        
        if ~isempty(im_crop)
            aveImg{part} = getAveImage(part,im_crop,1);
        else
            aveImg{part} = 0;
        end
    end
    %mkdir(fig_dir);
    saveas(gcf, [fig_dir,sprintf('detectedPatches_part_fixedpos_%-2.3d', part),'.png']);
end
%scp moinnabi@robson.cs.washington.edu:/projects/grail/moinnabi/cvpr15/cvpr_2015/data/part_selected/horse/tang_horse_super/2/figures/detectedPatches_part_fixedpos_001.png /home/moin/Desktop/