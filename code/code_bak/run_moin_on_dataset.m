function [ds_moin] = run_moin_on_dataset(model_selected,voc_test)

fid=fopen(sprintf(detrespath,file_name,'horse'),'w');

for img=1:length(voc_detect)
    %img = 22
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


%disp('doing part inference');
parfor i = 1:length(voc_test)
    disp([int2str(i),'/',int2str(length(voc_test))])
    im_current = imread(voc_test(i).im);
    [im_h, im_w, ~] = size(im_current);
%     ro = 0.07; %inspired by Santosh cvpr'14
%     bbox_current = [ro*im_w ro*im_h (1-ro)*im_w (1-ro)*im_h];
    bbox_current = [1 1 im_w im_h];
    [sc(i,:), bb(i,:)] = part_inference_inbox(im_current, model_selected, bbox_current);
    ds_out{i} = bb(:,[1:4 end]);
    ds_out{i} = sc(:,[5 end]);
end

    
end

