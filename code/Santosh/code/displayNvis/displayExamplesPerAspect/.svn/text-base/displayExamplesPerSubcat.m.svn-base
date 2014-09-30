function displayExamplesPerSubcat(objname, outdir, numComps, VOCyear)

try    
disp(['displayExamplesPerSubcat(''' objname ''',''' outdir ''',' num2str(numComps) ',''' VOCyear ''')' ]);

try evalc('matlabpool');
catch, disp('matlabpool was already open!'); end

dispdir = [outdir '/display/']; mymkdir(dispdir);
numToDisplay = 49;

disp('displaying weight vectors');
displayWeightVectorsPerAspect(objname, outdir);

disp('loading groundtruth info');
try load([outdir '/' objname '_train_' VOCyear '.mat'], 'pos');
catch, load([outdir '/' objname '_train.mat'], 'pos'); end

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
try load([outdir '/' objname '_' modeltype '.mat'], 'inds_lrs1',...
        'posscores_lrs1', 'lbbox_lrs1', 'possccalib_lrs1');
catch
    load([outdir '/' objname '_' modeltype '.mat'], 'models');
    model = mergemodels(models);
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_lrs1, posscores_lrs1, lbbox_lrs1] = poslatent_getInds(model, pos, model.overlap);
    [inds_lrs1, posscores_lrs1, lbbox_lrs1, possccalib_lrs1] = ...
        poslatent_calib_getInds(model, pos, model.overlap);   % changed 9Jan12
end

% LRSPLIT2_1
modeltype = 'model_lrsplit2_1';
disp(['loading modeltype ' modeltype]);
try 
    tmp = load([outdir '/' objname '_' modeltype '.mat'], 'latinds', 'posscores', 'lbbox', 'possccalib');
    inds_lrs21 = tmp.latinds; posscores_lrs21 = tmp.posscores; lbbox_lrs21 = tmp.lbbox; possccalib_lrs21 = tmp.possccalib;
catch
    load([outdir '/' objname '_' modeltype '.mat'], 'model');
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_lrs21, posscores_lrs21, lbbox_lrs21] = poslatent_getInds(model, pos, model.overlap);
    [inds_lrs21, posscores_lrs21, lbbox_lrs21, possccalib_lrs21] = poslatent_calib_getInds(model, pos, model.overlap);    % changed 9Jan12
end

% LRSPLIT2_2
modeltype = 'model_lrsplit2_2';
disp(['loading modeltype ' modeltype]);
try 
    tmp = load([outdir '/' objname '_' modeltype '.mat'], 'latinds', 'posscores', 'lbbox', 'possccalib');
    inds_lrs22 = tmp.latinds; posscores_lrs22 = tmp.posscores; lbbox_lrs22 = tmp.lbbox; possccalib_lrs22 = tmp.possccalib;
catch
    load([outdir '/' objname '_' modeltype '.mat'], 'model');
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_lrs22, posscores_lrs22, lbbox_lrs22] = poslatent_getInds(model, pos, model.overlap);
    [inds_lrs22, posscores_lrs22, lbbox_lrs22, possccalib_lrs22] = poslatent_calib_getInds(model, pos, model.overlap);    % changed 9Jan12
end

% LRSPLIT2_3
modeltype = 'model_lrsplit2_3';
disp(['loading modeltype ' modeltype]);
try 
    tmp = load([outdir '/' objname '_' modeltype '.mat'], 'latinds', 'posscores', 'lbbox', 'possccalib');
    inds_lrs23 = tmp.latinds; posscores_lrs23 = tmp.posscores; lbbox_lrs23 = tmp.lbbox; possccalib_lrs23 = tmp.possccalib;
catch
    load([outdir '/' objname '_' modeltype '.mat'], 'model');
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_lrs23, posscores_lrs23, lbbox_lrs23] = poslatent_getInds(model, pos, model.overlap);
    [inds_lrs23, posscores_lrs23, lbbox_lrs23, possccalib_lrs23] = poslatent_calib_getInds(model, pos, model.overlap);    % changed 9Jan12
end

% LRSPLIT2 || LRSPLIT2_4
modeltype = 'lrsplit2';
disp(['loading modeltype ' modeltype]);
try load([outdir '/' objname '_' modeltype '.mat'], 'inds_lrs2',...
        'posscores_lrs2', 'lbbox_lrs2', 'possccalib_lrs2');
catch
    load([outdir '/' objname '_' modeltype '.mat'], 'model');
    if ~isfield(model, 'overlap'), model.overlap = 0.7; end
    if isfield(model, 'sfx'), pos = enlargeWithContext(pos, model.sfx, model.sfy); end
    disp(' getting subcategory membership info');
    %[inds_lrs2, posscores_lrs2, lbbox_lrs2] = poslatent_getInds(model, pos, model.overlap);
    [inds_lrs2, posscores_lrs2, lbbox_lrs2, possccalib_lrs2] = ...
        poslatent_calib_getInds(model, pos, model.overlap);   % changed 9Jan12
end

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

disp('getting all displays');
[mimg_init, mlab_init, mimg_lrs1, mlab_lrs1, mimg_lrs21, mlab_lrs21, ...
    mimg_lrs22, mlab_lrs22, mimg_lrs23, mlab_lrs23, mimg_lrs2, mlab_lrs2, ...
    mimg_mix, mlab_mix, mimg_f, mlab_f] = deal([]);
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
[mimg_init, mlab_init] = getMontagesForModel_latent(inds_init, inds_init, inds_lrs1, [], [], [], pos, numToDisplay, numComps);
[mimg_lrs1, mlab_lrs1] = getMontagesForModel_latent(inds_lrs1, inds_init, inds_lrs21, posscores_lrs1, possccalib_lrs1, lbbox_lrs1, pos, numToDisplay, numComps);
[mimg_lrs21, mlab_lrs21] = getMontagesForModel_latent(inds_lrs21, inds_lrs1, inds_lrs22, posscores_lrs21, possccalib_lrs21, lbbox_lrs21, pos, numToDisplay, numComps);
[mimg_lrs22, mlab_lrs22] = getMontagesForModel_latent(inds_lrs22, inds_lrs21, inds_lrs23, posscores_lrs22, possccalib_lrs22, lbbox_lrs22, pos, numToDisplay, numComps);
[mimg_lrs23, mlab_lrs23] = getMontagesForModel_latent(inds_lrs23, inds_lrs22, inds_lrs2, posscores_lrs23, possccalib_lrs23, lbbox_lrs23, pos, numToDisplay, numComps);
[mimg_lrs2, mlab_lrs2] = getMontagesForModel_latent(inds_lrs2, inds_lrs23, inds_mix, posscores_lrs2, possccalib_lrs2, lbbox_lrs2, pos, numToDisplay, numComps);
[mimg_mix, mlab_mix] = getMontagesForModel_latent(inds_mix, inds_lrs2, inds_f, posscores_mix, possccalib_mix, lbbox_mix, pos, numToDisplay, numComps);
[mimg_f, mlab_f] = getMontagesForModel_latent(inds_f, inds_mix, inds_f, posscores_f, possccalib_f, lbbox_f, pos, numToDisplay, numComps);

disp('Writing final montages');
writeFinalMontages_latent(dispdir, mimg_init, mlab_init, mimg_lrs1, mlab_lrs1, ...
    mimg_lrs21, mlab_lrs21, mimg_lrs22, mlab_lrs22, mimg_lrs23, mlab_lrs23, ...
    mimg_lrs2, mlab_lrs2, mimg_mix, mlab_mix, mimg_f, mlab_f);

catch
    disp(lasterr); keyboard;
end

%%%%%%%%%%%%%%
%{
if isfield(model, 'sfx')
    disp('enlarging groundtruth to account for local context');
    pos = enlargeWithContext(pos, model.sfx, model.sfy); 
end

disp('getting subcategory membership info');
overlap = model.overlap;
[inds, posscores, lbbox] = poslatent_getInds(model, pos, overlap);

disp('getting displays');

[mimg, mlab] = deal(cell(numComps+1,1)); % +1 to accomodate 0 index    
for jj=1:numel(mimg)    % initialize to dummy
    mimg{jj} = ones(10,10,3);
    mlab{jj} = ' ';
end

unids = unique(inds);
for jj = 1:length(unids)    
    myprintf(jj);
    %savename = [dispdir '/montage_' num2str(jj) '.jpg'];
    
%    if ~exist(savename, 'file')
        A = find(inds == unids(jj));
        thisNum = min(numToDisplay, numel(A));
        allimgs = cell(thisNum,1); alllabs = cell(thisNum,1);
        
        if ~isempty(posscores)
            thisscores = posscores(A);
            [sval sinds] = sort(thisscores, 'descend');
            selInds = sinds(1:thisNum);
        else
            randInds = randperm(numel(A));
            selInds = randInds(1:thisNum);
            sval = zeros(thisNum, 1);
        end
        spos = pos(A(selInds));
        thisbbox = lbbox(A(selInds),:);
        %warptmp = warppos_display(model, spos);        
        for j=1:thisNum
            im = color(imreadx(spos(j)));
            allimgs{j} = croppos_nopad(im, thisbbox(j,:));
            %allimgs{j} = uint8(warptmp{j});
            if unids(jj) ~= 0 %& ~isempty(modelthresh) & sval(j) >= modelthresh(unids(jj))
                printScore = num2str(sval(j));
            else
                printScore = ['* ' num2str(sval(j))];
            end
            
            if inds_old(A(selInds(j))) == unids(jj)
                alllabs{j} = ['0 ' printScore];
            else
                alllabs{j} = [num2str(inds_old(A(selInds(j)))) ' ' printScore];
            end
            %alllabs{j} = '';        %% added this plug for generating results for CVPR supplementary deadline
        end
        mimg{unids(jj)+1} = montage_list_w_text2(allimgs, alllabs, 2);
        mlab{unids(jj)+1} = num2str(numel(A));
        %imwrite(mimg{unids(jj)+1}, savename);
%    end
end
%mim = montage_list_w_text2(mimg, mlab, 2, [], [], [3000 3000 3]);
%imwrite(mim, fullsavename);
myprintfn;
%}
