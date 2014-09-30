function [part_selected, score_all, patch_precision,patch_app_norm] = select_patch_inbox(ps_score,ng_score,top_num_part)

%parameters
discrimination_w  = 0.5; %importance of normalized spatial consistancy
representation_w = 0.5; %importance of normalized appreatance consistancy
precision_thersh = 0.25; %compute precision in top 25% of retrived images


n_img = size(ps_score,1); %number of positive images
%n_img_neg = length(ng_detect);
n_part = size(ps_score,2); %equal to numPatch

patch_precision = zeros(1,n_part);

for prt = 1:n_part
    [~,prec_ps_sortIndex_img] = sort([ps_score(:,prt);ng_score(:,prt)],'descend');
    tp = length(find(prec_ps_sortIndex_img(1:2*n_img*precision_thersh) <= n_img));
    fp = 2*n_img*precision_thersh - tp;
    patch_precision(1,prt) = tp/(tp+fp);
end

ps_score_norm =  normalize_matrix(ps_score); % normalize for each part

patch_app = zeros(n_part,1);
for prt = 1:n_part
    %count(prt) = length(find(ps_score_norm(:,prt) >0.5));
    ps_score_norm_sort = sort(ps_score_norm(:,prt),'descend');
    patch_app(prt) = sum(ps_score_norm_sort(2:5));

end

patch_app_norm = normalize_matrix(patch_app)'; % normalize appearance concistancy along different patches
score_all = patch_precision .* patch_app_norm; % multiply descrimination power and representation power of each part

part_selected = zeros(1,n_part);

[score_sortedValues,score_sortIndex] = sort(score_all,'descend');
score_maxIndex = score_sortIndex(1:top_num_part);
part_selected(score_maxIndex) = 1;