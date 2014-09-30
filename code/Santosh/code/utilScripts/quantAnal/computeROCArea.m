function roc = computeROCArea(roc)

% AUCROC => probability that a classifier will rank a randomly chosen
% positive instance higher than a randomly chosen negative one

% basic idea: AUC-ROC can be calculated by using the trapezoidal areas
% created between each ROC point (Martial's ICML'06 reference)
% (this seems to be a complicated algo (with no definite approach?!))

try
%ind = find([true (roc.fp(2:end)~=roc.fp(1:end-1))]);
ind = find([true (roc.conf(2:end-1)~=roc.conf(1:end-2))' true]);

dfp = roc.fp(ind(2:end)) - roc.fp(ind(1:end-1));

avetp = (roc.tp(ind(1:end-1))+roc.tp(ind(2:end)))/2;

if roc.tp(end) ~= 0     % added by SKD 1/27, to avoid Inf error
    roc.area = sum(avetp/roc.tp(end) .* dfp/roc.fp(end));
else
    roc.area = 0;   
end

catch
    roc.area = -1;  % some problem, I don't know to resolve; setting it as -1 as I'll at least know there is a problem when I see this weird value
    %disp(lasterr); keyboard;
end
