function plotROC(roc, h2)

if nargin < 2
    h2= figure;
    col = 'r';
else
    col = 'b';
end

%h1=figure; plot(roc.fp/length(roc.fp), roc.r, 'linewidth',2); hold on;
%h2=figure; 
hold on;
plot(roc.r, roc.p, col, 'linewidth',2);  

%figure(h1); set(gca, 'FontSize', 15); grid;  xlabel('FPR');  ylabel('TPR'); title('ROC'); hold off;
figure(h2); set(gca, 'FontSize', 15); grid;  xlabel('Recall');  ylabel('Precision'); 

[~,~,~,text_strings] = legend;
legend([text_strings; num2str(roc.ap)]); title('Precision-Recall'); hold off;
