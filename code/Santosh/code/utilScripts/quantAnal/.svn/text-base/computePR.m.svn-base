function pr = computePR(out, gt, recthresh)

if nargin < 3
    recthresh = [];
end

% compute precision/recall
[so,si]=sort(-out);
tp=gt(si)>0;
fp=gt(si)<0;

fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/sum(gt>0);
prec=tp./(fp+tp);

if ~isempty(recthresh)
    ind = find(rec<=recthresh,1,'last');
    ap=VOCap(rec(1:ind),prec(1:ind));
    ap_full=VOCap(rec,prec);
else
    ap=VOCap(rec,prec);
    ap_full = ap;
end

pr.rec = rec;
pr.prec = prec;
pr.ap = ap;
pr.ap_full = ap_full;
pr.r = rec;
pr.p = prec;
pr.recthresh = recthresh;
