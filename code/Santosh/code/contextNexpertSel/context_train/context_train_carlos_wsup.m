function context_train_carlos_wsup(cachedir, train_set, train_year, cls, phrasenames, CLSFR)

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;

disp(['context_train_carlos_wsup(''' cachedir ''',''' train_set ''',''' train_year ''',''' cls ''','' phrasenames '',''' num2str(CLSFR) ''')' ]);

disp('Get training data');
[XX, ds_imall] = context_data_carlos_wsup(cachedir, train_set, train_year, phrasenames);
ids = textread(sprintf(conf.pascal.VOCopts.imgsetpath, train_set), '%s'); 
%for i=1:numel(ds_imall), ds_imall{i}(:,end+1) = i; end

if CLSFR == 1
    clsfrtype = 'KSVMnoSIG';
elseif CLSFR == 2
    clsfrtype = 'KRBFSVMnoSIG';
elseif CLSFR == 3
    clsfrtype = 'K5SVMnoSIG';
elseif CLSFR == 4
    clsfrtype = 'LSVMnoSIG';
end

if strcmp(train_set, 'val2')
    savecode = 'context';
elseif strcmp(train_set, 'val1')
    savecode = 'val1context';
end

gtruthname = cls;

savaname = [cachedir '/' cls '_' savecode '_' clsfrtype '.mat'];
fprintf('Training context rescoring classifier\n');
try
    load(savaname);
catch
    disp([' Get labels for the training data for class ' cls]);
    [YY, YYolap] = context_labels_wsup(cachedir, gtruthname, ds_imall, train_set, train_year);
        
    disp(' Collect training feature vectors and labels into a single matrix and vector');
    X = cell2mat(XX(:));
    Y = cell2mat(YY(:));
    Yolap = cell2mat(YYolap(:));
    if size(X,1) ~= size(Y,1), disp('dimension mismatch'); keyboard; end
       
    disp(' Remove dont care examples');
    I = find(Y == 0);
    Y(I) = [];
    Yolap(I) = [];
    X(I,:) = [];
        
    % Train the rescoring SVM
    if CLSFR == 1
        disp('doing non linear (polynomial d3) svm');
        optionString = '-s 0 -t 1 -g 1 -r 1 -d 3 -c 1 -w1 2 -e 0.001 -m 500';
        model = doHardMining(Y,X, 10, optionString);
        %model = svmtrain(Y, X, '-s 0 -t 1 -g 1 -r 1 -d 3 -c 1 -w1 2 -e 0.001 -m 500');
    elseif CLSFR == 2
        disp('doing non linear (RBF) svm');
        optionString = '-s 0 -t 2 -g 1 -c 1 -w1 2 -e 0.001 -m 500';
        model = doHardMining(Y,X, 10, optionString);
    elseif CLSFR == 3
        disp('doing non linear (polynomial d5) svm');
        optionString = '-s 0 -t 1 -g 1 -r 1 -d 5 -c 1 -w1 2 -e 0.001 -m 500';
        model = doHardMining(Y,X, 10, optionString);
    elseif CLSFR == 4
        disp('doing linear svm');
        model = svmtrain(Y, X, '-s 0 -t 0 -c 1 -w1 2 -e 0.001 -m 500');
    end
    
    disp('compute training acc');
    s = [];
    if CLSFR == 1 || CLSFR == 2 || CLSFR == 3 || CLSFR == 4
        [~, ~, s] = svmpredict(ones(size(X,1), 1), X, model);
        s = model.Label(1)*s;
    end
    
    load([cachedir cls '_gt_anno_' train_set '_' train_year], 'npos');
    roc = computeROC(s, Y);
    roc.r = roc.r*roc.tp(end)/npos;
    roc.ap = averagePrecision(roc, (0:0.1:1));
    disp([' training acc is ' num2str(roc.ap)]);
    
    save(savaname, 'model', 'roc', 's');
end

catch
    disp(lasterr); keyboard;
end
