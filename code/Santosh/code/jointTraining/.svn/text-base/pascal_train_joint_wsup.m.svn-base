function model = pascal_train_joint_wsup(cls, objname, fname_imgcl_sprNg, cachedir, year, fg_olap, borderoffset, jointCacheLimit, n_perngram, do_retraining)

try
% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
seed_rand();

if isdeployed, n_perngram = str2num(n_perngram); end
if isdeployed, fg_olap = str2num(fg_olap); end
if isdeployed, borderoffset = str2num(borderoffset); end
if isdeployed, jointCacheLimit = str2num(jointCacheLimit); end  %set this variable corectly/calclate; be careful while modifying params (rembr ur old exp where u modified memory and had to modify #iterations)
if isdeployed, do_retraining = str2num(do_retraining); end

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
VOC_CONFIG_OVERRIDE.training.fg_overlap = fg_olap; %0.25;
VOC_CONFIG_OVERRIDE.training.train_set_fg = 'train';
%borderoffset = 0.07;      % if its a 100pixel image, ignore a 8-pixel margin (7/100*500)
diary([cachedir '/diaryoutput_train.txt']);
disp(['pascal_train_joint_wsup(''' cls ''',''' objname ''',''' fname_imgcl_sprNg ''',''' cachedir ''',''' year ''',' num2str(fg_olap) ',' num2str(borderoffset) ',' num2str(jointCacheLimit) ',' num2str(n_perngram) ',' num2str(do_retraining) ')' ]);

% set this variable corectly/calclate; be careful while modifying params
% (rembr ur old exp where u modified memory and had to modify #iterations)
VOC_CONFIG_OVERRIDE.training.cache_byte_limit = jointCacheLimit; %2*(3*2^30);
conf = voc_config();
disp(['RAM usage is ' num2str(conf.training.cache_byte_limit)]); 
conf.borderoffset = borderoffset;
save([cachedir 'conf.mat'], 'conf');

mymkdir([cachedir '/intermediateModels/']); 

% the dot is important
filenameWithPath = which('linuxUpdateSystemNumThreadsToMax.sh');    % avoids hardcoding filepath (/projects/grail/santosh/objectNgrams/code/utilScripts/linuxUpdateSystemNumThreadsToMax.sh')
system(['. ' filenameWithPath]);
%linuxUpdateSystemNumThreadsToMax_mat;

max_num_examples = conf.training.cache_example_limit;
num_fp           = conf.training.wlssvm_M;
fg_overlap       = conf.training.fg_overlap;

phrasenames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg);

load([cachedir cls '_joint_data'], 'pos', 'impos', 'neg', 'models_all', 'model', ...
        'inds_befjnt', 'posscores_befjnt', 'lbbox_befjnt');
%{
try
    load([cachedir cls '_joint_data'], 'pos', 'impos', 'neg', 'models_all', 'model', ...
        'inds_befjnt', 'posscores_befjnt', 'lbbox_befjnt');
catch
    disp('Load existing data (pos, neg, models)');
    k = 1;
    listOfSelNgramComps_globalIds = [];
    listOfSelNgramComps_accs = [];
    [pos_all, impos_all, models_all, inds_befjnt, posscores_befjnt, lbbox_befjnt] = deal([]);
    for ii = 1:numel(phrasenames)
        myprintf(ii,10);
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_' conf.training.train_set_fg '_' conf.pascal.year], 'pos', 'neg', 'impos');
        [pos, neg, impos] = updatePathForAWS(pos, neg, impos);
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_parts'], 'models', 'docomps');
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_mix'], 'inds_mix', 'posscores_mix', 'lbbox_mix');        
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_mix_goodInfo2'], 'selcomps', 'selcompsInfo');
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_mix_goodInfo'], 'roc');
        [compaps_full, compaps] = deal(zeros(n_perngram,1));
        for ck=1:n_perngram
            compaps_full(ck) = roc{ck}.ap_full_new*100;
            compaps(ck) = roc{ck}.ap_new*100;
        end
        for j=1:n_perngram
            if selcomps(j) == 1
                if docomps(j) ~= 1, disp('this model not trained'); keyboard; end
                models_all{k} = models{j};
                models_all{k}.class = [models{j}.class ' ' num2str(j)];
                listOfSelNgramComps_globalIds = [listOfSelNgramComps_globalIds; (ii-1)*n_perngram+j];
                listOfSelNgramComps_accs = [listOfSelNgramComps_accs; compaps_full(j)];
                pos_tmp = pos(inds_mix == j);
                impos_tmp = impos(inds_mix == j);
                for jj=1:numel(pos_tmp)     % add comp info to impos
                    pos_tmp(jj).thisPosModelId = k;
                    impos_tmp(jj).thisPosModelId = k;
                end
                inds_befjnt = [inds_befjnt; k*ones(numel(pos_tmp),1)];
                posscores_befjnt = [posscores_befjnt; posscores_mix(inds_mix==j,:)];
                lbbox_befjnt = [lbbox_befjnt; lbbox_mix(inds_mix==j,:)];
                pos_all = [pos_all pos_tmp];
                impos_all = [impos_all impos_tmp];
                k = k + 1;
            end
        end
    end
    myprintfn;
    
    pos = pos_all;
    impos = impos_all;
    disp('get negatives'); 
    %neg = neg;      % neg of last guy  ('train' set)
    neg = pascal_data_wsup_neg(conf.pascal.VOCopts, ['baseobjectcategory_' objname '_val1_withLabels'], year);  %'val' set
    [pos, impos, neg] = updateDataIds_jointData(pos, impos, neg);   
    model = model_merge(models_all);
    model.phrasenames = getphrasenames_modelmerged(models_all);
    model.class = cls;
    clear pos_all impos_all;
    save([cachedir cls '_joint_data'], 'pos', 'impos', 'neg', 'models_all', 'model',...
        'inds_befjnt', 'posscores_befjnt', 'lbbox_befjnt', 'listOfSelNgramComps_globalIds',...
        'listOfSelNgramComps_accs');
end 
myprintfn;
%}
        
%length(models_all)
disp(['Will jointly train a total of ' num2str(numel(model.rules{model.start})) ' components']);

mymatlabpoolopen;

% Select a small, random subset of negative images
% All data mining iterations use this subset, except in a final
% round of data mining where the model is exposed to all negative
% images
num_neg   = length(neg);
neg_perm  = neg(randperm(num_neg));
neg_small = neg_perm(1:min(num_neg, conf.training.num_negatives_small));
neg_large = neg; % use all of the negative images

disp('Doing training');
try
    load([cachedir cls '_joint'], 'inds_joint', 'posscores_joint', 'lbbox_joint');
    inds_joint;
catch
    seed_rand();
    
    if do_retraining
        disp('will do max component regularziation');
        model = train_wsup_joint(cachedir, model, impos, neg_large, false, false, 1, 20, ...
            max_num_examples, fg_overlap, num_fp, false, 'joint_1');
        save([cachedir cls '_joint'], 'model'); %, 'model_joint1', 'model_joint2', 'model_joint3');
    else
        disp('not doing any max component regularization');
    end
    %{
    model_joint1 = model;
    model = train_wsup_joint(model, impos, neg_small, false, false, 1, 25, ...
        max_num_examples, fg_overlap, num_fp, true, 'joint_2');
    model_joint2 = model;
    model = train_wsup(model, impos, neg_large, false, false, 1, 10, ...
        max_num_examples, fg_overlap, num_fp, true, 'joint_3');
    %}
    
    
    [inds_joint, posscores_joint, lbbox_joint] = poslatent_wsup_getinds(model, pos, fg_overlap, 0);
    save([cachedir cls '_joint'], 'inds_joint', 'posscores_joint', 'lbbox_joint', '-append');
end

disp('Generating displays for debugging');
dispdir = [cachedir '/display/']; mymkdir(dispdir);
[mimg_befjnt, mlab_befjnt] = getMontagesForModel_latent_wsup(inds_befjnt, inds_befjnt, ...
    inds_befjnt, posscores_befjnt, posscores_befjnt, lbbox_befjnt, pos, [], numel(model.rules{model.start}));
[mimg_joint, mlab_joint] = getMontagesForModel_latent_wsup(inds_joint, inds_joint, ...
    inds_joint, posscores_joint, posscores_joint, lbbox_joint, pos, [], numel(model.rules{model.start}));
disp('Writing montages');
mimg_cell = {mimg_befjnt; mimg_joint};
mlab_cell = {mlab_befjnt; mlab_joint;};
writeFinalMontages_latent(dispdir, mimg_cell, mlab_cell);

[mimg_lrs3x3, ~, mimg_avg] = get3x3MontagesForModel_latent_wsup(inds_joint, inds_joint, ...
    inds_joint, posscores_joint, posscores_joint, lbbox_joint, pos, [], numel(model.rules{model.start}), model);
for k=1:numel(model.rules{model.start})+1
    myprintf(k,10);
    imwrite(mimg_lrs3x3{k}, [dispdir '/montage3x3_' num2str(k-1, '%03d') '.jpg']);
    imwrite(mimg_avg{k}, [dispdir '/montageAVG_' num2str(k-1, '%03d') '.jpg']);
end

fv_cache('free');
diary off;

catch
    disp(lasterr); keyboard;
end
