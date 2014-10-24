function [ w_sel ] = patch_calibration(patch_per_comp,matfile,cellfile,component,voc_dir,voc9990_dir)

% This function is for calibrating the score of different patch models on a
% validation set provided by VOC 9990
% first extract representation score on samples then train a SVM on the
% output represeantion score of the detections.
%
% BY: MOIN 


model_selected = patch_per_comp.models_selected;
relpos_patch_normal_selected = patch_per_comp.relpos_patch_normal_selected;
%deform_param_patch_selected = patch_per_comp.deform_param_patch_selected;


% Feature and label creation using the output of the patch detector
selected_ind = find(matfile.ds_top(:,5) == component);
selected_samples = matfile.ds_top(selected_ind,:);
selected_images = cellfile(selected_ind,1);
selected_label = selected_samples(:,6);
selected_score = selected_samples(:,7);

pos = length(find(selected_label==1));
neg = length(find(selected_label==-1));

BBox_all = selected_samples(:,1:4);
%

feature = [];
parfor img =1 : length(selected_images)
    img
    switch selected_label(img)
        case 1
            adrs = [voc9990_dir,'VOC9990/JPEGImages/'];
        case -1
            adrs = [voc_dir,'VOC2007/VOCdevkit/VOC2007/JPEGImages/'];
        otherwise
            continue;
    end
    im_current = imread([adrs,selected_images{img},'.jpg']);
    gt_bbox = BBox_all(img,:);
    
    bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);
    
% %    close all;
%     imshow(imcrop_with_padding(im_current,bbox_current{1}));
%     figure; showboxes(im_current,bbox_current{1});
%     figure; imshow(imcrop(im_current,[bbox_current{1}(1),bbox_current{1}(2),bbox_current{1}(3)-bbox_current{1}(1),bbox_current{1}(4)-bbox_current{1}(2)]));
%     figure; imshow(croppos(im_current, bbox_current{1}));
    

    
% USIGN D. HOIM CODE (implemented in UW) -> before retraining by Latent LDA
     addpath(genpath('bcp_release/'));
     [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, model_selected, bbox_current);

%FOR LLDA%    [~ , ap_score , sp_score ] = part_inference_inbox_IIT(im_current, model_selected, bbox_current);
   


%IIT: 3 following lines   
%     inference{img}.sp_scores = sp_score;
%     inference{img}.ap_scores = ap_score;
%     inference{img}.patches = detection_loc;
    
    all_score = vertcat(ap_score{:}) .* vertcat(sp_score{:});
    feature(img,:) = all_score;
end

%[~,~,rep_score] = detect2repscore(inference,1,1,0);


%Feature&Label for training SVM
f_all = [selected_score,feature];
f_all_normal = [selected_score,normalize_matrix(feature)]; %normalize along columns % on each patch
l_all = selected_label;


actication_thershold = 5; %selected by magic

for pos_ind = 1:pos
    if length(find(f_all(pos_ind,:))) > actication_thershold
        pos_sel_ind(pos_ind) = 1;
    else
        pos_sel_ind(pos_ind) = 0;
    end
end

%figure; imshow(imread([adrs,selected_images{8},'.jpg']));


f_selected_pos = f_all(find(pos_sel_ind),:);
f_selected_pos_normal = f_all_normal(find(pos_sel_ind),:);
l_selected_pos = selected_label(find(pos_sel_ind),:);

f_selected = [f_selected_pos ; f_all(pos+1:end,:)];
f_selected_normal = [f_selected_pos_normal ; f_all_normal(pos+1:end,:)];
l_selected = [l_selected_pos ; selected_label(pos+1:end,:)];

TrainLabel = l_selected;
TrainVec = f_selected_normal;


%Full samples
addpath(genpath('libsvm-3.17/matlab/'));

% Cross validation
bestcv = 0;
for log2c = -6:10,
   cmd = ['-v 5 -c ', num2str(2^log2c)];
   cv = svmtrain(TrainLabel,TrainVec, cmd);
   if (cv >= bestcv),
     bestcv = cv; bestc = 2^log2c;
   end
   fprintf('(best c=%g, rate=%g)\n',bestc, bestcv);
end



model_scores_selected = svmtrain(TrainLabel, TrainVec,['-t 0 -c ',num2str(bestc)]);

%non-zero samples
%>>libsvmwrite('libsvm-3.17/data-2_partsize.txt', l_selected, sparse(f_selected_normal)) %run in matlab
%>>python grid.py ../data-2.txt % run in terminal in this directory libsvm-3.17/tools/
%2.0 0.5 96.7118
%model_scores_selected = svmtrain(l_selected, f_selected_normal,'-t 0 -c 32');

w_sel = model_scores_selected.SVs' * model_scores_selected.sv_coef;
b_sel = -model_scores_selected.rho;

if model_scores_selected.Label(1) == -1
    w_sel = -w_sel;
    b_sel = -b_sel;
end



end

