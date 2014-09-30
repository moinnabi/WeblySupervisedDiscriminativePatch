function displayExamplesPerAspect_lastNewIt(objname, outdir)
% taken from displayExamplesPerAspect_kmeans_overIt_latent

try
outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);
numToDisplay = 100;

disp(['Processing Class ' objname]);

load([outdir '/' objname '_train'], 'pos');

tmp_fin0 = load([outdir filesep objname '_hard_info'], 'sigAB', 'posclusinds', 'pos_cell', 'posscores');    
posclusinds{1} = tmp_fin0.posclusinds{end}; 
pos_cell{1} = tmp_fin0.pos_cell{end}; 
posscores{1} = tmp_fin0.posscores{end}; 

load([outdir filesep objname '_final'], 'model');

tmp_fin1 = load([outdir filesep objname '_box'], 'posclusinds', 'pos_cell', 'posscores');
posclusinds{2} = tmp_fin1.posclusinds; 
pos_cell{2} = tmp_fin1.pos_cell; 
posscores{2} = tmp_fin1.posscores; 

savename = [resdir '/finalMontage_overIt_perComp.jpg'];

if ~exist(savename, 'file')

disp('latent update It1');
thispos = pos_cell{1};
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im)        
        thispos(i) = rmfield(pos(i), 'recind');
    end
end
%nextpos = thispos;
modelthresh = repmat(-Inf, numel(model.rootfilters),1);
[mim{1} mimg_all{1} mlab_all{1}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds{1}, posclusinds{1}, thispos, posscores{1}, model, numToDisplay, modelthresh);

disp('latent update It2');
thispos = pos_cell{2};
for i=1:length(thispos)     % fill empty pos(i) cells
     if isempty(thispos(i).im)        
        thispos(i) = rmfield(pos(i), 'recind');
     end    
end
modelthresh = repmat(-Inf, numel(model.rootfilters),1);
[mim{2} mimg_all{2} mlab_all{2}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds{2}, posclusinds{1}, thispos, posscores{2}, model, numToDisplay, modelthresh);

disp('montage per component');
for k=1:length(mimg_all{1})
    myprintf(k);
    allimgs{1} = mimg_all{1}{k}; alllabs{1} = mlab_all{1}{k};
    allimgs{2} = mimg_all{2}{k}; alllabs{2} = mlab_all{2}{k};
    allmim{k} = montage_list_w_text2(allimgs, alllabs, 2, [], [], [1500 1500 3]);
    allmlab{k} = num2str(k);
    imwrite(allmim{k}, [resdir '/finalMontage_overIt_perComp_' num2str(k) '.jpg']);
end
mimg = montage_list_w_text2(allmim, allmlab, 2, [], [], [5000 5000 3]);
imwrite(mimg, savename);
end

catch
    disp(lasterr); keyboard;
end
