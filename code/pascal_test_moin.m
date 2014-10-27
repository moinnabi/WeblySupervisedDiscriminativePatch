function [ds_moin_median] = pascal_test_moin(model_selected,voc_test,relpos_patch_normal_selected,detection_thre,finalresdir,suffix)

addpath(genpath('bcp_release/'));

  disp('pascal_test_moin');

try
    load([finalresdir,suffix,'.mat'],'ds_moin');
catch
    [ds_moin] = run_detection_on(model_selected,voc_test);
    save([finalresdir,suffix,'.mat'],'ds_moin');
    
end

relpos_patch = relpos_patch_normal_selected;
voc_detect = ds_moin;

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
    
    if size(bbox_detected,1) > 0
        gtbox_detected = inv_relpos_p2gt(bbox_detected,relpos_patch_detected);
        pred = vertcat(gtbox_detected{:});
        score = score_detected';
        ds_moin_median{img} = [pred,score];
        
    else
        ds_moin_median{img} = [];
    end
end
end
