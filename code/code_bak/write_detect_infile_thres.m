function write_detect_infile_thres(voc_detect,ids,relpos_patch,detrespath,file_name,detection_thre,med_flg)

fid=fopen(sprintf(detrespath,file_name,'horse'),'w');

for img=1:length(voc_detect)
    %img = 200
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
%     im_current = imread(voc_test(img).im);
%     figure; subplot(2,2,1); showboxes(im_current,pred); text(1,1,'predicted BB','FontSize',18);
%     
%     pred_top = nms_tomasz(pred, 0.1);
%     subplot(2,2,2); showboxes(im_current,pred_top); text(1,1,'NMS','FontSize',18);

    pred_med = median(pred,1); %cluster gtboxes
%     subplot(2,2,3); showboxes(im_current,pred_med); text(1,1,'Median','FontSize',18);
    
     %cluster
%     box_num = 2;
%     [IDX,pred_med_all,sumd,D] = kmeans(pred,box_num);
%     subplot(2,2,4); showboxes(im_current,pred_med_all); text(1,1,'Clustering','FontSize',18);
%     savehere = 'data/figure/medianVSclustering/';
%     saveas(gcf, [savehere,'medianVSclustering_',num2str(img),'.png']);
%     close all;
end
    for box_ind = 1 : box_num
        pred_med = pred_med_all(box_ind,:);
        score_med = score_detected*D(:,box_ind);
    %
        if ~isempty(pred_med)
            if med_flg
                fprintf(fid,'%s %f %d %d %d %d\n',ids{img},score_med,pred_med);
            else
            % write to results file
                for j=1:length(sco)
                    fprintf(fid,'%s %f %d %d %d %d\n',ids{img},sco(j),pred(j,:));
                end
            end
        end
    end
end

% close results file
fclose(fid);

