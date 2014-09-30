function [part_selected, score_all] = subcategory_patch_selection(rep_score,disc_score,rep_w,disc_w,top_num_part)

n_part = size(rep_score,2);
% multiply descrimination power and representation power of each part
% score_all = patch_precision .* patch_app_norm; 
%score_all = rep_w.*rep_score + disc_w.*disc_score;
score_all = rep_w.*rep_score .* disc_w.*disc_score;

part_selected = zeros(1,n_part);

[score_sortedValues,score_sortIndex] = sort(score_all,'descend');
score_maxIndex = score_sortIndex(1:top_num_part);
part_selected(score_maxIndex) = 1;