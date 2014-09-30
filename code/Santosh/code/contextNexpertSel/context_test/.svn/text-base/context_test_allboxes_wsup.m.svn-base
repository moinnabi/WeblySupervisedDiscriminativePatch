function context_test_allboxes_wsup(cachedir, train_year, dataset, baseobjname, phrasenames)
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

numcls = length(phrasenames);
%if ~isempty(cls), cls_inds = strmatch(cls, phrasenames, 'exact');
%else cls_inds = 1:numcls; end
cls_inds = 1:numcls; 
%cls_ind = strmatch(cls, phrasenames, 'exact');

% Get detections, filter bounding boxes, and context feature vectors to be rescored
[ds_all, bs_all, XX] = context_data_wsup(cachedir, dataset, VOCyear, cls_inds, phrasenames);

disp(' merging boxes from all cngrams');
try
    load([cachedir baseobjname '_context_data_' dataset '_merged']);
catch    
    XX_old = XX;
    numids = numel(ds_all{1});
    [ds, bs, XX] = deal(cell(numids,1));
    for f=1:numel(ds_all)
        myprintf(f);
        for i=1:numids
            if ~isempty(ds_all{f}{i})
                ds{i} = [ds{i}; ds_all{f}{i}(:,1:end-1) ds_all{f}{i}(:,end)];
                bs{i} = [bs{i}; bs_all{f}{i}(:,1:end-1) bs_all{f}{i}(:,end)];
                XX{i} = [XX{i}; XX_old{f,i}];
            end
        end
    end
    save([cachedir baseobjname '_context_data_' dataset '_merged'], 'ds', 'bs', 'XX', '-v7.3');
end

ids = textread(sprintf(VOCopts.imgsetpath, dataset), '%s');
numids = length(ids);

fprintf('Rescoring detections\n');
try
    load([cachedir baseobjname '_boxes_' dataset '_context_' VOCyear]);
catch
    load([cachedir baseobjname '_context_classifier'], 'model');
    pos_ind = find(model.Label == 1);
    for i = 1:numids
        myprintf(i, 100);
        if ~isempty(XX{i})
            [~, ~, s] = svmpredict(ones(size(XX{i},1), 1), XX{i}, model);
            s = model.Label(1)*s;
            ds{i}(:,end) = s;
            bs{i}(:,end) = s;
        end
    end
    ds_nonms = ds;
    bs_nonms = bs;
    
    disp(' do nms');
    for i=1:numel(ds)
        myprintf(i, 100);        
        [blah, blah, nmsinds] = bboxNonMaxSuppression(ds{i}(:,1:4), ds{i}(:,end), 0.5);
        ds{i} = ds{i}(nmsinds,:);
        bs{i} = bs{i}(nmsinds,:);        
    end
    myprintfn;
    
    save([cachedir baseobjname '_boxes_' dataset '_context_' VOCyear], 'ds', 'bs', 'ds_nonms', 'bs_nonms');
end

%fprintf('Evaluating results\n');
%ap = pascal_eval(baseobjname, ds, dataset, VOCyear, ['context_' VOCyear]);
%fprintf(' %.3f\n', ap);

catch
    disp(lasterr); keyboard;
end
