function doExpertSel_train(cachedir, train_year, traindataset, heldoutset, objname, phrasenames, suffix)

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;

disp(['doExpertSel_train(''' cachedir ''',''' train_year  ''',''' traindataset ''',''' heldoutset ''',''' objname ''','' phrasenames  '',''' suffix ''')' ]);

numcls = numel(phrasenames);

disp(['phraseorder is determined by performance on ' heldoutset ' set']);
apresults = zeros(numcls, 1);
for ii = 1:numcls
    myprintf(ii,10);    
    pr = load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_pr_' heldoutset '_' train_year '.mat'], 'ap_base');
    apresults(ii, 1) = pr.ap_base;
    %pr = load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_prpos_' heldoutset '_' train_year '.mat'], 'ap');
    %apresults(ii, 1) = pr.ap;
end
myprintfn;
[~, phraseorder] = sort(apresults, 'descend');

largeval = 10;
precval = [0.95 0.85 0.75 0.65 0.55 0.45 0.35 0.25 0.15 0.1 0];
%precval = 0.99:-0.02:0;
phrasethreshs = largeval*ones(numcls, numel(precval));
if strcmp(suffix, 'thresh1')
    disp('phrasetheshs is determind based on model thresh');
    for ii = 1:numcls
        myprintf(ii,10);
        tmpmod = load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_final.mat'], 'model');
        phrasethreshs(ii,1) = tmpmod.model.thresh;
    end
    myprintfn;
elseif strcmp(suffix, 'thresh2') || strcmp(suffix, 'thresh3') || strcmp(suffix, 'thresh3b') ||...
        strcmp(suffix, 'thresh4') || strcmp(suffix, 'thresh5') || strcmp(suffix, 'thresh6')
    disp(['phrasetheshs is determind based on prec wrt to '  heldoutset]);
    for ii = 1:numcls
        myprintf(ii,10);        
        clear prec_base scores
        load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_pr_' heldoutset '_' train_year '.mat'], 'prec_base', 'scores');
        prprec = prec_base;
        %load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_prpos_' heldoutset '_' train_year '.mat'], 'prec', 'scores');
        %prprec = prec;
        scores = sort(scores, 'descend');
        for j=1:numel(precval)
            indval = find(prprec > precval(j), 1, 'last');            
            if ~isempty(indval)
                phrasethreshs(ii, j) = scores(indval);
            end
        end
    end
    myprintfn;
end

ignorephrases=[];
phraseorder_orig = phraseorder;
if 0
disp('ignore really bad ngrams');
trainaps = zeros(numcls,1);
for ii=1:numcls     % get training accuracies
    myprintf(ii, 10);
    tmppr = load([cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_prpos_' traindataset '_' train_year '.mat'], 'ap');
    trainaps(ii) = tmppr.ap;
end
myprintfn;
trainaccthresh = 0.25;
ignorephrases_train = find(trainaps<trainaccthresh);

testaccthresh = 0.02;
ignorephrases_test = find(apresults<testaccthresh);

ignorephrases = union(ignorephrases_train, ignorephrases_test);

commonrows = ismember(phraseorder, ignorephrases);
phraseorder(commonrows,:) = [];
end

disp('load unsup sigmoid params');
gtsubdir = 'p33tn';
sigparams = cell(numcls, 1);
for ii=1:numcls
    myprintf(ii,10);
    fname = [cachedir '/../' phrasenames{ii} '/' phrasenames{ii} '_calibParamsHOPC_' gtsubdir traindataset '_' objname '.mat'];
    if exist(fname, 'file')
        tmpsig = load(fname, 'sigAB');
        sigparams{ii} = tmpsig.sigAB;
    else
        numcomps = 6;
        sigparams{ii} = repmat([-1.5 0], numcomps, 1);
        fprintf('no');
    end
end
myprintfn;

save([cachedir '/' objname '_ordering_' traindataset suffix '_' train_year '.mat'], 'phraseorder', 'phrasethreshs', 'ignorephrases', 'phraseorder_orig', 'sigparams');

catch
    disp(lasterr); keyboard;
end
