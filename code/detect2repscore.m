function [sp_score_all_norm,ap_score_all_norm,rep_score_all] = detect2repscore(detect_struct,sp_w,ap_w,norm_flag)
%detection struct as input compute normalized matrix of sp and ap as well
%as computing represeantation score as multiply over normalized
% spatial/appearance consistancy
%
% sp_w: weight for spatial_consistancy
% ap_w: weight for appearance_consistancy
% norm_flag: flag to do/not the normalization over patchs (default: 0)
% by: Moin Nabi

img_num = length(detect_struct);
numPatches = length(detect_struct{1}.sp_scores);

sp_score_all = zeros(img_num,numPatches);
ap_score_all = zeros(img_num,numPatches);
for img = 1:img_num
    if  ~isempty(detect_struct{img})
        sp_score_all(img,:) = horzcat(detect_struct{img}.sp_scores{:});
        ap_score_all(img,:) = horzcat(detect_struct{img}.ap_scores{:});
        %rep_score_all(img,:) = 
    end
end

%Normalization over Patch
if norm_flag == 1
    sp_score_all_norm = normalize_matrix(sp_score_all);
    ap_score_all_norm = normalize_matrix(ap_score_all);    
    
else
    sp_score_all_norm = sp_score_all;
    ap_score_all_norm = ap_score_all;
    
end

rep_score_all = zeros(img_num,numPatches);
for img = 1:img_num
    if  ~isempty(detect_struct{img})
%         rep_score_all(img,:) = ap_w.*ap_score_all_norm(img,:) + sp_w.*sp_score_all_norm(img,:);
         rep_score_all(img,:) = ap_w.*ap_score_all_norm(img,:) .* sp_w.*sp_score_all_norm(img,:);
%        rep_score_all(img,:) = ap_score_all_norm(img,:) .* sp_score_all_norm(img,:);
    end
end