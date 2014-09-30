function [ds_moinONmoin,scores_all_moinONmoin] = moin_rescoring_moin(model_selected,relpos_patch_normal_selected,voc_test,ds_moin,w_sel_moin,suffix)
% function for rescoring bounding box of santosh by parts defined by moin

addpath(genpath('bcp_release/')); 

ds_moinONmoin = ds_moin;
%scores_all_rescored = [];
clear scores_all_moinONmoin;

ds_adrs = [];
ds_ind = 1;
for i=1:length(ds_moin)
    if ~isempty(ds_moin{i})
        for j = 1:size(ds_moin{i},1)
            ds_adrs(ds_ind,:) = [i,j];
            %santosh_score(ds_ind,:) = ds_moin{i}(j,5);
            ds_ind = ds_ind + 1;
        end
    end
end

%disp('checking Moins parts inside box');
try
    %load('data/scores_all_rescored.mat','scores_all_rescored');  
    load(['data/result/',suffix,'.mat'],'scores_all_moinONmoin');
catch
    parfor i = 1:length(ds_moin)
        disp([int2str(i),'/',int2str(length(voc_test))])

        if ~isempty(ds_moin{i})

            im_current = imread(voc_test(i).im);
            gt_bbox_all = ds_moin{i}(:,1:4);
            
            tmp = compute_score_per_sample(ds_moin{i},gt_bbox_all,relpos_patch_normal_selected,im_current, model_selected);
            
            scores_all_moinONmoin{i} = tmp;
        end
    end
    save(['data/result/',suffix,'.mat'],'scores_all_moinONmoin');
end
moin_score_all = vertcat(scores_all_moinONmoin{:});
moin_score = normalize_matrix(moin_score_all);
score_all = moin_score * w_sel_moin;
%
for ind =1:ds_ind-1
    ind;
    i = ds_adrs(ind,1);
    j = ds_adrs(ind,2);
    ds_moinONmoin{i}(j,5) = score_all(ind);
end