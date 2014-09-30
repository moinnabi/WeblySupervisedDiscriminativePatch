function context_test_carlos_wsup(cachedir, train_year, trainset, dataset, objname, phrasenames, CLSFR)

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;
VOCyear  = conf.pascal.year;

disp(['context_test_carlos_wsup(''' cachedir ''',''' train_year ''',''' trainset ''',''' dataset ''',''' objname ''','' phrasenames '',''' num2str(CLSFR) ''')' ]);

[XX, ds_imall] = context_data_carlos_wsup(cachedir, dataset, VOCyear, phrasenames);

ids = textread(sprintf(VOCopts.imgsetpath, dataset), '%s');
numids = length(ids);

if CLSFR == 1
    clsfrtype = 'KSVMnoSIG';
elseif CLSFR == 2
    clsfrtype = 'KRBFSVMnoSIG';
elseif CLSFR == 3
    clsfrtype = 'K5SVMnoSIG';    
elseif CLSFR == 4
    clsfrtype = 'LSVMnoSIG';
end

if strcmp(trainset, 'val2')
    savecode = 'context';
elseif strcmp(trainset, 'val1')
    savecode = 'val1context';
end

savename = [cachedir '/' objname '_boxes_' dataset '_' savecode '_' clsfrtype '_' VOCyear '.mat'];
try
    load(savename);
catch    
    disp(['Rescoring detections ']);
    load([cachedir '/' objname '_' savecode '_' clsfrtype], 'model');
    for i = 1:numids
        myprintf(i, 100);
        if ~isempty(XX{i})
            s = [];
            if CLSFR == 1 || CLSFR == 2 || CLSFR == 3
                if ~isempty(model.sv_coef)
                    [~, ~, s] = svmpredict(ones(size(XX{i},1), 1), XX{i}, model);
                    s = model.Label(1)*s;
                end
            end
            if ~isempty(s)
                ds_imall{i}(:,end) = s;                
            end
        end
    end
    myprintfn;
    ds = ds_imall;    
    
    disp(' do nms');
    nmsolap = 0.5;
    for i=1:numel(ds)
        myprintf(i, 100);
        if ~isempty(ds{i})
            [blah, blah, nmsinds] = bboxNonMaxSuppression(ds{i}(:,1:4), ds{i}(:,end), nmsolap);
            ds{i} = ds{i}(nmsinds,:);            
        end
    end
    myprintfn;
    
    save(savename, 'ds', 'ds_imall', 'nmsolap');    
    %fprintf('Evaluating results\n');
    %ap = pascal_eval(objname, ds, dataset, VOCyear, ['context_' VOCyear]);
    %fprintf(' %.3f\n', ap);
end

catch
    disp(lasterr); keyboard;
end
