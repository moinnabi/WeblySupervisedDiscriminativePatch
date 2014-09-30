function DET = computeDET(scores, labels, np, numImg)

[sval, sind] = sort(scores, 'descend');
tp = labels(sind)==1;
fp = labels(sind)==-1;

%DET.fp=cumsum(~tp)/length(tp);
DET.fp=cumsum(~tp)/numImg;
DET.mr=1-cumsum(tp)/np;

if 0
    loglog(DET.fp,DET.mr,'-');
    set(gca,'ytick',[0.01 0.02 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
    grid;
    xlabel 'false positive rate'
    ylabel 'miss rate'
end