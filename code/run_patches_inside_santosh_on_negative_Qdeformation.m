function [ng_detect] = run_patches_inside_santosh_on_negative_Qdeformation(model_santosh,models_all,voc_ng_train,relpos_patch_normal,thresh,deform_param_patch)

ng_detect = cell(1,length(voc_ng_train));

parfor i = 1:length(voc_ng_train)
    disp([int2str(i),'/',int2str(length(voc_ng_train))])
    im_current = imread(voc_ng_train(i).im);
    %
    %addpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/features/');
    ds = run_santosh_on_img(model_santosh,im_current,thresh);


    if ~isempty(ds)

        %for j = 1:size(ds,1)
            j = 1; % just consider the top detected object
            root_bbox = ds(j,1:4);
            bbox_current = inverse_relative_position_all(root_bbox,relpos_patch_normal,1);
            addpath('bcp_release/inference/')
%%            [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, models_all, bbox_current); % UWWW
                [detection_loc , ap_score , sp_score] = part_inference_inbox_Qdeformation(im_current, models_all, bbox_current,root_bbox,deform_param_patch,1);
            %%
            ng_detect{i}.sp_scores = sp_score;
            ng_detect{i}.ap_scores = ap_score;
            %ng_detect{i}.scores = num2cell(horzcat(ap_score{:}).*horzcat(sp_score{:}));
            ng_detect{i}.patches = detection_loc;

        %end
    end
end