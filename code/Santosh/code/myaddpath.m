function [paths_tba, myaddpath_fpath, paths_tba_c, compiledir] = myaddpath(doadd)
% this code needs to be commented (chumma added comment to test commit from uw to cmu)

if ~exist('doadd', 'var') || isempty(doadd)
    doadd = 1;
end


if ispc
basecodedir = ['Z:' filesep 'objectNgrams'  filesep 'code' filesep];    % @ CMU
else  
basecodedir = fileparts([mfilename('fullpath') '.m']); %'/projects/grail/santosh/objectNgrams/code/';
end
compiledir = [basecodedir '/../code_compiled/']; %mkdir(compiledir);

myaddpath_fpath = [basecodedir '/myaddpath.m'];
paths_tba = {[basecodedir filesep]};

paths_tba_c = {[basecodedir filesep 'voc-release5']};
    %[basecodedir filesep '/featAdapt/globalPb08/lib/' filesep 'segment']};
    %[basecodedir filesep 'voc-release4' filesep 'learn'],...
    %[basecodedir filesep 'voc-release4' filesep 'learn_nonms']


if doadd
restoredefaultpath;
for k=1:numel(paths_tba)
    addpath(genpath(paths_tba{k}));
end
% removing path to avoid conflict of file names
%rmpath(genpath([basecodedir '/PASannotation/']));
end

format compact
