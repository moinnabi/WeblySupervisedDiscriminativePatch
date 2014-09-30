function [A, B, err] = getProbabilisticOutputParams_overlap(conf, labels)
% [A, B, err] = getProbabilisticOutputParams(conf, labels)
%
% Converts a score (such as SVM output or log-likelihood ratio) to a
% probability.
%
% Input:
%   conf(ndata): the confidence of a datapoint (higher indicates greater
%   likelihood of label(i)=1
%   label(ndata): the true label (0 or -1 or neg, 1 for pos) of the datapoint
% Output:
%   A, B: p = 1 / (1+exp(A*conf+B))
%   err: final value that has been minimized

% this function gives same result as matlab "glmfit" (with 'binomial' option) or
% "regress"

%AB = fminsearch(@(AB) logisticError(AB, conf, labels), [-1 0], []);%, optimset('MaxFunEvals', 1000000, 'MaxIter', 1000000));
AB = fminsearch(@(AB) logisticError(AB, conf, labels), [-1 0], optimset('MaxFunEvals', 1000000, 'MaxIter', 1000000));

A = AB(1);
B = AB(2);

err = logisticError([A B], conf, labels)/numel(labels);


function err = logisticError(AB, conf, labels)

labels = double(labels);
p = 1./ (1+exp(AB(1)*conf+AB(2)));

% "-" bcoz u want to minimize
err = -sum(labels.*log(p)+(1-labels).*log(1-p));



