function model = pascal_train_wsup3(cls, n, note, cachedir, year, fg_olap, borderoffset, objname, fname_imgcl_sprNg, doparts)
% new idea that trains a model partially, tests on val set, ignore bad
% comps and then trains model fully

try
% At every "checkpoint" in the training process the 
% RNG's seed is reset to a fixed value so that experimental results are 
% reproducible.
seed_rand();

if isdeployed, n = str2num(n); end
if isdeployed, fg_olap = str2num(fg_olap); end
if isdeployed, borderoffset = str2num(borderoffset); end
if isdeployed, doparts = str2num(doparts); end

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
VOC_CONFIG_OVERRIDE.training.fg_overlap = fg_olap; %0.25;
VOC_CONFIG_OVERRIDE.training.train_set_fg = 'train';
diary([cachedir '/diaryoutput_train.txt']);
disp(['pascal_train_wsup3(''' cls ''',' num2str(n) ',''' note ''',''' cachedir ''',''' year ''',' num2str(fg_olap) ',' num2str(borderoffset) ',''' objname ''',''' fname_imgcl_sprNg ''',' num2str(doparts) ')' ]);

% added if condition (as with large number of components K=100 nodes crash)
disp(' only opening 8 cores'); 
if n<75, mymatlabpoolopen(8); end   

conf = voc_config();
conf.borderoffset = borderoffset;  
save([cachedir cls '_conf.mat'], 'conf');

recthresh = conf.threshs.recthresh_goodcompsel;
minAPthresh_full = conf.threshs.minAP_compThresh_full;
minAPthresh = conf.threshs.minAP_compThresh;
minNumValInst = conf.threshs.minNumValInst_comp;
minNumTrngInst = conf.threshs.minNumTrngInst_comp;
numLimitToTrainDPM = conf.threshs.numLimitToTrainDPM;

% Load the training data
[pos, neg, impos] = pascal_data_wsup(cls, conf.pascal.year, borderoffset);
[pos, neg, impos] = updatePathForAWS(pos, neg, impos);

disp('splitting - kmeans using esvm hog'); 
%[spos, posindex] = split_wsup(pos, n);     % Split foreground examples into n groups by aspect ratio
indsname = [cachedir '/' cls '_displayInfo.mat'];
if ~exist(indsname, 'file')
    disp('doing clustering');        
    [inds_init, clustCents, mimg] = split_app_esvm(pos, n, conf.esvmmodfile);    
    if isempty(inds_init)
        disp(' doing regular hog clustering instead of esvmhog');
        [inds_init, clustCents, mimg] = split_app(pos, n);
    end 
    save(indsname, 'inds_init', 'clustCents');
    mymkdir([cachedir '/display/']);
    %imwrite(mimg, [cachedir '/display/initmontage_kmeansHOG.jpg']);
    imwrite(mimg, [cachedir '/display/initmontage_kmeansESVMHOG_' num2str(n) '.jpg']); 
else
    load(indsname, 'inds_init');
end
spos = cell(n,1);
for i=1:n, spos{i} = pos(inds_init == i); end
disp(spos);

mymkdir([cachedir '/intermediateModels/']); 

max_num_examples = conf.training.cache_example_limit;
num_fp           = conf.training.wlssvm_M;
fg_overlap       = conf.training.fg_overlap;

% Select a small, random subset of negative images
% All data mining iterations use this subset, except in a final
% round of data mining where the model is exposed to all negative
% images
num_neg   = length(neg);
neg_perm  = neg(randperm(num_neg));
neg_small = neg_perm(1:min(num_neg, conf.training.num_negatives_small));
neg_large = neg;        % use all of the negative images

% Train a root filter for each subcategory
% using warped positives and random negatives
disp('Doing lrsplit1');
try
    load([cachedir cls '_lrsplit1']);
catch
    seed_rand();
    for i = 1:n
        disp(['*******Training lrsplit1 model ' num2str(i) ' ********']);
        models{i} = root_model(cls, spos{i}, note);        
        models{i} = train_wsup(models{i}, spos{i}, neg_large, true, true, 1, 1, ...
            max_num_examples, fg_overlap, 0, false, ...
            ['lrsplit1_' num2str(i)]);
    end
    save([cachedir cls '_lrsplit1'], 'models');
    
    [inds_lrsplit1, posscores_lrsplit1, lbbox_lrsplit1] = poslatent_wsup_getinds(model_merge(models), pos, fg_overlap, 0);
    save([cachedir cls '_lrsplit1'], 'inds_lrsplit1', 'posscores_lrsplit1', 'lbbox_lrsplit1', '-append');
end
myprintfn;

%{
%%% debugging code
[mimg_lrs1, mlab_lrs1] = getMontagesForModel_latent_wsup(inds_lrsplit1, inds_lrsplit1, ...
    inds_lrsplit1, posscores_lrsplit1, posscores_lrsplit1, lbbox_lrsplit1, pos, [], n);
mimg = montage_list_w_text(mimg_lrs1, mlab_lrs1, 2, '', [0 0 0], [2000 2000 3]);
imwrite(mimg, [cachedir '/display/montage_lrsplit1c.jpg']);
%}

% Train a mixture model composed of all subcategories 
% using latent positives and hard negatives
disp('Doing mix');
try 
  load([cachedir cls '_mix']);
catch
  seed_rand();  
  model = model_merge(models);      % Combine separate mixture models into one mixture model
  model = train_wsup(model, impos, neg_small, false, false, 1, 5, ...
      max_num_examples, fg_overlap, num_fp, false, 'mix_1');
  model_mix1 = model;
  %model = train_wsup(model, impos, neg_large, false, false, 1, 15, ...
  %    max_num_examples, fg_overlap, num_fp, true, 'mix_2');      
  
  save([cachedir cls '_mix'], 'model', 'model_mix1');
  
  [inds_mix, posscores_mix, lbbox_mix] = poslatent_wsup_getinds(model, pos, fg_overlap, 0);
  save([cachedir cls '_mix'], 'inds_mix', 'posscores_mix', 'lbbox_mix', '-append');
  
  displayExamplesPerSubcat4(cls, cachedir, year, conf.training.train_set_fg);
end
myprintfn;

disp('Testing mix');
try
    load([cachedir cls '_mix_goodInfo'], 'goodcomps', 'roc');
    goodcomps;
catch
    % test
    pascal_test_partialmodel(cachedir, cls, 'val', year, year, 'mix');
    
    % evaluate    
    load([cachedir cls '_boxes_' 'val' '_' year '_' 'mix'], 'ds_top');
    roc = getROCInfoPerComp2_nonjoint(ds_top, cachedir, n, recthresh);
    
    % decide
    numTrngInst = model.stats.filter_usage;
    numTrngInst_mix = zeros(n,1);
    for ck=1:n, numTrngInst_mix(ck) = numel(find(inds_mix == ck)); end
    [compaps, compaps_full, numInst, goodcomps] = deal(zeros(n, 1));
    for ck=1:n
        compaps_full(ck) = roc{ck}.ap_full_new*100;
        compaps(ck) = roc{ck}.ap_new*100;
        numInst(ck) = roc{ck}.npos;
        if compaps_full(ck) > minAPthresh_full && numInst(ck) >= minNumValInst &&...
                (numTrngInst(ck) >= minNumTrngInst || numTrngInst_mix(ck) >= minNumTrngInst) ...    % 5Sep13
                && ceil(compaps(ck)) >= minAPthresh                
            goodcomps(ck) = 1;
        end
    end
    
    disp(['Total of ' num2str(sum(goodcomps)) '/' num2str(n) ' good comps']);
    
    save([cachedir cls '_mix_goodInfo'], 'goodcomps', 'roc', 'numTrngInst');
end
myprintfn;
    
%{
%%% debugging code
[mimg_lrs1, mlab_lrs1] = getMontagesForModel_latent_wsup(inds_mix, inds_mix, ...
    inds_mix, posscores_mix, posscores_mix, lbbox_mix, pos, [], n);
mimg = montage_list_w_text(mimg_lrs1, mlab_lrs1, 2, '', [0 0 0], [2000 2000 3]);
imwrite(mimg, [cachedir '/display/montage_mix.jpg']);
%}

if doparts
    % Train a mixture model with 2x resolution parts using latent positives and hard negatives    
    disp('Doing parts');
    try        
        load([cachedir cls '_parts'], 'models'); models;        
    catch
        seed_rand();
        
        load([cachedir cls '_lrsplit1'], 'models');
        load([cachedir cls '_mix'], 'inds_mix');
        load([cachedir cls '_mix'], 'model');   %models = model_split(model, models);
        % update lrsplit models with latest weights from _mix model, so that parts are well initialized
        for i = 1:n            
            % bias
            bl_lhs = models{i}.rules{models{i}.start}(1).offset.blocklabel;
            bl_rhs = model.rules{model.start}(i).offset.blocklabel;
            if numel(models{i}.blocks(bl_lhs).w) ~= numel(model.blocks(bl_rhs).w), disp('error here'); keyboard; end
            models{i}.blocks(bl_lhs).w = model.blocks(bl_rhs).w;
            
            % filter (dsk: not sure how to index into filter, for now "-1" is a hack)            
            bl_lhs = models{i}.rules{models{i}.start}(1).offset.blocklabel-1;
            bl_rhs = model.rules{model.start}(i).offset.blocklabel-1;
            if numel(models{i}.blocks(bl_lhs).w) ~= numel(model.blocks(bl_rhs).w), disp('error here'); keyboard; end
            models{i}.blocks(bl_lhs).w = model.blocks(bl_rhs).w;
        end
        
        % add parts only to the "selected" components
        %load([cachedir '/' cls '_mix_goodInfo'], 'goodcomps');  docomps = goodcomps;
        load([cachedir '/' cls '_mix_goodInfo2'], 'selcomps', 'selcompsInfo');  docomps = selcomps;
        disp(['will be adding parts to ' num2str(length(find(docomps==1))) ' components']);
                
        phrasenames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg); 
        
        disp('Add parts to each mixture component');
        for i = 1:n
            disp([' ****** Doing component ' num2str(i) ' **********']);
            ruleind = 1;        % Top-level rule for this component
            partner = [];       % Top-level rule for this component's mirror image
            filterind = 1;      % Filter to interoplate parts from
            models{i} = model_add_parts(models{i}, models{i}.start, ruleind, ...
                partner, filterind, 8, [6 6], 1);
            % Enable learning location/scale prior
            bl = models{i}.rules{models{i}.start}(1).loc.blocklabel;
            models{i}.blocks(bl).w(:)     = 0;
            models{i}.blocks(bl).learn    = 1;
            models{i}.blocks(bl).reg_mult = 1;
            
            if docomps(i) == 1
                % Train using several rounds of positive latent relabeling
                % and data mining on the small set of negative images
                %imposToTrainOn = impos(inds_mix == i);
                disp(['generating new samples to make balanced data if insufficient; '...
                    'hacking up dataids; may cause problems if u train these models again!!!!']);
                %imposToTrainOn = generateNewImgInds_byDuplication(impos(inds_mix == i), numInstToTrain_allNgrams, neg(end).dataid);                                
                imposToTrainOn = generateNewImgInds_byMerging(impos(inds_mix == i), selcompsInfo{i}, cachedir, phrasenames, cls, year, neg(end).dataid, numLimitToTrainDPM);
                
                models{i} = train_wsup(models{i}, imposToTrainOn, neg_small, false, false, 8, 10, ...
                    max_num_examples, fg_overlap, num_fp, false, ['parts_1_' num2str(i)]);
                % Finish training by data mining on all of the negative images
                models{i} = train_wsup(models{i}, imposToTrainOn, neg_large, false, false, 1, 5, ...
                    max_num_examples, fg_overlap, num_fp, true, ['parts_2_' num2str(i)]);
            end
        end
        save([cachedir cls '_parts'], 'models', 'docomps');
                
        if 0 % do joint training here only if needed   
            disp('merge models and do max component regularziation (for debugging/poslatent purposes)');
            model = model_merge(models);
            for jj=1:numel(impos)       % add comp info to impos
                impos(jj).thisPosModelId = inds_mix(jj);
            end
            model = train_wsup_joint(model, impos, neg_small, false, false, 1, 15, ...
                max_num_examples, fg_overlap, num_fp, false, 'parts_3');
            save([cachedir cls '_parts'], 'model', '-append');
            
            [inds_parts, posscores_parts, lbbox_parts] = poslatent_wsup_getinds(model, pos, conf.training.fg_overlap, 0);
            save([cachedir cls '_parts'], 'inds_parts', 'posscores_parts', 'lbbox_parts', '-append');
        end
    end
end

fv_cache('free');

save([cachedir cls '_final'], 'model');

displayWeightVectorsPerAspect_v5(cls, cachedir);

close all;

diary off;

catch
    disp(lasterr); keyboard;
end
