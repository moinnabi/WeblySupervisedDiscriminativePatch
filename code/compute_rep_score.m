function [sp_score,ap_score,rep_score] = compute_rep_score(ps_detect,sp_w,ap_w,top_max)
% compute respresenation score from an struct of detections
%
% sp_w: weight for spatial_consistancy (default: 1)
% ap_w: weight for appearance_consistancy (default: 1)
% top_max: the final rep_score is computed using sum over max TOP_MAX detections
% by: Moin Nabi

[sp_score,ap_score,ps_score] = detect2repscore(ps_detect,sp_w,ap_w,0);



n_part = size(ps_score,2); %equal to numPatch

ps_score_norm =  normalize_matrix(ps_score); % normalize for each part

patch_app = zeros(n_part,1);
for prt = 1:n_part
    %count(prt) = length(find(ps_score_norm(:,prt) >0.5));
    ps_score_norm_sort = sort(ps_score_norm(:,prt),'descend');
    patch_app(prt) = sum(ps_score_norm_sort(2:top_max));

end

rep_score = normalize_matrix(patch_app)'; % normalize appearance concistancy along different patches