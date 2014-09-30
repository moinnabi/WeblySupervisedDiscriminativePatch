function roc = getROCInfoPerComp2_nonjoint(ds_top, cachedir, numComp, recthresh)

%recthresh = 0.3;

% see pascal_test_partialmodel.m
%ds_top = [x1 y1 x2 y2 whichCompFired imgPosOrBgrnd detScore]
mymkdir([cachedir '/display/pr/']);
roc = cell(numComp,1);
for ck = 1:numComp
    thisCompInds = find(ds_top(:,end-2) == ck);      % whichCompFired (out of numComp)
    scores = ds_top(thisCompInds,end);
    labels = ds_top(thisCompInds,end-1);             % 0 => bgrnd, non-zero => positive
    
    % discard indices (images) with no detections by this detector (i.e., init value of -10)
    discardinds = find(labels == -10);
    labels(discardinds) = [];
    scores(discardinds) = [];
    
    labels(labels==1) = 1;      % now set that ngram imgs as positives    
    labels(labels==0) = -1;     % set bgrnd imgs as negative
    
    pr = computePR(scores, labels, recthresh);
    
    roc{ck}.npos = length(find(labels==1));
    roc{ck}.r = pr.rec;
    roc{ck}.p = pr.prec;
    roc{ck}.recthresh = pr.recthresh;
    roc{ck}.scores = sort(scores, 'descend');
    roc{ck}.ap_new = pr.ap;
    roc{ck}.ap_full_new = pr.ap_full;
    fname = [cachedir '/display/pr/' num2str(ck) '_ngram.jpg'];
    if ~exist(fname, 'file')
        clf;        
        plot(pr.rec, pr.prec, 'r','LineWidth', 10);
        if ~isempty(recthresh)
            hold on
            ind = find(pr.rec<=pr.recthresh,1,'last');
            plot(pr.rec(1:ind), pr.prec(1:ind), 'b', 'LineWidth', 10);
        end
        hgcf = legend(num2str(pr.ap_full*100), [num2str(pr.ap*100) ' ' num2str(roc{ck}.npos)]);
        title([num2str(ck)]);
        set(hgcf,'FontSize',24);
        set(gca,'FontSize',24); set(gca,'FontWeight','bold');        
        %disp('check linewidth & font ok'); keyboard;
        saveas(gcf, fname);
    end    
end 

% montage doesnt work on frame.cs 
%system(['montage ' [cachedir '/display/pr/*.jpg'] ' ' [cachedir '/display/pr/pr_montage.jpg']]);
mimg = cell(numComp, 1);
for ck=1:numComp
    fname = [cachedir '/display/pr/' num2str(ck) '_ngram.jpg'];
    mimg{ck} = imread(fname);
end
mim = montage_list(mimg, 2, [], [3000 3000 3]); 
imwrite(mim, [cachedir '/display/pr/pr_montage.jpg'])   

myprintfn;
close all;
