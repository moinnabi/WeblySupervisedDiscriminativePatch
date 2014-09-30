%%%%MOIN%%%%%    
addpath('bcp_release/');
addpath('Santosh/');
addpath('/projects/grail/moinnabi/eccv14/');
addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/vis/');
run bcp_release/startup;
addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/');
addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/utils/');

%%%%
im_current = imread('/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/VOC2007/JPEGImages/005733.jpg');
%im_current = imread('/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/VOC2007/JPEGImages/008078.jpg');



[im_h, im_w, ~] = size(im_current);
bbox_current = [1 1 im_w im_h];
for ii = 1:5
    for jj = 1:5
        mdl = (ii-1)*5+jj;
        model_part =  model_selected{mdl};
        [scores, parts] = part_inference(im_current, model_part, bbox_current);
%         parpar1 = [];
%         th = 0;
%         for i = 1:length(scores)%25
%             if scores{i} > th
%                 parpar1 = [parpar1;parts{i}];
%             end
%         end
        
        %relpos = relpos_patch_normal_selected{mdl};
        
        predicted_bb = inv_relpos_p2gt_in(parts{1},relpos_patch_normal_selected{mdl});
        
        subplot(5,5,mdl);
        showboxes(im_current,predicted_bb);
        str1 = {['Part #',num2str(mdl),' - Score:',num2str(scores{1})]};
        text(1,1,str1)
    end
end

    
    
%%%%SANTOSH%%%%%
run('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/startup.m');
addpath(genpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/'));
%cd('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/gdetect/');

[ds, bs] = imgdetect(im_current, model_santosh, model_santosh.thresh);
parpar2 = ds(:,1:4);
figure; showboxes(im_current,parpar2)