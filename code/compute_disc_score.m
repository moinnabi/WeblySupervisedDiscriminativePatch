function [patch_image_score_ps,patch_image_score_ng,disc_score] = compute_disc_score(ps_detect,ng_detect,sp_w,ap_w,precision_thersh)
% Compute discriminative score using the precision creteria
% sp_w: weight for spatial_consistancy (default: 1)
% ap_w: weight for appearance_consistancy (default: 1)
% compute precision in top 25% of retrived images

[ps_sp_score,ps_ap_score,ps_score] = detect2repscore(ps_detect,sp_w,ap_w,0);
[ng_sp_score,ng_ap_score,ng_score] = detect2repscore(ng_detect,sp_w,ap_w,0);

n_img = size(ps_score,1); %number of positive images
n_part = size(ps_score,2); %equal to numPatch

patch_precision = zeros(1,n_part);

for prt = 1:n_part
    [~,prec_ps_sortIndex_img] = sort([ps_score(:,prt);ng_score(:,prt)],'descend');
    tp = length(find(prec_ps_sortIndex_img(1:uint16(2*n_img*precision_thersh)) <= n_img));
    fp = 2*n_img*precision_thersh - tp;
    patch_precision(1,prt) = tp/(tp+fp);
end

disc_score = patch_precision;

patch_image_score_ps = ps_score; % NOT normalize for each part
patch_image_score_ng = ng_score; % NOT normalize for each part
% patch_image_score_ps = normalize_matrix(ps_score); % normalize for each part
% patch_image_score_ng = normalize_matrix(ng_score); % normalize for each part
