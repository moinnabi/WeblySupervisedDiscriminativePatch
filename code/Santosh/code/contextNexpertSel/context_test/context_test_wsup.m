function context_test_wsup(cachedir, train_year, dataset, cls, baseobjname, phrasenames)
% Rescore detections on the test dataset using the context
% rescoring SVMs trained by context_train.m.
%   ap = context_test(dataset, cls)
%
% Return value
%   ap          AP score for context rescoring
%
% Arguments
%   dataset     Dataset to context rescore
%   cls         Object class to rescore (if not given, all are rescored)

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config();
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;
VOCyear  = conf.pascal.year;

cls_ind = strmatch(cls, phrasenames, 'exact');

% Get detections, filter bounding boxes, and context feature vectors to be rescored
[ds_all, bs_all, X] = context_data_wsup(cachedir, dataset, VOCyear, cls_ind, phrasenames);

ids = textread(sprintf(VOCopts.imgsetpath, dataset), '%s');
numids = length(ids);

fprintf('Rescoring detections\n');
try
    load([cachedir baseobjname '_boxes_' dataset '_context_' VOCyear]);
catch
    load([cachedir baseobjname '_context_classifier']);
    pos_ind = find(model.Label == 1);
    for i = 1:numids
        if ~isempty(X{cls_ind,i})
            [~, ~, s] = svmpredict(ones(size(X{cls_ind,i},1), 1), X{cls_ind,i}, model);
            s = model.Label(1)*s;
            ds_all{cls_ind}{i}(:,end) = s;
            bs_all{cls_ind}{i}(:,end) = s;
        end
    end
    ds = ds_all{cls_ind};
    bs = bs_all{cls_ind};
    save([cachedir baseobjname '_boxes_' dataset '_context_' VOCyear], 'ds', 'bs');
end

%fprintf('Evaluating results\n');
%ap = pascal_eval(baseobjname, ds, dataset, VOCyear, ['context_' VOCyear]);
%fprintf(' %.3f\n', ap);

catch
    disp(lasterr); keyboard;
end
