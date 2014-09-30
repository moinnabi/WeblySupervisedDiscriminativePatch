function pascal_test_sumpool_reducer(cachedir, cls, testset, year, suffix, modelname, postag)

try    

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;

if nargin < 6
    modelname = '';
end

if nargin < 7
    postag = 'NOUN';
end

disp(['pascal_test_sumpool_reducer(''' cachedir ''',''' cls ''',''' testset ''',''' year ''',''' suffix ''',''' modelname ''',''' postag ''');' ]);

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
VOCopts  = conf.pascal.VOCopts;
cachedir = conf.paths.model_dir;

% copied from pascal.m
if isempty(modelname)   % if modelname = 'final', leave it empty
    %disp('loading final (parts) model');
    %load([cachedir '/' cls '_final.mat'], 'model');
    savename = [cachedir cls '_boxes_' testset '_' suffix];
else
    %disp('loading non-final (no parts/mix/joint) model');
    %load([cachedir '/' cls '_' modelname '.mat'], 'model');
    savename = [cachedir cls '_boxes_' testset '_' suffix '_' modelname];
end
%model.thresh = min(conf.eval.max_thresh, model.thresh);
%model.interval = conf.eval.interval;

%ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
if strcmp(postag, 'NOUN')
    ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
elseif strcmp(postag, 'VERB')
    ids = textread(sprintf(VOCopts.action.imgsetpath, testset), '%s');
end

% run detector in each image
try    
    load(savename);
catch  
    num_ids = length(ids);
    ds_out = cell(1, num_ids);
    bs_out = cell(1, num_ids);
    ds_sumout = cell(1, num_ids);   % sumpooling    
    for i = 1:num_ids    
        myprintf(i,100);
        load([cachedir '/testFiles_' year '/' '/output_' num2str(i) '.mat'], 'ds_save', 'bs_save', 'ds_sumsave');        
        ds_out{i} = ds_save; 
        ds_sumout{i} = ds_sumsave;
        bs_out{i} = bs_save;
    end
    ds = ds_out;
    bs = bs_out;
    ds_sum = ds_sumout;
    save(savename, 'ds', 'bs', 'ds_sum');    
end
myprintfn;

displayDetection_rankedMontages_v5(cls, testset, cachedir, year, suffix, modelname, postag);

catch
    disp(lasterr); keyboard;
end
