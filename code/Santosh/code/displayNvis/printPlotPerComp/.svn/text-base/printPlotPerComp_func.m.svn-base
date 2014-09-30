function [mim, mimg, ap_percomp] = printPlotPerComp_func(roc)

try
clear mimg;
clear ap_percomp;
clf;
%tempfname = 'printPlotPerComp_func_tmp.jpg';
tempfname = [tempname '.jpg'];
numcomps = numel(roc.roc_comp);
for i=1:numcomps    
    plot(roc.roc_comp{i}.r, roc.roc_comp{i}.p, 'b', 'linewidth', 3);
    ap_percomp(i) = roc.roc_comp{i}.ap_new*100;
    legend(num2str(ap_percomp(i)));
    title(num2str(i));
    set(gca, 'FontSize', 15);
    %fillscreen;
    %disp('here'); keyboard;
    saveas(gcf, tempfname);
    mimg{i} = imread(tempfname);
end
delete(tempfname);
mim = montage_list(mimg, 2);
catch
    disp(lasterr); keyboard;
end
