%visualization



models = models_all;
models = model_retrained;

sel_ind = find(patch_selected);

model_selected = [];
relpos_patch_normal_selected = [];
deform_param_patch_selected = [];
for i = 1:length(sel_ind)
    model_selected{i} = models{sel_ind(i)};
    relpos_patch_normal_selected{i} = relpos_patch_normal{sel_ind(i)};
    deform_param_patch_selected{i} = deform_param_patch{sel_ind(i)};
end


addpath(genpath('bcp_release/'));
parfor i = 1:length(ps)
    disp([int2str(i),'/',int2str(length(ps))])
    im_current = imread(ps{1,i}.I);
    root_bbox = ps{1,i}.bbox;

    bbox_current = inverse_relative_position_all(root_bbox,relpos_patch_normal_selected,1);
%    [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, model_selected, bbox_current);
    [detection_loc , ap_score , sp_score ] = part_inference_inbox_IIT(im_current, model_selected, bbox_current);
     ps_detect{i}.sp_scores = sp_score;
     ps_detect{i}.ap_scores = ap_score;
    %ps_detect{i}.scores = num2cell(horzcat(ap_score{:}).*horzcat(sp_score{:}));
     ps_detect{i}.patches = detection_loc;
end

%ng_detect = ps_detect;
%ps_detect = ps_detect_elda;

[~,~,rep_score] = compute_rep_score(ps_detect,1,1,5);
[ps_score,~,disc_score] = compute_disc_score(ps_detect,ng_detect,1,1,0.25);


% [sortedValues_part,sortIndex_part] = sort(rep_score,'descend'); 
% maxIndex_part = sortIndex_part(1:top_num_part);

%ps_detect_llda = ps_detect;
%ps_detect_elda = ps_detect;


for part = 1:top_num_part
%     close all;
    pa = sel_ind(part);

   figure;
   figsize = 5;
%   top_num_img = min(figsize*(figsize-1),length(find(ps_score(:,part))));%length(ps));
    top_num_img = min(figsize*(figsize-1),length(find(ps_score(:,part)>50)));%length(ps));

    
    %top_num_img = length(find(ps_score(:,part)>50));

    [~,sortIndex_img] = sort(ps_score(:,part),'descend');

    %[sortedValues_img,sortIndex_img] = sort([ps_score(:,prt);ng_score(:,prt)],'descend');
    maxIndex_img = sortIndex_img(1:top_num_img);

    subplot(figsize,figsize,1); showbox_color(imread(I{pa}),gtbox{pa},'b',1,'-',0); showbox_color(imread(I{pa}),bbox{pa},'r',1,'-',1);
    str1 = {['REP:',num2str(rep_score(part),2)]}; text(1,-30,str1)
    %showboxes(imread(I{pa}), bbox{pa}(1:4)); rectangle('Position',[gtbox{pa}(1),gtbox{pa}(2),gtbox{pa}(3)-gtbox{pa}(1),gtbox{pa}(4)-gtbox{pa}(2)],'EdgeColor','b','linewidth', 5);
    subplot(figsize,figsize,2); visualizeHOGpos(models_all{pa}.w)
    subplot(figsize,figsize,3); visualizeHOGneg(models_all{pa}.w)
    
clear im_crop;
    
if top_num_img >0

    for imgind = 1:top_num_img
        
            

            img = imread(ps{1,maxIndex_img(imgind)}.I);
            gt_bbox = ps{1,maxIndex_img(imgind)}.bbox(1:4);
            part_bbox = ps_detect{maxIndex_img(imgind)}.patches{part}(1:4);
            
            im_crop{imgind} = imcrop(img,[part_bbox(1),part_bbox(2),part_bbox(3)-part_bbox(1),part_bbox(4)-part_bbox(2)]);


            subplot(figsize,figsize,imgind+figsize);
            showbox_color(img,gt_bbox,'b',1,'-',0); showbox_color(img,part_bbox,'g',1,'--',1);
            str1 = {['Score:',num2str(ps_score(maxIndex_img(imgind),part),3)]}; text(1,-30,str1)
            
%             if ps_score(maxIndex_img(imgind),part) > 50
%                 rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','g','linewidth', 2);
%             else
%                 rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','r','linewidth', 2);                
%             end
    end

    if length(im_crop)>0
        aveImg{part} = getAveImage(part,im_crop,1);
    else
        aveImg{part} = 0;        
    end
      
end
        
     category = 'horse';
     dir_class = 'mountain_horse_super';
     component = 1;    
    savehere = ['/home/moin/Desktop/UW/all_UW/eccv14/data/part_selected/',category,'/',dir_class,'/',num2str(component),'/'];
    mkdir([savehere,'figures/']);
    saveas(gcf, [savehere,'figures/','detectedPatches_part_fixedpos',num2str(part),'-elda.png']);
    close all;
end

