function displayWeightVectorsPerAspect_kmeans15_2(objname, outdir)
%multimachine_warp('displayExamplesPerAspect', 20, resdir, 2)

% this is a temporary version to overwrite existing weight vectors (no
% ~exsit check)

try
basedir = '/nfs/hn12/sdivvala/partsBasedObjDet/';
%objname = 'pottedplant';
%outdir = ['/nfs/hn12/sdivvala/partsBasedObjDet/results/uoctti_models/release3_retrained/2007/' objname '_kmeanssplit_4/test/candidates/'];

outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);

numToDisplay = 49;

disp(['Processing Class ' objname]);

load([outdir '/' objname '_random.mat'], 'models');   
kclus = numel(models{1}.rootfilters);
clear models;

finmodelname = [outdir '/' objname '_final.mat'];
if exist(finmodelname, 'file')
savename = [resdir '/weightVector_final.jpg'];
%if ~exist(savename, 'file')
clear allimw alliml
load(finmodelname, 'model');   
for i=1:numel(model.rootfilters)
   allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
   alliml{i} = num2str(i);
end
mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3]);
imwrite(mim, savename);
%end
end


harmodelname = [outdir '/' objname '_hard.mat'];
if exist(harmodelname, 'file')
savename = [resdir '/weightVector_hard.jpg'];
%if ~exist(savename, 'file')
clear allimw alliml
load(harmodelname, 'model');   
for i=1:numel(model.rootfilters)
   allimw{i} = color(visualizeHOG(model.rootfilters{i}.w));
   alliml{i} = num2str(i);
end
mim = montage_list_w_text2(allimw, alliml, 2, [], [], [1500 1000 3]);
imwrite(mim, savename);
%end
end

randmodelname = [outdir '/' objname '_random.mat'];
if exist(randmodelname, 'file')
savename = [resdir '/weightVector_random.jpg'];
%if ~exist(savename, 'file')
load(randmodelname, 'models');   
clear mim;
for k=1:numel(models)
   clear allimw alliml
   for i=1:numel(models{k}.rootfilters)
       allimw{i} = color(visualizeHOG(models{k}.rootfilters{i}.w));
       alliml{i} = num2str(i);
   end
   mim{k} = montage_list_w_text2(allimw, alliml, 2, [], [], [500 1000 3]);
end
%mimg = [mim{1}; mim{2}; mim{3}];   
mimg = cat(1,mim{:});
imwrite(mimg, savename);
%end
end

catch
    disp(lasterr); keyboard;
end
