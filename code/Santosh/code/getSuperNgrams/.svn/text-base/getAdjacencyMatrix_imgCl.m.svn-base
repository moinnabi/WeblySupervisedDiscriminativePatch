function getAdjacencyMatrix_imgCl(cachedir, inpfname) %, cutoffThresh, fsize, sbin, domode)

try    
    
disp(['getAdjacencyMatrix_imgCl(''' cachedir ''',''' inpfname ''')']);

conf = voc_config('paths.model_dir', 'blah');
fsize = conf.threshs.fsize_fastImgClfr;
sbin = conf.threshs.sbin_fastImgClfr;
domode =  conf.threshs.featExtMode_imgClfr;

biasval = 1;
fsize = [fsize fsize];
%fsize = [10 10];
%sbin = 8;

fname = ['edgematrix'];
try
    load([cachedir '/' fname '.mat'], 'edgeval');
    disp('  loaded pre computed adjacency matrix');
catch
    disp('  computing adjacency matrix');
    mymatlabpoolopen;

    % get list of valid ngrams for this object
    disp('load data');
    if domode == 1, phrasenames = selectTopPhrasenames(inpfname);
    elseif domode == 2, phrasenames = selectTopPhrasenames_slow(inpfname, cutoffThresh); end    
    numcls = numel(phrasenames);
    if numcls == 0, disp('some error possibly with csscanf'); keyboard; end
    
    disp('compute all positive features');
    try
        load([cachedir '/posData_alltest.mat'], 'posData', 'phrasenames');
    catch
        %tic;
        % for loop takes about 1 sec per class
        disp(numcls); 
        
        posData = cell(numcls, 1);
        for f=1:numcls  % didnt parfor this as getHOGFeatures is parfor'd
            myprintf(f,10);
            ids = mydir([cachedir '/images/' phrasenames{f} '/*.jpg'], 1);
            tmpld = load([cachedir '/results/' phrasenames{f} '_result'], 'keepinds', 'dupfnd', 'testInds');
            keepinds = tmpld.keepinds; dupfnd = tmpld.dupfnd; testInds = tmpld.testInds;
            ids = ids(logical(keepinds));
            ids = ids(~logical(dupfnd));
            
            try
                ids_test = ids(testInds);
            catch
                disp('see error in getting inds'); keyboard; % see commented code below if that helps
                %{
                % this happends becoz i moved keepinds part of code outside the if loop afterwards
                vect1 = zeros(numel(keepinds),1);
                vect1(testInds) = 1;
                vect1 = logical(vect1) & keepinds;
                testInds = find(vect1(logical(keepinds)));
                ids_test = ids(testInds);
                %}
            end
            
            pos=[];
            for i=1:length(ids_test)
                pos(i).im = ids_test{i};
                pos(i).flip = 0;
            end            
            %{
            feats = cell(length(pos),1);
            warped = warppos_img(pos, fsize, sbin);
            for i = 1:length(pos)
                hogfeat = features(double(warped{i}), sbin);
                feats{i} = [hogfeat(:); biasval];
            end
            %}
            feats = getHOGFeaturesFromWarpImg(pos, fsize, sbin, biasval, domode);
            posData{f} = cat(2, feats{:})';
        end
        myprintfn;
        posData(cellfun('isempty', posData)) = [];
        % save only for fast classifier, too heavy for slow classifier
        if domode == 1, save([cachedir '/posData_alltest.mat'], 'posData', 'phrasenames', '-v7.3'); end
    end
    tmp = load([cachedir '/negData_test.mat'], 'negData');
    negData_test = tmp.negData;
    
    %tic; %(366*366 takes about 6700 secs -- stats b4 doing parfor)
    % for each pair, get rank and build matrix
    disp(' compute matrix');
    maxmatval = 10^4;
    edgeval = maxmatval*ones(numcls, numcls);
    for c=1:numcls          % for each ngram
        myprintf(c, 10);
        tmp = load([cachedir '/results/' phrasenames{c} '_result'], 'model');
        model = tmp.model;        
        score_negtest = negData_test  * model.W - model.rho;    % apply classifier c on neg bgrnd
        negGt = -1*ones(size(negData_test,1),1);
        parfor j=1:numcls      % get the rank of all other ngram
            % apply classifier c on pos testing data of j; merge with neg bgrnd
            score_test = [posData{j}  * model.W - model.rho; score_negtest];
            testGt = [ones(size(posData{j},1),1); negGt];            
            [~, sind] = sort(score_test, 'descend');
            posId = testGt(sind);
            
            % get edge weight
            thisinds = find(posId == 1);
            if numel(thisinds)>1, edgeval(c, j) = median(thisinds)/(numel(thisinds)/2); end
        end 
    end
    myprintfn;  
    save([cachedir '/' fname '.mat'], 'edgeval');
    %toc;
    
    try matlabpool('close', 'force'); end
end

catch
    disp(lasterr); keyboard;
end
