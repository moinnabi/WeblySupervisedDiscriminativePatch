function [ds_santoshONmoin] = santosh_rescoring_moin(ds_moin,voc_test,model_santosh,thresh)

addpath(genpath('dpm-voc-release5/'));

ds_santoshONmoin = ds_moin;
num_ids = length(voc_test);
parfor i = 1:num_ids
    disp([num2str(i), ' / ' ,num2str(num_ids)]);
    im = imread(voc_test(i).im);
    [im_h, im_w, ~] = size(im);
    bbox_im = [1 1 im_w-1 im_h-1];
    

    if ~isempty(ds_moin{i})
        ds_santoshONmoin{i}(:,5) = 0;
        ds_m = ds_moin{i}(:,1:4);
        for rect = 1: size(ds_m,1)
            %deform = 10;
            a = [ds_m(rect,1) , ds_m(rect,2) , ds_m(rect,3)-ds_m(rect,1) , ds_m(rect,4)-ds_m(rect,2)];
            if (rectint(a,bbox_im) == a(3)*a(4))
                %im_crop = imcrop(im,a);

                [im_crop, boxes] = croppos(im, ds_m(rect,1:4));
                fg_overlap = 0.9;
                [pyra, model_dp] = gdetect_pos_prepare(im_crop, model_santosh, boxes, fg_overlap);
                [ds_s, ~, ~] = gdetect_pos(pyra, model_dp, 1, boxes,fg_overlap, bbox_im, 1);
                
                %[ds, ~, ~] = gdetect(pyra, model_dp, -1.5);
                %[ds_s, ~,~] = imgdetect(im_crop, model_santosh,-1.5);
                if ~isempty(ds_s)
                    ds_santoshONmoin{i}(rect,5) = ds_s(1,6);
                    %figure; showboxes(im_crop,ds_s(:,1:4));
                end
            end
        end
    end
end
    
%%    
%     threshold = 0.75;
%     for th= -1:0.01:-1.5
%         for i = 1: size(ds_m,1)
%             a = [ds_m(i,1) , ds_m(i,2) , ds_m(i,3)-ds_m(i,1) , ds_m(i,4)-ds_m(i,2)];
%             [ds_s, ~,~] = imgdetect(im, model_santosh, th);
%             for j = 1 : size(ds_s,1)
%                 b = [ds_s(j,1) , ds_s(j,2) , ds_s(j,3)-ds_s(j,1) , ds_s(j,4)-ds_s(j,2)];
%                 intersect = rectint(a,b);
%                 union = a(3)*a(4) + b(3)*b(4) - intersect;
%                 overlap = intersect / union;%intersection over union
%                 if overlap > threshold;
%                     continue;
%                 %sp_overlap(i,j) = intersect / union;%intersection over union
%                 %dist(i,j) = sqrt(sum((ds_s(j,1:4)-ds_m(i,:)) .^ 2));
%             end
%             if overlap(i,j) > threshold;
%                     continue;
%                 else
%             
%         [V,I] = max(sp_overlap(i,:))
%             end
%             
% 
%    
%    for th= -1:0.01:-1.5
%        
%        [ds_s, ~,~] = imgdetect(im, model_santosh, th);
       