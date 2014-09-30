function [ds_santosh_rescored,scores_all_rescored] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santosh,w_sel,suffix)
% function for rescoring bounding box of santosh by parts defined by moin

ds_santosh_rescored = ds_santosh;
%scores_all_rescored = [];
clear scores_all_rescored;

ds_adrs = [];
ds_ind = 1;
for i=1:length(ds_santosh)
    if ~isempty(ds_santosh{i})
        for j = 1:size(ds_santosh{i},1)
            ds_adrs(ds_ind,:) = [i,j];
            santosh_score(ds_ind,:) = ds_santosh{i}(j,5);
            ds_ind = ds_ind + 1;
        end
    end
end

%disp('checking Moins parts inside box');
try
    %load('data/scores_all_rescored.mat','scores_all_rescored');  
    load(['data/',suffix,'.mat'],'scores_all_rescored');
catch
    parfor i = 1:length(ds_santosh)%length(voc_test)
        disp([int2str(i),'/',int2str(length(voc_test))])

        if ~isempty(ds_santosh{i})

            im_current = imread(voc_test(i).im);
            gt_bbox_all = ds_santosh{i}(:,1:4);
            
            tmp = compute_score_per_sample(ds_santosh{i},gt_bbox_all,relpos_patch_normal_selected,im_current, model_selected)
            
            scores_all_rescored{i} = tmp;
        end
    end
    save(['data/',suffix,'.mat'],'scores_all_rescored');
end
moin_score_all = vertcat(scores_all_rescored{:});
moin_score = normalize_matrix(moin_score_all);
score_all = [santosh_score,moin_score] * w_sel;
%
for ind = 1:ds_ind-1
    i = ds_adrs(ind,1);
    j = ds_adrs(ind,2);
    ds_santosh_rescored{i}(j,5) = score_all(ind);
end