function write_detect_infile_topn(voc_detect,ids,relpos_patch,detrespath,file_name,top_n,med_flg)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fid=fopen(sprintf(detrespath,file_name,'horse'),'w');

for img=1:length(voc_detect)
    img;
    bbox_detected = [];
    score_detected = [];
    relpos_patch_detected = [];
    
    score_all = vertcat(voc_detect{img}.scores{:});
    [sortedValues_score,sortIndex_score] = sort(score_all,'descend');
    maxIndex_score = sortIndex_score(1:top_n);    

    
    for prt = 1:top_n
        part = maxIndex_score(prt);
        bbox_detected{prt} = voc_detect{img}.parts{part};
        score_detected(prt) = voc_detect{img}.scores{part};
        relpos_patch_detected{prt} = relpos_patch{part};
    end    

    gtbox_detected = inv_relpos_p2gt(bbox_detected,relpos_patch_detected);
        
    pred = vertcat(gtbox_detected{:});
    pred_med = median(pred); %cluster gtboxes
    sco = score_detected;%vertcat(score_detected{:});
    score_med = median(sco);
    
%     showboxes(imread(voc_test(img).im),pred_med);
%     saveas(gcf, ['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/',dir_class,'/BB/AllPatch/pred/predictedBB_',voc_test(img).im(end-9:end)]);
%     close all;
%     
%     showboxes(imread(voc_test(img).im),pred);
%     saveas(gcf, ['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/',dir_class,'/BB/AllPatch/hyp/hyp_',voc_test(img).im(end-9:end)]);
%     close all;
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

% close results file
fclose(fid);


end

