function compareResults_visualization(outdir, outdir_base, objname, testdatatype)

try
    
myroc = load([outdir '/' objname '_' testdatatype '_result_comp.mat'], 'roc_comp');
myroc = myroc.roc_comp;
myrocb = load([outdir_base '/' objname '_' testdatatype '_result_comp.mat'], 'roc_comp');
myrocb = myrocb.roc_comp;

numcomp = numel(myroc);
[rocap, rocapb] = deal(zeros(numcomp,1));
for i=1:numcomp
    if ~isempty(myroc{i})   % 16Apr12: to handle null clusters
        rocap(i) = myroc{i}.ap_new;
        rocapb(i) = myrocb{i}.ap_new;
    end
end
    
diff1 = [rocap-rocapb]*100;
%diff1 = diff1.*(abs(diff1) > 2);
clf; bar(1:numcomp,diff1)
absmaxval = max(abs(diff1));
absminval = -1*absmaxval;
%set(gca,'XTick', 1:numcomp, 'YTick', absminval-5:5:absmaxval+5);
set(gca,'XLim',[0.5 numcomp+0.5]);
set(gca,'YLim',[absminval-5 absmaxval+5]);
%rotateticklabel(gca, -90);
set(gca,'FontSize',24); set(gca,'FontWeight','bold')
legend('\{ours\} - \{base\}');

saveas(gcf,[outdir '/rankedMontages/persubcatAPdiff.jpg']);

catch
    disp(lasterr); keyboard;
end
