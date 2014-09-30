function resp = analyzeROC(roc)
% given a pr curve, you want to know at each point of recall: the #true
% positives found and #false positives accepted

try
rec = roc.r;
prec = roc.p;
rtp = roc.tp;
rfp = roc.fp;

tp = [];
fp = [];
sind = [];
vals = [];
for t=0:0.1:1
    %tp=[tp min(rtp(rec>=t))];
    %fp=[fp min(rfp(rec>=t))];
    ind = find(rec>=t,1);
    if ~isempty(ind)
        vals = [vals t];
        tp=[tp rtp(ind)];
        fp=[fp rfp(ind)];
        sind = [sind ind];
    end
end
resp = [vals; tp; fp; sind]';

catch
    disp(lasterr); keyboard;
end
