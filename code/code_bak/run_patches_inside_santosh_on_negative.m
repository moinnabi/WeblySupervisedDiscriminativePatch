function [ng_detect] = run_patches_inside_santosh_on_negative(model_santosh,models_all,voc_ng_train,relpos_patch_normal,thresh)

ng_detect = cell(1,length(voc_ng_train));

parfor i = 1:length(voc_ng_train)
    disp([int2str(i),'/',int2str(length(voc_ng_train))])
    im_current = imread(voc_ng_train(i).im);
    %
    %addpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/features/');
    %
    ds = run_santosh_on_img(model_santosh,im_current,thresh)

    if ~isempty(ds)
        %bbox_current = [1 1 im_w im_h];
        
        %for j = 1:size(ds,1)
        j = 1; % just consider the top detected object
            gt_bbox = ds(j,1:4);
            bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal,1);
            addpath('bcp_release/inference/')
            [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, models_all, bbox_current);
            ng_detect{i}.scores = num2cell(horzcat(ap_score{:}).*horzcat(sp_score{:}));
            ng_detect{i}.parts = detection_loc;
        %end
    end
end