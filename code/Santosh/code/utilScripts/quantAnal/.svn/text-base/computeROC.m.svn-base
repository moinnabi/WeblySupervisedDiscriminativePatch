function roc = computeROC(scores, labels)

[sval, sind] = sort(scores, 'descend');
roc.tp = cumsum(labels(sind)==1);
roc.fp = cumsum(labels(sind)==-1);
roc.conf = sval;
roc = computeROCArea(roc);

% ind = find([true (roc.conf(2:end)~=roc.conf(1:end-1))']);
% dfp = roc.fp(ind(2:end)) - roc.fp(ind(1:end-1));
% avetp = (roc.tp(ind(1:end-1))+roc.tp(ind(2:end)))/2;
% roc.area = sum(avetp/roc.tp(end) .* dfp/roc.fp(end));

%if labels(sind(1)) == 0     %% the two if statements added by SKD 03/09 to avoid NAN error
%    dbclear if naninf;
%end
roc.p = roc.tp ./ (roc.tp + roc.fp);
if labels(sind(1)) == 0
    roc.p(1) = 0;
    %dbstop if naninf;
end

if roc.tp(end) ~= 0     % added by SKD 1/27, to avoid Inf error
    roc.r = roc.tp / roc.tp(end);   
    % this should actually be tp/tp+fn  == tp/totalTrue
else
    roc.r = 0;
end
roc.ap = [];
