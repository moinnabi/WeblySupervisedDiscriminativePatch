function [ds_moin_all] = pascal_test_moin(model_selected,voc_test,relpos_patch_normal_selected,detection_thre,suffix)

addpath(genpath('bcp_release/')); 
%following 6 lines commented in IIT
try
  load(['data/result/ds_',suffix,'.mat'],'ds_moin_all');
catch
    [voc_test_detect] = run_detection_on(model_selected,voc_test);


%    [voc_test_detect] = run_detection_on(model_selected,voc_test);

    
    %detrespath = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/results/VOC2007/Main/%s_det_val_%s.txt';
    %file_name = 'test-1';

    %fid=fopen(sprintf(detrespath,file_name,'horse'),'w');
    %detection_thre = 120;
%     voc_test_detect_norm = normalize_matrix(
%     vertcat(voc_detect{img}.scores{:});
    
    relpos_patch = relpos_patch_normal_selected;
    voc_detect = voc_test_detect;
    
    parfor img=1:length(voc_detect)
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

        ds_moin_all{img} = [pred,score];

    end
      save(['data/result/ds_',suffix,'.mat'],'ds_moin_all');
%end    
end