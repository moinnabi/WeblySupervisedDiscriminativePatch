function [ds_moin] = pascal_test_moin_IIT(model_selected,voc_test,relpos_patch_normal_selected,detection_thre,suffix)

addpath(genpath('dpm-voc-release5/'));

% VOC_root = ['/homes/grail/moinnabi/datasets/PASCALVOC/VOC',testyear,'/VOCdevkit']; addpath([VOC_root '/VOCcode']); VOCinit; cachedir = [VOC_root,'/results/VOC2007/Main/']; ids_2 = textread(sprintf(VOCopts.imgsetpath, testset), '%s');


% run detector in each image
try
  load(['../data/result/ds_',suffix,'.mat'],'ds_moin','ds_pa');
catch
  % parfor gets confused if we use VOCopts
  %opts = VOCopts;
  %num_ids = length(ids);
  num_ids = length(voc_test);
  ds_out = cell(1, num_ids);
  bs_out = cell(1, num_ids);
  th = tic();
  
  %count_ds = zeros(1,length(model_selected));
  
for pa = 1:length(model_selected)
  mdl = model_selected{pa};
  parfor i = 1:num_ids;
    %disp([num2str(i), ' / ' ,num2str(num_ids)]);
    im = imread(voc_test(i).im);
    ds_pa{i,pa} = run_dpm_on_img(mdl,im,mdl.thresh);
  end

end


% for pa = 1:length(model_selected)
%     for i = 1:num_ids
%         ds_pa{i,pa}(:,1:4)
%     end
% end


% for i = 1:num_ids;
%   ds_out{i} = horzcat(ds_pa{i,:});
% end


for img=1:num_ids
    bbox_detected = [];
    bbox_detected_str = [];
    score_detected = [];
    relpos_patch_detected = [];
    relpos_patch_detected_str = [];
    prt_ind = 1;

    for prt = 1:length(model_selected)
        if ~isempty(ds_pa{img,prt})
            bbox_detected{prt_ind} = ds_pa{img,prt}(:,1:4);
            score_detected{prt_ind} = ds_pa{img,prt}(:,6);
            
            stepsize = size(ds_pa{img,prt},1);
            relpos_patch_detected{prt_ind} = repmat(relpos_patch_normal_selected{prt},[stepsize,1]);
            prt_ind = prt_ind + stepsize;
        end
    end
    
    if ~isempty(bbox_detected)
        bbox_detected_all = vertcat(bbox_detected{:});
        relpos_patch_detected_all = vertcat(relpos_patch_detected{:});
        
        for numbb = 1 : size(bbox_detected_all,1)
            bbox_detected_str{numbb} = bbox_detected_all(numbb,:);
            relpos_patch_detected_str{numbb} = relpos_patch_detected_all(numbb,:);
        end
        gtbox_detected = inv_relpos_p2gt_old(bbox_detected_str,relpos_patch_detected_str);        
        pred = vertcat(gtbox_detected{:});
        score = vertcat(score_detected{:})';        
        
        pred_med = median(pred,1);
        score_med = median(score);

        %cluster gtboxes
        ds_moin_median{img} = [pred_med,score_med];
    else
        ds_moin_median{img} = [];
    end
    
end



  save(['../data/result/ds_',suffix,'.mat'],'ds_moin','ds_pa');

end