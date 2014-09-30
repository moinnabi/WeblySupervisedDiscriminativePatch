function pr = computePR_oldap(out, gt)

% this script is not being used. its correctness is not gauranteed

% compute precision/recall
[so,si]=sort(-out);
tp=gt(si)>0;
fp=gt(si)<0;

fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/sum(gt>0);
prec=tp./(fp+tp);

pr.rec = rec;
pr.prec = prec;
pr.r = rec;
pr.p = prec;

ap = averagePrecision2(roc, (0:0.1:1));

pr.ap = ap;
