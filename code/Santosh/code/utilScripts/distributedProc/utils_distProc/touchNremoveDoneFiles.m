function touchNremoveDoneFiles
%multimachine_warp('computePDFprobFeatures', 85000, resdir, 160, 'computePDFprobFeatures_007');

%% this function computes pdf prob features for each image each part and save 
try
if ~ispc, basedir = '/nfs/hn12/sdivvala/partsBasedObjDet/';
else basedir = 'Z:\partsBasedObjDet\'; end    
if 0, objname = 'person';
else load([basedir filesep 'code' filesep 'objname.mat'], 'objname'); end
outdir = fullfile(basedir, 'results', 'VOC2010', objname, 'randomParts_NN');
resdir = [outdir filesep 'part_pdfParamsProbFeats']; mymkdir(resdir);

if 1
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numel(imlist));
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'file') || exist([ resdir '/done/' num2str(f) '.done'],'file') )
        continue;
    end
    system(['touch ' resdir '/done/' num2str(f) '.lock']);
    disp(['Processing image ' num2str(f)]);
    
    savename = [resdir filesep strtok(imlist{f},'.') '.mat'];
    if ~exist(savename, 'file')
        ...
    end
    system(['touch ' resdir '/done/' num2str(f) '.done']);
    system(['rm ' resdir '/done/' num2str(f) '.lock']);

end
close all;
end 

catch
    disp(lasterr); keyboard;
end
