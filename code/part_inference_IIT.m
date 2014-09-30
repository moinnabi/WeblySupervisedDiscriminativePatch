function [ap_score sp_score detection_loc flipped] = part_inference_IIT(input, part_model, regions)

    im_current = imread(input);
    
    bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);
    
% %    close all;
%     imshow(imcrop_with_padding(im_current,bbox_current{1}));
%     figure; showboxes(im_current,bbox_current{1});
%     figure; imshow(imcrop(im_current,[bbox_current{1}(1),bbox_current{1}(2),bbox_current{1}(3)-bbox_current{1}(1),bbox_current{1}(4)-bbox_current{1}(2)]));
%     figure; imshow(croppos(im_current, bbox_current{1}));
    

    
% USIGN D. HOIM CODE (implemented in UW) -> before retraining by Latent LDA
%     addpath(genpath('bcp_release/'));
%     [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, model_selected, bbox_current);

    [detection_loc , ap_score , sp_score ] = part_inference_inbox_IIT(im_current, model_selected, bbox_current);
   

