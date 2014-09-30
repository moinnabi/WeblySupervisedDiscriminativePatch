function [detection_score_part] = run_detection_on_IIT(model_santosh,santosh_thresh, model_selected, dataset, relpos_patch_normal_selected)
% dataset should be stored in a cell
disp('doing part inference');
%clear detection_score_part
parfor i = 1:length(dataset)
    disp([int2str(i),'/',int2str(length(dataset))])
    im_current = imread(dataset(i).im);

    [ds_santosh, ~] = imgdetect(im_current, model_santosh, santosh_thresh);
    nHyp = size(ds_santosh,1);


%     detection_score_part{i} = do_inference(im_current,nHyp,ds_santosh,i)


    for hyp =1:nHyp
        gt_bbox = ds_santosh(hyp,1:4);
        bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);

        [detection_loc , ap_score , sp_score ] = part_inference_inbox_IIT(im_current, model_selected, bbox_current);

        detection_score_part{i}(hyp).sp_scores = sp_score;
        detection_score_part{i}(hyp).ap_scores = ap_score;
        detection_score_part{i}(hyp).patches = detection_loc;        

    end
    
    ddss{i} = ds_santosh;
end







      
%         scores = vertcat(ap_score{:}) .* vertcat(sp_score{:})
%         score_all = sum(scores)
        
        
% 
%     
%     
%     
%     [im_h, im_w, ~] = size(im_current);
% %     ro = 0.07; %inspired by Santosh cvpr'14
% %     bbox_current = [ro*im_w ro*im_h (1-ro)*im_w (1-ro)*im_h];
%     bbox_current = [1 1 im_w im_h];
%     %UW% [detection_score_part{i}.scores, detection_score_part{i}.parts] = part_inference(im_current, model_all, bbox_current);
%     [detection_score_part{i}.scores, ~ , detection_score_part{i}.parts,~] = part_inference(im_current, model_selected, bbox_current);
end





function [ap_score sp_score detection_loc flipped] = part_inference_IIT(input, part_model, regions)


addpath(genpath('dpm-voc-release5/'));

% run detector in each image
% try
%   load(['data/result/ds_',suffix,'.mat'],'ds_santosh');
% catch

  num_ids = length(voc_test);
  ds_out = cell(1, num_ids);
  bs_out = cell(1, num_ids);
  th = tic();
  parfor i = 1:num_ids;
    disp([num2str(i), ' / ' ,num2str(num_ids)]);
    im_current = imread(voc_test(i).im);
    
    
    [ds_santosh, bs] = imgdetect(im, model_santosh, model_santosh.thresh);
    
    nHyp = size(ds_santosh,1)
    
    for i =1:nHyp
        gt_bbox = ds_santosh(i,1:4);
        bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);

        [detection_loc , ap_score , sp_score ] = part_inference_inbox_IIT(im_current, model_selected, bbox_current);
        
    
    
    if ~isempty(bs)
      unclipped_ds = ds_santosh(:,1:4);
      [ds_santosh, bs, rm] = clipboxes(im, ds_santosh, bs);
     
      unclipped_ds(rm,:) = [];

      % NMS
      I = nms(ds_santosh, 0.5);
      ds_santosh = ds_santosh(I,:);
      %bs = bs(I,:);
      %unclipped_ds = unclipped_ds(I,:);

      % Save detection windows in boxes
      ds_out{i} = ds_santosh(:,[1:4 end]);

    else
      ds_out{i} = [];
      %bs_out{i} = [];
    end
  end
  th = toc(th);
  ds_santosh = ds_out;
  %bs = bs_out;
  save(['data/result/ds_',suffix,'.mat'],'ds_santosh');





    im_current = imread([adrs,selected_images{img},'.jpg']);
    gt_bbox = BBox_all(img,:);
    
    bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);
    
    [detection_loc , ap_score , sp_score ] = part_inference_inbox_IIT(im_current, model_selected, bbox_current);
   
   
    all_score = vertcat(ap_score{:}) .* vertcat(sp_score{:});
    feature(img,:) = all_score;