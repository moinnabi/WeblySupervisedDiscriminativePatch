function [detection_score_part] = run_detection_on_IIT(model_all,dataset)
% dataset should be stored in a cell
disp('doing part inference');
parfor i = 1:length(dataset)
    disp([int2str(i),'/',int2str(length(dataset))])
    im_current = imread(dataset(i).im);
    [im_h, im_w, ~] = size(im_current);
%     ro = 0.07; %inspired by Santosh cvpr'14
%     bbox_current = [ro*im_w ro*im_h (1-ro)*im_w (1-ro)*im_h];
    for j = 1:25    
        bbox_current{j} = [1 1 im_w im_h];
    end
    %UW% [detection_score_part{i}.scores, detection_score_part{i}.parts] = part_inference(im_current, model_all, bbox_current);
%    [detection_score_part{i}.scores, ~ , detection_score_part{i}.parts,~] = part_inference(im_current, model_all, bbox_current);
    %[detection_score_part{i}.scores, ~ , detection_score_part{i}.parts,~] 
    [detection_loc , ap_scores , sp_scores ] = part_inference_inbox_IIT(im_current, model_all, bbox_current);
end
