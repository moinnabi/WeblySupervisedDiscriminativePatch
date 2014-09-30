function context_train_allboxes_wsup(cachedir, train_set, train_year, baseobjname, phrasenames)

% from context_train_wsup 
% main change is that I put all boxes together instead of just horse ngram
% boxes for rescoring

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;

%diary([cachedir '/diaryoutput_contextRescore_train.txt']);
disp(['context_train_allboxes_wsup(''' cachedir ''',''' train_set ''',''' train_year ''',''' baseobjname '' ', phrasenames)' ]);

numcls = length(phrasenames);
%if ~isempty(cls), cls_inds = strmatch(cls, phrasenames, 'exact');
%else cls_inds = 1:numcls; end
cls_inds = 1:numcls;
%cls_inds = strmatch(cls, phrasenames, 'exact');

% Get training data
[ds_all, bs_all, XX] = context_data_wsup(cachedir, train_set, train_year, cls_inds, phrasenames);

disp(' merging boxes from all cngrams');
try
    load([cachedir baseobjname '_context_data_' train_set '_merged']);
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
    save([cachedir baseobjname '_context_data_' train_set '_merged'], 'ds', 'bs', 'XX');
end

disp(' apply nms');
try
    load([cachedir baseobjname '_context_data_' train_set '_merged_nms']);
catch    
    nmsolap = 0.6;  % ensures between 91% to 95% recall    
    for i=1:numel(ds)
        myprintf(i, 10);
        %nmsinds = nms(ds{i}, nmsolap);
        [blah, blah, nmsinds] = bboxNonMaxSuppression(ds{i}(:,1:4), ds{i}(:,end), nmsolap);
        ds{i} = ds{i}(nmsinds,:);
        bs{i} = bs{i}(nmsinds,:);
        XX{i} = XX{i}(nmsinds, :);
    end
    myprintfn;
    save([cachedir baseobjname '_context_data_' train_set '_merged_nms'], 'ds', 'bs', 'XX');
end


fprintf('Training context rescoring classifier for %s\n', baseobjname);
try
    load([cachedir baseobjname '_context_classifier']);
catch
    disp(' Get labels for the training data for class cls');
    YY = context_labels_wsup(cachedir, baseobjname, ds, train_set, train_year);
    X = [];
    Y = [];
    disp(' Collect training feature vectors and labels into a single matrix and vector');    
    X = cell2mat(XX);
    Y = cell2mat(YY);
    %{
    for i = 1:size(XX,1)
        myprintf(i,100);
        X = [X; XX{i}];
        Y = [Y; YY{i}];
    end
    myprintfn;
    %}
    
    disp(' Remove dont care examples');
    I = find(Y == 0);
    Y(I) = [];
    X(I,:) = [];
    
    % Train the rescoring SVM
    if 1
    disp('doing non linear (polynomial) svm');
    %model = svmtrain(Y, X, '-s 0 -t 1 -g 1 -r 1 -d 3 -c 1 -w1 2 -e 0.001 -m 500');
    model = doHardMining(Y, X, 10);
    else
    disp('doing linear svm');
    model = svmtrain(Y, X, '-s 0 -t 0 -c 1 -w1 2 -e 0.001 -m 500');
    end
    
    % compute training acc
    load([cachedir baseobjname '_gt_anno_' train_set '_' train_year], 'npos');
    [~, ~, s] = svmpredict(ones(size(X,1), 1), X, model);
    s = model.Label(1)*s;
    roc = computeROC(s, Y);
    roc.r = roc.r*roc.tp(end)/npos;
    roc.ap = averagePrecision(roc, (0:0.1:1));
        
    save([cachedir baseobjname '_context_classifier'], 'model', 'roc');
end

%diary off;

catch
    disp(lasterr); keyboard;
end
