function roc = getROCInfoPerComp2(ds_top, cachedir, phrasenames, numComp, recthresh)
% roc datastruct is roc(c,ck) instead of roc(c*6+ck) here

%recthresh = 0.3;

%ds_top = [x1 y1 x2 y2 imgid whichCompFired imgBelongsToWhichCompOfNgam imgBelongsToWhichNgram detScore]
mymkdir([cachedir '/display/pr/']); 
roc = cell(numel(ds_top),numComp);
for c=1:numel(ds_top)
    myprintf(c,10);
    if ~isempty(ds_top{c})              % if debugging, some ngrams will be empty
        for ck = 1:numComp
            thisCompInds = find(ds_top{c}(:,end-3) == ck);      % whichCompFired (out of numComp)
            scores = ds_top{c}(thisCompInds,end);
            labels = ds_top{c}(thisCompInds,end-1);             % 0 => bgrnd, non-zero => positive
            
            % discard indices (images) with no detections by this detector (i.e., init value of -10)
            discardinds = find(labels == -10);
            labels(discardinds) = [];
            scores(discardinds) = [];
            
            if 0                        % base horse as gtruth
                labels(labels~=0) = 1;  
            else                        % ngram horse as gtruth
                otherinds = find(labels~=0 & labels~=c);        % fist discard all (val) images belonging to other ngrams
                labels(otherinds) = []; 
                scores(otherinds) = [];
                labels(labels==c) = 1;                          % now set that ngram imgs as positives
            end
            
            labels(labels==0) = -1;     % set bgrnd imgs as negative
            
            pr = computePR(scores, labels, recthresh);
            
            roc{c,ck}.npos = length(find(labels==1));
            roc{c,ck}.r = pr.rec;
            roc{c,ck}.p = pr.prec;
            roc{c,ck}.recthresh = pr.recthresh;
            roc{c,ck}.scores = sort(scores, 'descend');
            roc{c,ck}.ap_new = pr.ap;
            roc{c,ck}.ap_full_new = pr.ap_full;
            fname = [cachedir '/display/pr/' phrasenames{c} '_' num2str(ck) '_ngram.jpg'];
            if ~exist(fname, 'file')
                clf;
                plot(pr.rec, pr.prec, 'r','LineWidth', 10);
                if ~isempty(recthresh)
                    hold on
                    ind = find(pr.rec<=pr.recthresh,1,'last');
                    plot(pr.rec(1:ind), pr.prec(1:ind), 'b', 'LineWidth', 10);
                end
                legend(num2str(pr.ap_full*100), [num2str(pr.ap*100) ' ' num2str(roc{c,ck}.npos)]);
                title([phrasenames{c} ' ' num2str(ck)]);
                set(gca,'FontSize',24); set(gca,'FontWeight','bold');
                disp('check linewidth & font ok'); keyboard;    
                saveas(gcf, fname);
            end
        end
    end
end
myprintfn;
