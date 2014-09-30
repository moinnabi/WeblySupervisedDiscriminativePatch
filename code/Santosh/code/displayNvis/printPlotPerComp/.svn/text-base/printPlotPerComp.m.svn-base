function printPlotPerComp(roc, fname)

clf;
numcomps = numel(roc.roc_comp);
spx = floor(sqrt(numcomps)); spy = ceil(numcomps/spx);
for i=1:numcomps
    if ~isempty(roc.roc_comp{i})
    subplot(spx,spy,i); hold on; 
    plot(roc.roc_comp{i}.r, roc.roc_comp{i}.p, 'b');
    legend(num2str(roc.roc_comp{i}.ap_new*100));
    title(num2str(i)); 
    end
end
%fillscreen; % disabling as it gives error in distributed mode

%set(gcf,'PaperPositionMode','auto')
%print('-dpsc2','-zbuffer','-r200', fname)

saveas(gcf, fname);
%mysaveas(fname);

% commented and swtiched to saveas on 23Feb12 as doesn't work on
% imgclassification expts
%hfd = getframe(gcf);
%imwrite(hfd.cdata, fname);


%{
k=1;
clf;
for i=1:3
    for j=1:numcomps/3      
        subplot(3,numcomps/3,k); 
        plot(modelsc{i,j}.vals{3,3});
        k = k+1;
    end
end
%}