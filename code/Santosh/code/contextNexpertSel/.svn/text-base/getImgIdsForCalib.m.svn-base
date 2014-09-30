function [ids labs] = getImgIdsForCalib(VOCopts, cls)

% this should be used a reference to create val1.txt (although val1 would
% be different as it would have positives from all ngram positive train
% data)

numNegImgsToUse = 500;
[pids gt] = textread(sprintf(VOCopts.clsimgsetpath, cls, 'train'), '%s %d');
pids = pids(gt == 1);
if isempty(pids), disp('no positive images'); keyboard; end
[nids gt] = textread(sprintf(VOCopts.imgsetpath, 'trainval_withLabels'), '%s %d');
nids = nids(gt == -1);
nids = nids(1:numNegImgsToUse);
ids = [pids; nids];
labs = [ones(size(pids,1),1); -1*ones(size(nids,1),1)];
disp(['total #images to test ' num2str(numel(ids))]);
%disp('check if enough images'); keyboard;
