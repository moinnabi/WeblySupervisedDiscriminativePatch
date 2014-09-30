function [part_selected, score_all, patch_precision] = select_patch(ps_score,ng_score,sp_consistant_parts,top_num_part)

%parameters
w_sp = 0.5; %importance of normalized spatial consistancy
w_app = 0.5; %importance of normalized appreatance consistancy
precision_thersh = 0.25; %compute precision in top 25% of retrived images


n_img = size(ps_score,1); %number of positive images
%n_img_neg = length(ng_detect);
n_part = size(ps_score,2); %equal to numPatch

patch_precision = zeros(1,n_part);

for prt = 1:n_part
    [~,prec_ps_sortIndex_img] = sort([ps_score(:,prt);ng_score(:,prt)],'descend');
    tp = length(find(prec_ps_sortIndex_img(1:2*n_img*precision_thersh) <= n_img));
    fp = 2*n_img*precision_thersh - tp;
    patch_precision(prt) = tp/(tp+fp);
end


for prt = 1:n_part
    
    normalized_app_score(prt) = (1-(max(patch_precision)-patch_precision(prt))/(max(patch_precision)-min(patch_precision)));
    normalized_sp_score(prt) = (1-(max(sp_consistant_parts)-sp_consistant_parts(prt))/(max(sp_consistant_parts)-min(sp_consistant_parts)));
    score_all(prt) = w_app*normalized_app_score(prt) + w_sp*normalized_sp_score(prt);
end

    part_selected = zeros(1,n_part);

    [score_sortedValues,score_sortIndex] = sort(score_all,'descend');
    score_maxIndex = score_sortIndex(1:top_num_part);
    part_selected(score_maxIndex) = 1;
end