function model = pascal_train_joint(cls, n, note, cachedir, year)
% Train a model.
%   model = pascal_train(cls, n, note)
%
%   The model will be a mixture of n star models, each of which
%   has 2 latent orientations.
%
% Arguments
%   cls           Object class to train and evaluate
%   n             Number of aspect ratio clusters to use
%                 (The final model has 2*n components)
%   note          Save a note in the model.note field that describes this model

try
% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
seed_rand();

% Default to no note
if nargin < 3
    note = '';
end

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
diary([cachedir '/diaryoutput.txt']);
disp(['pascal_train_joint(''' cls ''',' num2str(n) ',''' note ''',''' cachedir ''',''' year ''')' ]);

conf = voc_config();
% Train a mixture model composed all of aspect ratio groups and
% latent orientation choices using latent positives and hard negatives
try
    load([cachedir cls '_joint']);
catch
    model6 = load([cachedir cls '_final_6']);
    models{1} = model6.model;
    model15 = load([cachedir cls '_final_15']);
    models{2} = model15.model;
    
    model = model_merge(models);
    save([cachedir cls '_joint'], 'model');
end

save([cachedir cls '_final'], 'model');

diary off;
catch
    disp(lasterr); keyboard;
end
