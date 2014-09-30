function num_ids = getNumImagesInDataset(cachedir, year, testset, postag)

if nargin < 4
    postag = 'NOUN';
end

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
VOCopts  = conf.pascal.VOCopts;

%ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
if strcmp(postag, 'NOUN')
    ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
elseif strcmp(postag, 'VERB')
    ids = textread(sprintf(VOCopts.action.imgsetpath, testset), '%s');
end

num_ids = length(ids);
