function context_train_wsup(cachedir, train_set, train_year, cls, baseobjname, phrasenames)

% from context_train but for ngram data
% %% main change is that cls is "horse" while baseobjname is "base_horse" as
% gtrtuh for horse is named so

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;

diary([cachedir '/diaryoutput_contextRescore_train.txt']);
disp(['context_train_wsup(''' cachedir ''',''' train_set ''',''' train_year ''',''' cls ''',''' baseobjname '' ', phrasenames)' ]);

numcls = length(phrasenames);
if ~isempty(cls), cls_inds = strmatch(cls, phrasenames, 'exact');
else cls_inds = 1:numcls; end
%cls_ind = strmatch(cls, phrasenames, 'exact');

% Get training data
[ds_all, bs_all, XX] = context_data_wsup(cachedir, train_set, train_year, cls_inds, phrasenames);

fprintf('Training context rescoring classifier for %s\n', baseobjname);
try
    load([cachedir baseobjname '_context_classifier']);
catch
    % Get labels for the training data for class cls
    YY = context_labels_wsup(cachedir, baseobjname, ds_all{cls_ind}, train_set, train_year);
    X = [];
    Y = [];
    % Collect training feature vectors and labels into a single matrix and vector
    for i = 1:size(XX,2)
        X = [X; XX{cls_ind,i}];
        Y = [Y; YY{i}];
    end
    % Remove "don't care" examples
    I = find(Y == 0);
    Y(I) = [];
    X(I,:) = [];
    
    % Train the rescoring SVM
    if 0
    disp('doing non linear (polynomial) svm');
    model = svmtrain(Y, X, '-s 0 -t 1 -g 1 -r 1 -d 3 -c 1 -w1 2 -e 0.001 -m 500');
    else
    disp('doing linear svm');
    model = svmtrain(Y, X, '-s 0 -t 0 -c 1 -w1 2 -e 0.001 -m 500');
    end
    
    save([cachedir baseobjname '_context_classifier'], 'model');
end

diary off;

catch
    disp(lasterr); keyboard;
end
