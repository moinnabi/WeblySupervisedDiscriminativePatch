function tmp = compute_score_per_sample(ds_img,gt_bbox_all,relpos_patch_normal_selected,im_current, model_selected)
tmp = zeros(size(ds_img,1),size(model_selected,2));
for j = 1:size(ds_img,1)
    gt_bbox = gt_bbox_all(j,:);
    bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);
    [~ , ap_score , sp_score ] = part_inference_inbox(im_current, model_selected, bbox_current);
    score = (vertcat(ap_score{:}) .* vertcat(sp_score{:}))';
    tmp(j,:) = score;
end