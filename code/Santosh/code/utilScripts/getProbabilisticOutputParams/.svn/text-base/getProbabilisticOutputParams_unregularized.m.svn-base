function [A, B, err, dtype] = getProbabilisticOutputParams_unregularized(conf, labels)
% [A, B, err] = getProbabilisticOutputParams(conf, labels)
%
% Converts a score (such as SVM output or log-likelihood ratio) to a
% probability.
%
% Input:
%   conf(ndata): the confidence of a datapoint (higher indicates greater
%   likelihood of label(i)=1
%   label(ndata): the true label (0 or -1 for neg, 1 for pos) of the datapoint
% Output:
%   A, B: p = 1 / (1+exp(A*conf+B))
%   err: final value that has been minimized

ind = labels==-1;
labels(ind) = 0;

AB = fminsearch(@(AB) logisticError(AB, conf, labels), [-1 0], []);
%A = AB(1); B = AB(2);
A1 = AB(1); B1 = AB(2);
err1 = logisticError([AB(1) AB(2)], conf, labels)/numel(labels);

AB = fminsearch(@(AB) logisticError(AB, conf, labels), [0 log((sum(labels==0)+1)/(sum(labels==1)+1))], []); % platt uses the following prior than [-1 0]
%A = AB(1); B = AB(2);
A2 = AB(1); B2 = AB(2);
err2 = logisticError([AB(1) AB(2)], conf, labels)/numel(labels);

if err1 < err2
    %disp('reg prior');
    A = A1; B = B1; err = err1; dtype = 1;    
else
    %disp('platt prior');
    A = A2; B = B2; err = err2; dtype = 2;
end

function err = logisticError(AB, conf, labels)

labels = double(labels);
p = 1./ (1+exp(AB(1)*conf+AB(2)));
err = -sum(labels.*log(p)+(1-labels).*log(1-p));



