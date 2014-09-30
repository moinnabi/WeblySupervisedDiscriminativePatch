function plotCurve(st)

if 1
DET = st;
loglog(DET.fp,DET.mr,'-');
set(gca,'ytick',[0.01 0.02 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1])
grid;
xlabel 'false positive rate'
ylabel 'miss rate'
end

if 1
plot(roc.r, roc.p);
grid;
xlabel 'recall'
ylabel 'precision'
end

if 1
plot(roc.fp/length(roc.fp), roc.r);
grid;
xlabel 'FPR'
ylabel 'TPR'
end