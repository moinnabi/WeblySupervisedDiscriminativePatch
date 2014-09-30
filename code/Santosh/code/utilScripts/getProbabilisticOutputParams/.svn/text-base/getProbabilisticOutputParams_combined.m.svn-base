function [finalAB, err] = getProbabilisticOutputParams_combined(conf, initAB, labels)
% [A, B, err] = getProbabilisticOutputParams(conf, labels)
%
% this script is adopted from getProbabilisticOutputParams; tries to learn
% the sigmoid parameters jointly for a set of classifier outputs
%
% Input:
%   conf(ndata,nclass): the confidence of a datapoint (higher indicates greater
%   likelihood of label(i)=1) per classifier
%   label(ndata,nclass): the true label (0 or -1 or neg, 1 for pos) of the
%   datapoint per classifier
%   initAB(nclass,2): the parameters [A B] per classifier
% Output:
%   A, B: p = 1 / (1+exp(A*conf+B))
%   err: final value that has been minimized

ind = labels==-1;
labels(ind) = 0;

AB = fminsearch(@(AB) logisticError(AB, conf, labels), [-1 0], []);%, optimset('MaxFunEvals', 1000000, 'MaxIter', 1000000));

A = AB(1);B = AB(2);
err = logisticError([A B], conf, labels)/numel(labels);
finalAB = AB;

function err = logisticError(AB, conf, labels)

labels = double(labels);
p = 1./ (1+exp(AB(1)*conf+AB(2)));

% see platts paper for making this update!!
labels(labels==1) = (sum(labels==1)+1)/(sum(labels==1)+2);
labels(labels==0) = 1 / (sum(labels==0)+2);
err = -sum(labels.*log(p)+(1-labels).*log(1-p));


function err = softMax(initAB, conf, labels)

labels = double(labels);
if size(conf,2) ~= 1
    disp('conf should be a column vector!'); keyboard;
end    
Q = 1 ./ (1+exp(initAB(:,1)*conf'+ repmat(initAB(:,2)', [size(conf,1) 1])));

P = exp(Q) ./ repmat(sum(exp(Q),2), [1 size(Q,2)]);
p = max(P);


% see platts paper for making this update!!
labels(labels==1) = (sum(labels==1)+1)/(sum(labels==1)+2);
labels(labels==0) = 1 / (sum(labels==0)+2);
err = -sum(labels.*log(p)+(1-labels).*log(1-p));

