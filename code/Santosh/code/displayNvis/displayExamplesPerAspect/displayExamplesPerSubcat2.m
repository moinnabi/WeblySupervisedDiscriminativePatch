function displayExamplesPerSubcat2(objname, outdir, numComps, VOCyear, traindatatype)

try    
disp(['displayExamplesPerSubcat2(''' objname ''',''' outdir ''',' num2str(numComps)...
    ',''' VOCyear ''',''' traindatatype ''')' ]);

try evalc('matlabpool');
catch, disp('matlabpool was already open!'); end

dispdir = [outdir '/display/']; mymkdir(dispdir);
numToDisplay = 49;

disp('displaying weight vectors');
displayWeightVectorsPerAspect(objname, outdir);

disp('loading groundtruth info');
try load([outdir '/' objname '_' traindatatype '_' VOCyear '.mat'], 'pos');
catch, load([outdir '/' objname '_' traindatatype '.mat'], 'pos'); end

% INIT
disp('getting subcategory membership kmeans initialization');
try load([outdir '/' objname '_displayInfo.mat'], 'inds_init'); 
catch
myinds = load([outdir '/' objname '_displayInfo.mat'], 'inds'); 
inds_init = myinds.inds{1};
end

% LRSPLIT1
modeltype = 'lrsplit1';
disp(['loading modeltype ' modeltype]);    
try load([outdir '/' objname '_' modeltype '.mat'], 'model', 'inds_lrs1',...
        'posscores_lrs1', 'lbbox_lrs1', 'possccalib_lrs1');
catch
    load([outdir '/' objname '_' modeltype '.mat'], 'models', 'model');
    if ~exist('model', 'var'), model = mergemodels(models); end
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_lrs1, posscores_lrs1, lbbox_lrs1] = poslatent_getInds(model, pos, model.overlap);
    [inds_lrs1, posscores_lrs1, lbbox_lrs1, possccalib_lrs1] = ...
        poslatent_calib_getInds(model, pos, model.overlap);   % changed 9Jan12
end

% LRSPLIT2 || LRSPLIT2_4
modeltype = 'lrsplit2';
fname = [outdir '/' objname '_' modeltype '.mat'];
if exist(fname, 'file')
    disp(['loading modeltype ' modeltype]);
    try 
        load(fname, 'inds_lrs2', 'posscores_lrs2', 'lbbox_lrs2', 'possccalib_lrs2');
        try load(fname, 'inds_lrs1b', 'posscores_lrs1b', 'lbbox_lrs1b', 'possccalib_lrs1b'); end
    catch
    load(fname, 'model');
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sf')        
        pos = enlargeWithContext4(pos, model.sf);
    end
    disp(' getting subcategory membership info');
    %[inds_lrs2, posscores_lrs2, lbbox_lrs2] = poslatent_getInds(model, pos, model.overlap);
    [inds_lrs2, posscores_lrs2, lbbox_lrs2, possccalib_lrs2] = ...
        poslatent_calib_getInds(model, pos, model.overlap);   % changed 9Jan12
    end
end

disp('getting the montages');
[mimg_init, mlab_init] = getMontagesForModel_latent(inds_init(:), inds_init(:), ...
    inds_init(:), [], [], [], pos, [], numel(model.rules{model.start}));
%mimg_cell = mimg_init; mlab_cell = mlab_init;
[mimg_lrs1, mlab_lrs1] = getMontagesForModel_latent(inds_lrs1, inds_lrs1, ...
    inds_lrs1, posscores_lrs1, possccalib_lrs1, lbbox_lrs1, pos, [], numel(model.rules{model.start}));
%mimg_cell = {mimg_cell(:); mimg_lrs1}; mlab_cell = {mlab_cell(:); mlab_lrs1};
if exist('inds_lrs1b', 'var')
[mimg_lrs1b, mlab_lrs1b] = getMontagesForModel_latent(inds_lrs1b, inds_lrs1b, ...
    inds_lrs1b, posscores_lrs1b, possccalib_lrs1b, lbbox_lrs1b, pos, [], numel(model.rules{model.start}));
end
if exist('inds_lrs2', 'var')
[mimg_lrs2, mlab_lrs2] = getMontagesForModel_latent(inds_lrs2, inds_lrs2, ...
    inds_lrs2, posscores_lrs2, possccalib_lrs2, lbbox_lrs2, pos, [], numel(model.rules{model.start}));
%mimg_cell = {mimg_cell; mimg_lrs2}; mlab_cell = {mlab_cell; mlab_lrs2};
end

disp('Writing montages');
if exist('mimg_lrs2', 'var') &&  exist('mimg_lrs1b', 'var')
mimg_cell = {mimg_init; mimg_lrs1; mimg_lrs1b; mimg_lrs2};
mlab_cell = {mlab_init; mlab_lrs1; mlab_lrs1b; mlab_lrs2};
elseif exist('mimg_lrs2', 'var') 
mimg_cell = {mimg_init; mimg_lrs1; mimg_lrs2};
mlab_cell = {mlab_init; mlab_lrs1; mlab_lrs2};   
else
mimg_cell = {mimg_init; mimg_lrs1};
mlab_cell = {mlab_init; mlab_lrs1};
end
writeFinalMontages_latent(dispdir, mimg_cell, mlab_cell);

%{
% MIX
modeltype = 'mix';
disp(['loading modeltype ' modeltype]);
try load([outdir '/' objname '_' modeltype '.mat'], 'inds_mix', 'posscores_mix', 'lbbox_mix', 'possccalib_mix');
catch
    load([outdir '/' objname '_' modeltype '.mat'], 'model');
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_mix, posscores_mix, lbbox_mix] = poslatent_getInds(model, pos, model.overlap);
    [inds_mix, posscores_mix, lbbox_mix, possccalib_mix] = poslatent_calib_getInds(model, pos, model.overlap);  % changed 9Jan12
end

% FINAL
modeltype = 'parts';
disp(['loading modeltype ' modeltype]);
try load([outdir '/' objname '_' modeltype '.mat'], 'inds_f', 'posscores_f', 'lbbox_f', 'possccalib_f');
catch
    load([outdir '/' objname '_' modeltype '.mat'],'model');
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_f, posscores_f, lbbox_f] = poslatent_getInds(model, pos, model.overlap);
    [inds_f, posscores_f, lbbox_f, possccalib_f] = poslatent_calib_getInds(model, pos, model.overlap);    % changed 9Jan12
end
%inds_f = inds_mix; posscores_f = posscores_mix; lbbox_f = lbbox_mix; possccalib_f = possccalib_mix;
%}

%{
    % no pos scores with calib
[mimg_init, mlab_init] = getMontagesForModel_latent(inds_init, inds_init, inds_lrs1, [], [], pos, numToDisplay, numComps);
[mimg_lrs1, mlab_lrs1] = getMontagesForModel_latent(inds_lrs1, inds_init, inds_lrs21, posscores_lrs1, lbbox_lrs1, pos, numToDisplay, numComps);
[mimg_lrs21, mlab_lrs21] = getMontagesForModel_latent(inds_lrs21, inds_lrs1, inds_lrs22, posscores_lrs21, lbbox_lrs21, pos, numToDisplay, numComps);
[mimg_lrs22, mlab_lrs22] = getMontagesForModel_latent(inds_lrs22, inds_lrs21, inds_lrs23, posscores_lrs22, lbbox_lrs22, pos, numToDisplay, numComps);
[mimg_lrs23, mlab_lrs23] = getMontagesForModel_latent(inds_lrs23, inds_lrs22, inds_lrs2, posscores_lrs23, lbbox_lrs23, pos, numToDisplay, numComps);
[mimg_lrs2, mlab_lrs2] = getMontagesForModel_latent(inds_lrs2, inds_lrs23, inds_mix, posscores_lrs2, lbbox_lrs2, pos, numToDisplay, numComps);
[mimg_mix, mlab_mix] = getMontagesForModel_latent(inds_mix, inds_lrs2, inds_f, posscores_mix, lbbox_mix, pos, numToDisplay, numComps);
[mimg_f, mlab_f] = getMontagesForModel_latent(inds_f, inds_mix, inds_f, posscores_f, lbbox_f, pos, numToDisplay, numComps);
%}    
    
catch
    disp(lasterr); keyboard;
end
