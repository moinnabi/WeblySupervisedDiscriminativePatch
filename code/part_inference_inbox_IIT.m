function [detection_loc , ap_scores , sp_scores ] = part_inference_inbox_IIT(im_current, model_selected, bbox_current)
% This funciton find the appearance and spatial score after running
% model_select inside bbox_current (repectively) on im_current 
% model_select: DPM-like models trained using LLDA
% bbox_current: pascal-like bounding boxes inside the image
%
% BY: MOIN

    for pa = 1:length(bbox_current)
        [imCrop{pa} gt_bb{pa}] = croppos(im_current, bbox_current{pa});
        ds = run_dpm_on_img(model_selected{pa},imCrop{pa},model_selected{pa}.thresh);
        
        if ~isempty(ds)
            b = [gt_bb{pa}(1) , gt_bb{pa}(2) , gt_bb{pa}(3)-gt_bb{pa}(1) , gt_bb{pa}(4)-gt_bb{pa}(2)];            
            spap_max = -100;  
            
            for d = 1:size(ds,1)
                
               ap = ds(d,6);
               det_loc = ds(d,1:4);
               a = [det_loc(1) , det_loc(2) , det_loc(3)-det_loc(1) , det_loc(4)-det_loc(2)];

               intersect = rectint(a,b);
               union = a(3)*a(4) + b(3)*b(4) - intersect;
               sp = intersect / union; %intersection over union %%%%%UUUWWWW
               
               if sp .* ap > spap_max  % get the sp and ap with the largest value of sp .* ap
                   spap_max = sp .* ap;
                   ap_scores{pa} = ap;
                   detection_loc{pa} = bbox_current{pa};%det_loc; % NOT TRUE
                   sp_scores{pa} = sp;
               end
            end
        else
           ap_scores{pa} = 0;
           detection_loc{pa} = [];
           sp_scores{pa} = 0;
        end;
     end
    
    
    % for mdl = 1:25
%     ddss = run_santosh_on_img(model_selected{mdl},imCrop,model_selected{mdl}.thresh);
%     if ~isempty(ddss)
%         mdl
%         figure; showboxes(imCrop,ddss(:,1:4))
%     end
% end
