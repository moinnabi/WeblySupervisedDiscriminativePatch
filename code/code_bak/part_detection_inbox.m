function [voc_test_detect] = part_detection_inbox(model_selected,voc_test,bbox_san)
% dataset should be stored in a cell

disp('doing part inference');
parfor i = 1:length(voc_test)
    disp([int2str(i),'/',int2str(length(voc_test))])
    im_current = imread(voc_test(i).im);
    gt_bbox_all = bbox_san{i};
    
    for j = 1:size(bbox_san{i},1)
        gt_bbox = gt_bbox_all(j,:);
        bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);
        [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, model_selected, bbox_current);
        
        all_score = vertcat(ap_score{:}) .* vertcat(sp_score{:});
        
        voc_test_detect{i}.scores{j} = detection_loc;
        voc_test_detect{i}.parts{j} = all_score;
        
    end
    
end