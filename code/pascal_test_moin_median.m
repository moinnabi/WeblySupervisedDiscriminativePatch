function [ds_moin_median] = pascal_test_moin_median(model_selected,voc_test,relpos_patch_normal_selected,detection_thre,suffix)

addpath(genpath('bcp_release/')); 
% 
% try
%     load('data/imgdata_VOC_test.mat', 'voc_test_detect');
% catch
%     [voc_test_detect] = run_detection_on(model_selected,voc_test);
%     save('data/imgdata_VOC_test.mat', 'voc_test_detect');
% end
    
try
  load(['data/result/ds_',suffix,'.mat'],'ds_moin_median');
catch
    [voc_test_detect] = run_detection_on(model_selected,voc_test);

    %detrespath = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/results/VOC2007/Main/%s_det_val_%s.txt';
    %file_name = 'test-1';

    %fid=fopen(sprintf(detrespath,file_name,'horse'),'w');
    %detection_thre = 120;
%     voc_test_detect_norm = normalize_matrix(
%     vertcat(voc_detect{img}.scores{:});
    
    relpos_patch = relpos_patch_normal_selected;
    voc_detect = voc_test_detect;
    
    for img=1:length(voc_detect)
        bbox_detected = [];
        score_detected = [];
        relpos_patch_detected = [];
        prt_ind = 1;

        for prt = 1:length(voc_detect{1}.scores)%#patches
            if voc_detect{img}.scores{prt} > detection_thre
                bbox_detected{prt_ind} = voc_detect{img}.parts{prt};
                score_detected(prt_ind) = voc_detect{img}.scores{prt};
                relpos_patch_detected{prt_ind} = relpos_patch{prt};
                prt_ind = prt_ind+1;
            end
        end
        
        gtbox_detected = inv_relpos_p2gt(bbox_detected,relpos_patch_detected);

        
        pred = vertcat(gtbox_detected{:});
        score = score_detected';
        if ~isempty(pred)
            pred_med = median(pred,1);
            score_med = median(score);

            %cluster gtboxes
            ds_moin_median{img} = [pred_med,score_med];
        else
            ds_moin_median{img} = [];
        end

    end
      save(['data/result/ds_',suffix,'.mat'],'ds_moin_median');
end