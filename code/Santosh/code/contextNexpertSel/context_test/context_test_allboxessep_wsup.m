function context_test_allboxessep_wsup(cachedir, train_year, traindataset, dataset, objname, gtruthname, phrasenames, CLSFR, thiscls)

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;
VOCyear  = conf.pascal.year;

if nargin < 9, thiscls = []; end;
disp(['context_test_allboxessep_wsup(''' cachedir ''',''' train_year  ''',''' traindataset ''',''' dataset ''',''' objname ''',''' gtruthname ''''', phrasenames '','''  num2str(CLSFR) ''',''' thiscls ')' ]);

IGNOREBADONES = 1;
disp('IGNOREBADONES is on'); keyboard;
trainaccthresh = 0.25;

numcls = length(phrasenames);

% get training accuracies
trainaps = zeros(numcls,1);
for ii=1:numcls
    myprintf(ii, 10);
    tmppr = load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_prpos_' traindataset '_' train_year '.mat'], 'ap');
    trainaps(ii) = tmppr.ap;
end
myprintfn;

if ~isempty(thiscls)
    cls_inds = strmatch(thiscls, phrasenames, 'exact');
else        
    if IGNOREBADONES
        % only pass those above a threshold        
        cls_inds = find(trainaps>trainaccthresh)';
    else
        cls_inds = 1:numcls;
    end
    disp(['Doing a total of ' num2str(numel(cls_inds)) ' ngrams']);
end

% Get detections, filter bounding boxes, and context feature vectors to be rescored
[ds_all, bs_all, XX] = context_data_wsup(cachedir, dataset, VOCyear, cls_inds, phrasenames);

ids = textread(sprintf(VOCopts.imgsetpath, dataset), '%s');
numids = length(ids);

if CLSFR == 2
    clsfrtype = 'KLogReg';
elseif CLSFR == 4
    clsfrtype = 'SVRolap';
elseif CLSFR == 5
    clsfrtype = 'KSVMSIG';
elseif CLSFR == 6
    clsfrtype = 'KLinReg';
elseif CLSFR == 1
    clsfrtype = 'KSVMnoSIG';
elseif CLSFR == 3
    clsfrtype = 'LSVMnoSIG';
elseif CLSFR == 7
    clsfrtype = 'LSVMLRank';
elseif CLSFR == 8
    clsfrtype = 'LSVMPAUC';
elseif CLSFR == 10
    clsfrtype = 'KSVMLRank';
elseif CLSFR == 9
    clsfrtype = 'KSVMPAUC';    
end

if strcmp(traindataset, 'val2')
    gtsubdir = '';
    contexttype = [gtsubdir 'context'];
elseif strcmp(traindataset, 'val1')
    gtsubdir = 'p33tn';
    contexttype = [gtsubdir  'val1context'];
end
%if isempty(gtruthname), savecode = thiscls;
%else savecode = gtruthname; end
savecode = [clsfrtype '_' gtruthname];
savename = [cachedir objname '_boxes_' dataset '_' contexttype '_' savecode '_' VOCyear];
try
    load(savename);
catch    
    disp(['Rescoring detections ']);
    for c = cls_inds
        myprintf(c,10);
        cls = phrasenames{c};
        %if isempty(gtruthname), loadcode = cls;
        %else loadcode = gtruthname; end
        load([cachedir '/../' cls '/' cls '_' contexttype '_' clsfrtype '_' gtruthname], 'model');
        for i = 1:numids            
            if ~isempty(XX{c,i})
                s = [];
                if CLSFR == 1 || CLSFR == 3
                    if ~isempty(model.sv_coef)
                    [~, ~, s] = svmpredict(ones(size(XX{c,i},1), 1), XX{c,i}, model);
                    s = model.Label(1)*s;
                    end
                elseif CLSFR == 5
                    if ~isempty(model.sv_coef)
                    [~, ~, s] = svmpredict(ones(size(XX{c,i},1), 1), XX{c,i}, model, '-b 1');                    
                    s = s(:,model.Label == 1);
                    end
                elseif CLSFR == 4                    
                    [~, ~, s] = svmpredict(ones(size(XX{c,i},1), 1), XX{c,i}, model);
                elseif CLSFR == 2  
                    X = XX{c,i};
                    s = zeros(size(X,1),1);
                    for ii=1:size(X,1)
                        kvect = (1 + model.X * X(ii,:)').^2;
                        s(ii) = 1./(1+exp(- model.w' * kvect));
                    end
                elseif CLSFR == 6
                    s = model.w' * (1+model.X*XX{c,i}').^2;
                elseif CLSFR == 7
                    s = XX{c,i}*model.w;
                elseif CLSFR == 8
                    s = XX{c,i}*model.w;      
                elseif CLSFR == 9
                    s = pasTestKernelSvm_perfNoCV(XX{c,i},model);
                elseif CLSFR == 10
                    s = pasTestKernelSvmLight_rank(XX{c,i},model);
                end
                if ~isempty(s)
                ds_all{c}{i}(:,end) = s;
                bs_all{c}{i}(:,end) = s;
                end
            end
        end                                
    end
    myprintfn;
    
    disp(['merge detections ']);
    [ds, bs] = deal(cell(numids,1));
    for c=cls_inds
        myprintf(c, 10);
        for i=1:numids
            if ~isempty(ds_all{c}{i})
                ds{i} = [ds{i}; ds_all{c}{i}(:,1:end-1) ds_all{c}{i}(:,end)];
                bs{i} = [bs{i}; bs_all{c}{i}(:,1:end-1) bs_all{c}{i}(:,end)];                
            end
        end
    end
    myprintfn;
    ds_nonms = ds;
    bs_nonms = bs;
    
    disp(' do nms');
    nmsolap = 0.25; % 28Jan13: changed from 0.5 to 0.25; this is last stage so be conservative and get rid of duplicate dets (at the cost of missing recall)
    for i=1:numel(ds)
        myprintf(i, 100);
        if ~isempty(ds{i})
            [blah, blah, nmsinds] = bboxNonMaxSuppression(ds{i}(:,1:4), ds{i}(:,end), nmsolap);
            ds{i} = ds{i}(nmsinds,:);
            bs{i} = bs{i}(nmsinds,:);
        end
    end
    myprintfn;
    
    if isempty(thiscls), save(savename, 'ds', 'bs', 'ds_all', 'bs_all', 'ds_nonms', 'bs_nonms', 'nmsolap');
    else save(savename, 'ds', 'bs', 'ds_nonms', 'bs_nonms', 'nmsolap'); end
    %fprintf('Evaluating results\n');
    %ap = pascal_eval(objname, ds, dataset, VOCyear, ['context_' VOCyear]);
    %fprintf(' %.3f\n', ap);
end

catch
    disp(lasterr); keyboard;
end
