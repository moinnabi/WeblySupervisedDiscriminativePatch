function pascal_getGoodComps(cachedir, phrasenames, testset, year, numComp, modelname,...
    minAPthresh_full, minAPthresh, minNumValInst, minNumTrngInst, recthresh)
% identifies good components within each model based on performance on a heldout set

try    
    
global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
conf = voc_config('pascal.year', year, 'eval.test_set', testset);

%minAPthresh_full = 15;  % 8Apr13: played around a bit (10 or 15 or 20); 10 keeps some crap, 20 kind of looses good stuff, so 15 is best
%minAPthresh = 20;       % changed to 20 (from 10) on 5/12/13 after seeing top 75 good ones; before 10 was selected by looking at pr curves
%minNumValInst = 4;      % looked at pr curves and then arrived at this
%minNumTrngInst = 8; %4; % changed to 8 on 5/12 after seeing top 75 good ones, 6 on 5/5/13 after analyzing remaining 200 componets (just before adding parts)
%recthresh = 0.3;
numcls = numel(phrasenames);

diary([cachedir '/diaryoutput_getGoodComps.txt']);
disp(['pascal_getGoodComps(''' cachedir ''','' phrasenames '',''' testset ''',''' year ''',''' num2str(numComp) ''',''' modelname  ''',''' num2str(minAPthresh_full) ''','''  num2str(minAPthresh) ''','''  num2str(minNumValInst) ''','''  num2str(minNumTrngInst) ''','''  num2str(recthresh) ''');' ]);

% B was after changed numTrng from 4 to 8 and minApThresh from 10 to 20
if isempty(modelname)
    rocfname = [cachedir '/rocInfo_' testset '_' year '.mat'];
    this_suffix = ['_goodCompInfoB'];
else
    rocfname = [cachedir '/rocInfo_' testset '_' year '_' modelname '.mat'];
    this_suffix = ['_' modelname '_goodCompInfoB'];
end

disp(' get all detection boxes');
ds_top = get_dstop(cachedir, testset, year, phrasenames, conf, modelname);    

if ~isempty(find(cellfun(@isempty, ds_top)==1, 1))
    disp('some dets missing'); keyboard;
end 

disp(' get all roc curves');
try
    load(rocfname, 'roc', 'numTrngInst');
catch
    roc = getROCInfoPerComp2(ds_top, cachedir, phrasenames, numComp, recthresh);    
    numTrngInst = zeros(numcls, numComp);
    for f=1:numcls
        myprintf(f,10);
        load([cachedir '/../' phrasenames{f} '/' phrasenames{f} '_mix.mat'], 'model');
        numTrngInst(f,:) = model.stats.filter_usage;
    end
    myprintfn;
    save(rocfname, 'roc', 'numTrngInst');
end

disp(' now identifying good components');
totalgudcomps = 0;
for f=1:numcls
    myprintf(f, 10);
    if ~isempty(roc{f,1})
        [compaps, compaps_full, numInst, goodcomps] = deal(zeros(numComp, 1));
        for ck=1:numComp
            compaps_full(ck) = roc{f,ck}.ap_full_new*100;
            compaps(ck) = roc{f,ck}.ap_new*100;
            numInst(ck) = roc{f,ck}.npos;
            if compaps_full(ck) > minAPthresh_full && numInst(ck) >= minNumValInst &&...
                     numTrngInst(f,ck) >= minNumTrngInst && ceil(compaps(ck)) >= minAPthresh 
                goodcomps(ck) = 1;
                totalgudcomps = totalgudcomps + 1;
            end
        end
        save([cachedir '/../' phrasenames{f} '/' phrasenames{f} this_suffix], 'compaps', 'compaps_full', 'numInst', 'goodcomps', 'minAPthresh');
    end
end
myprintfn;

%length(find(cellfun(@isempty, ds_top)==0))*numComp
disp(['Total of ' num2str(totalgudcomps) '/' num2str(numcls*numComp) ' good comps']);

diary off;

catch
    disp(lasterr); keyboard;
end
