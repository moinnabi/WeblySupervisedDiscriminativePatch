function roc = getROCInfo(ds_top, cachedir, phrasenames)

roc = [];
for c=1:numel(ds_top)
    myprintf(c,10);
    scores = ds_top{c}(:,end);
    labels = ds_top{c}(:,end-1);    
    
    % discard indices with -10
    discardinds = find(labels == -10);
    labels(discardinds) = [];
    scores(discardinds) = [];
    
    if 0
        labels(labels~=0) = 1;  % base horse as gtruth
    else
        % ngram horse as gtruth
        otherinds = find(labels~=0 & labels~=c);   % fist discard all other ngrams
        labels(otherinds) = [];
        scores(otherinds) = [];
        labels(labels==c) = 1;      % now set that ngram as positives
    end
    
    labels(labels==0) = -1;     % set bgrnd as negative
    
    pr = computePR(scores, labels);
    
    roc{c}.r = pr.rec;
    roc{c}.p = pr.prec;
    roc{c}.scores = sort(scores, 'descend');
    roc{c}.ap_new = pr.ap;
    fname = [cachedir '/display/pr/' phrasenames{c} '_ngram.jpg'];
    if ~exist(fname, 'file')
        plot(pr.rec, pr.prec); 
        legend(num2str(pr.ap*100));
        %saveas(gcf, [cachedir '/display/pr/' phrasenames{c} '_base.jpg']);
        saveas(gcf, fname);
    end
    
end
myprintfn;
