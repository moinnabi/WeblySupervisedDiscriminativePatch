function [A, err] = getProbabilisticOutputParams_A(conf, labels)
% [A, err] = getProbabilisticOutputParams(conf, labels)
%
% Converts a score (such as SVM output or log-likelihood ratio) to a
% probability.
%
% Input:
%   conf(ndata): the confidence of a datapoint (higher indicates greater
%   likelihood of label(i)=1
%   label(ndata): the true label (0 or -1 or neg, 1 for pos) of the datapoint
% Output:
%   A: p = 1 / (1+exp(A*conf))
%   err: final value that has been minimized

ind = labels==-1;
labels(ind) = 0;

A = fminsearch(@(A) logisticError(A, conf, labels), -1, []);%, optimset('MaxFunEvals', 1000000, 'MaxIter', 1000000));

err = logisticError(A, conf, labels)/numel(labels);


function err = logisticError(A, conf, labels)

labels = double(labels);
p = 1./ (1+exp(A*conf));

% see platts paper for making this update!!
labels(labels==1) = (sum(labels==1)+1)/(sum(labels==1)+2);
labels(labels==0) = 1 / (sum(labels==0)+2);
err = -sum(labels.*log(p)+(1-labels).*log(1-p));


