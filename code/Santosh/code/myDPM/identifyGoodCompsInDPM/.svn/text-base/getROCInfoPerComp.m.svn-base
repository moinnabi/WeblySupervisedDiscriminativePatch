function roc = getROCInfoPerComp(ds_top, cachedir, phrasenames, numComp)

roc = [];
for c=1:numel(ds_top)
    myprintf(c,10);
    if ~isempty(ds_top)     % if debugging, some ngrams will be empty
        for ck = 1:numComp
            thisCompInds = find(ds_top{c}(:,end-3) == ck);
            scores = ds_top{c}(thisCompInds,end);
            labels = ds_top{c}(thisCompInds,end-1);
            
            % discard indices with -10
            discardinds = find(labels == -10);
            labels(discardinds) = [];
            scores(discardinds) = [];
            
            if 0
                labels(labels~=0) = 1;  % base horse as gtruth
            else
                % ngram horse as gtruth
                otherinds = find(labels~=0 & labels~=c);    % fist discard all other ngrams
                labels(otherinds) = [];
                scores(otherinds) = [];
                labels(labels==c) = 1;                      % now set that ngram as positives
            end
            
            labels(labels==0) = -1;     % set bgrnd as negative
            
            pr = computePR(scores, labels);
            
            roc{(c-1)*numComp+ck}.r = pr.rec;
            roc{(c-1)*numComp+ck}.p = pr.prec;
            roc{(c-1)*numComp+ck}.scores = sort(scores, 'descend');
            roc{(c-1)*numComp+ck}.ap_new = pr.ap;
            fname = [cachedir '/display/pr/' phrasenames{c} '_' num2str(ck) '_ngram.jpg'];
            if ~exist(fname, 'file')
                plot(pr.rec, pr.prec);
                legend(num2str(pr.ap*100));
                saveas(gcf, fname);
            end
        end
    end
end
myprintfn;
