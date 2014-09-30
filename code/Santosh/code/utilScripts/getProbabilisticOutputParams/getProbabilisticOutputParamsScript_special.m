function [sigAB, err]= getProbabilisticOutputParamsScript_special(imdir, result, chinds, paramInfo, testMode)

load([imdir '/recs.mat'], 'recs');
rec = recs(chinds);    

maxov = paramInfo.maxov;
maxdet = paramInfo.maxdet;
BIGPPLHT = paramInfo.BIGPPLHT;

%result = myLoadResults(fn, maxdet, [outdir '/candidates/']);

for k = 1:numel(result)
    [result(k).bbox, result(k).svmScore, kept] = ...
        pruneBBox(result(k).bbox, result(k).svmScore, [], [], maxov);
    result(k).scale = result(k).scale(kept);
    result(k).scores = result(k).svmScore;   % score set to svmScore!
end
ignoreExtraPos = false;
result = evaluateDetectionResult(rec, result, 'person', ignoreExtraPos, testMode, BIGPPLHT);

conf = cat(1, result.scores);
labels = cat(1, result.labels);
nonZeroInds = find(labels ~= 0);
conf = conf(nonZeroInds);
labels = labels(nonZeroInds);
labels(labels == -1) = 0;

disp(' added stub to take care of Inf values');
infinds = find(conf == -Inf);
minval = min(conf(find(conf~=-Inf)));
conf(infinds) = minval - 1;

[A, B, err] = getProbabilisticOutputParams(conf, labels);
sigAB = [A B];
