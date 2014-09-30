function pascal_getNondupComps(cachedir, phrasenames, datatype, data_year, numComp, modelname, wwwdispdir, wwwdispdir_part) %,...
    %rankThresh, rankThresh_dis1, ovThresh_dis1, rankThresh_dis2, ovThresh_dis2)
% similar in spirit to getDiverseNgrams_fastImgCl (but at comp level)

try    

diary([cachedir '/diaryoutput_getNondupComps.txt']);    
disp(['pascal_getNondupComps(''' cachedir ''','' phrasenames '',''' datatype ''',''' data_year ''',''' num2str(numComp) ''',''' modelname ''',''' wwwdispdir ''',''' wwwdispdir_part ''');' ]);

%rankThresh = 25;
%rankThresh_dis1 = 100; ovThresh_dis1 = 0.25;    % weak score, better be good overlap (random stuff?)
%rankThresh_dis2 = 50; ovThresh_dis2 = 0.05;     % strong score, ok to have low overlap (e.g., head on body)

conf = voc_config('pascal.year', data_year, 'eval.test_set', datatype);
rankThresh = conf.threshs.rankThresh_simComp;
rankThresh_dis1 = conf.threshs.rankThresh_disimComp1;
ovThresh_dis1 = conf.threshs.ovThresh_disimCmp1;
rankThresh_dis2 = conf.threshs.rankThresh_disimComp2;
ovThresh_dis2 = conf.threshs.ovThresh_disimComp2;

if isempty(modelname)
    this_suffix = ['_goodInfo'];
    this_suffix2 = ['_goodInfo2'];
    edgefname = ['matrix_' datatype '_' data_year];
    outfname = [cachedir '/dupCompInfo_' datatype '_' data_year '.txt'];
    outfname2 = [cachedir '/disCompInfo_' datatype '_' data_year '.txt'];
    dmatfname = [cachedir '/edgeMatInfo_' datatype '_' data_year '.txt'];
else
    this_suffix = ['_' modelname '_goodInfo'];
    this_suffix2 = ['_' modelname '_goodInfo2'];
    edgefname = ['matrix_' datatype '_' data_year '_' modelname];
    outfname = [cachedir '/dupCompInfo_' datatype '_' data_year '_' modelname '.txt'];
    outfname2 = [cachedir '/disCompInfo_' datatype '_' data_year '_' modelname '.txt'];
    dmatfname = [cachedir '/edgeMatInfo_' datatype '_' data_year '_' modelname '.txt'];
end
numcls = numel(phrasenames);

load([cachedir '/' edgefname '.mat'], 'edgeval', 'ovlap');

disp(' get good comp info');
phrasevalidcomps = zeros(numcls*numComp, 1);
phrasecompaps_full = zeros(numcls*numComp, 1);
phrasecompaps = zeros(numcls*numComp, 1);
for f=1:numcls
    myprintf(f, 10);    
    clear goodcomps roc
    load([cachedir '/../' phrasenames{f} '/' phrasenames{f} this_suffix], 'goodcomps', 'roc');    
    for ci=1:numComp
        phrasevalidcomps((f-1)*numComp+ci) = goodcomps(ci);
        phrasecompaps_full((f-1)*numComp+ci) = roc{ci}.ap_full_new*100; %compaps_full(ci);
        phrasecompaps((f-1)*numComp+ci) = roc{ci}.ap_new*100; %compaps(ci);
    end
end
myprintfn;
disp(['starting with ' num2str(length(find(phrasevalidcomps)))  ' good comps, where total=' num2str(size(edgeval,1))]);

disp(' update the matrix such that edgeval(i,j) has score at least as much as  edgeval(j,j) ');
dmat = edgeval;
for j=1:size(edgeval,1)
    inds = find(dmat(:,j) < dmat(j,j));
    %if ~isempty(inds), disp('here'); keyboard; end
    dmat(inds, j) = dmat(j,j);
    
    inds = find(dmat(j,:) < dmat(j,j));
    %if ~isempty(inds), disp('here'); keyboard; end
    dmat(j, inds) = dmat(j,j);
end

if ~exist(dmatfname, 'file')
    disp('dumping the edgeval + ovlap info to file');
    fid = fopen(dmatfname, 'w');
    for i=1:size(edgeval,1)
        myprintf(i, 10);
        %fprintf(fid, '%d :', i);
        ngramid1 = ceil(i/numComp);
        compid1 = rem(i, numComp);
        if compid1 == 0, compid1 = numComp; end
        for j=1:size(edgeval,1)
            ngramid2 = ceil(j/numComp);
            compid2 = rem(j, numComp);
            if compid2 == 0, compid2 = numComp; end
            fprintf(fid, '%s,%d\t%s,%d\t%2.1f,%1.3f\n', phrasenames{ngramid1}, compid1, phrasenames{ngramid2}, compid2, dmat(i,j), ovlap(i,j));
        end
    end
    myprintfn;
    fclose(fid);
end

disp(' finding similar nodes');
offsetThresh = rankThresh/2;
simNodes = cell(size(edgeval,1), 1);
remNodes = 1:size(edgeval,1);
% find nodes that are valid and just consider them
remNodes = remNodes(logical(phrasevalidcomps));
while ~isempty(remNodes)
    pickNode = remNodes(1);
    fprintf('%d ', pickNode);
    % find bidirectional edges of (high similarity and reasonable (50%) overlap)
    likeNodes = find(...
        [dmat(remNodes, pickNode) < max(rankThresh, dmat(pickNode, pickNode) + offsetThresh)] & ...
        [dmat(pickNode, remNodes)' < max(rankThresh, diag(dmat(remNodes, remNodes)) + offsetThresh)] & ...
        [ovlap(remNodes, pickNode) >= 0.5] & [ovlap(pickNode, remNodes)' >= 0.5]);
    if isempty(find(likeNodes==1, 1))
        if ~isempty(likeNodes), disp('here'); keyboard; end
        likeNodes = [1 likeNodes]; 
    end    
    simNodes{pickNode} = remNodes(likeNodes);
    remNodes(likeNodes) = [];    
end
myprintfn;

%disp(' sort simNodes within based on ap scores');
disp(' sort simNodes within based on dmat values');
for i=1:numel(simNodes)
    if length(simNodes{i}) >= 1
        %if length(simNodes{i}) < 3
        %    [~, sind] = sort(phrasecompaps(simNodes{i}), 'descend');
        %    simNodes{i} = simNodes{i}(sind);
        %else
            sumval = zeros(length(simNodes{i}),1);
            for jj=1:length(simNodes{i})
                sumval(jj) = sum(dmat(simNodes{i}(jj), simNodes{i}(:)));
            end
            [~, sind] = sort(sumval, 'ascend');
            simNodes{i} = simNodes{i}(sind);
        %end
    end
end

disp(' sort simNodes across based on ap scores');
snodeacc = zeros(numel(simNodes),1);
for i=1:numel(simNodes)
    if length(simNodes{i}) >= 1
        snodeacc(i) = phrasecompaps(simNodes{i}(1));
    end
end
[~, snodeacc_sind] = sort(snodeacc, 'descend');
%simNodes = simNodes(snodeacc_sind); 

disp(' print info for reference/debugging');
fid = fopen(outfname, 'w');
k = 1;
for i=snodeacc_sind(:)'
    if length(simNodes{i}) >= 1
        fprintf(fid, '%d :', k);
        for j=1:length(simNodes{i})
            ngramid = ceil(simNodes{i}(j)/numComp);
            compid = rem(simNodes{i}(j), numComp);
            if compid == 0, compid = numComp; end
            fprintf(fid, '%s,%d,%2.1f,%2.1f\t', phrasenames{ngramid}, compid, phrasecompaps_full(simNodes{i}(j)), phrasecompaps(simNodes{i}(j)));
        end
        fprintf(fid, '\n\n');
        k = k+ 1;
    end
end
fclose(fid);
totalSelected = k-1;
disp(['selected ' num2str(totalSelected) ' out of ' num2str(length(find(phrasevalidcomps)))]);

disp('find extremely dissimilar nodes and reject them');
inNodes = cell(size(edgeval,1), 1);
outNodes = cell(size(edgeval,1), 1);
listNodes = find(snodeacc);     % dont need sorted order

selNodes = zeros(length(listNodes),1);
for i=1:length(listNodes),
    selNodes(i) = simNodes{listNodes(i)}(1);
end

for i=1:length(listNodes)
    %pickNode = listNodes(i);   % cant directly pick as they have been internally sorted
    pickNode = selNodes(i); %simNodes{listNodes(i)}(1);
    fprintf('%d ', pickNode);
    % find unidirectional incoming/outgoing edges of (high similarity and reasonable (50%) overlap)
    %inEdges = find([dmat(listNodes, pickNode) < max(rankThresh_dis1, dmat(pickNode, pickNode) + offsetThresh2)]); 
    %outEdges = find([dmat(pickNode, listNodes)' < max(rankThresh_dis1, diag(dmat(listNodes, listNodes)) + offsetThresh2)]); 
    %inEdges = find([dmat(listNodes, pickNode) < rankThresh_dis1]); 
    %outEdges = find([dmat(pickNode, listNodes)' < rankThresh_dis1]); 
    
    inEdges = find([dmat(selNodes, pickNode) < rankThresh_dis1] & [ovlap(selNodes, pickNode) >= ovThresh_dis1] | ...
        [dmat(selNodes, pickNode) < rankThresh_dis2] & [ovlap(selNodes, pickNode) >= ovThresh_dis2]); 
    outEdges = find([dmat(pickNode, selNodes)' < rankThresh_dis1] & [ovlap(pickNode, selNodes)' >= ovThresh_dis1] | ...
        [dmat(pickNode, selNodes)' < rankThresh_dis2] & [ovlap(pickNode, selNodes)' >= ovThresh_dis2]); 
    if isempty(find(inEdges==i, 1)) || isempty(find(outEdges==i, 1))
        if ~isempty(inEdges), disp('here'); keyboard; end
        if ~isempty(outEdges), disp('here'); keyboard; end        
    end
    inEdges = setdiff(inEdges, i);
    outEdges = setdiff(outEdges, i);
    inNodes{listNodes(i)} = selNodes(inEdges);
    outNodes{listNodes(i)} = selNodes(outEdges);
end
myprintfn;

disp(' sort inNodes & outNodes within based on ap scores');
for i=1:numel(simNodes)
    if length(simNodes{i}) >= 1
        [~, sind] = sort(dmat(inNodes{i}, i), 'ascend');
        inNodes{i} = inNodes{i}(sind);
        
        [~, sind] = sort(dmat(i, outNodes{i}), 'ascend');
        outNodes{i} = outNodes{i}(sind);
    end
end

disp(' 2. print info for reference/debugging');
fid = fopen(outfname2, 'w');
k = 1;
phrasename_sel = [];
ngramid_sel = [];
compid_sel = [];
for i=snodeacc_sind(:)'
    if length(simNodes{i}) >= 1 && (length(inNodes{i}) >=1 || length(outNodes{i}) >= 1)
        fprintf(fid, '%d :', k);
        ngramid = ceil(simNodes{i}(1)/numComp);
        compid = rem(simNodes{i}(1), numComp);
        if compid == 0, compid = numComp; end
        fprintf(fid, '%s,%d\t', phrasenames{ngramid}, compid);
        phrasename_sel{k} = phrasenames{ngramid};
        ngramid_sel(k) = ngramid;
        compid_sel(k) = compid;
        
        % print incoming edges
        fprintf(fid, '\n\t\t<-\t');
        for j=1:length(inNodes{i})            
            ngramid = ceil(inNodes{i}(j)/numComp);
            compid = rem(inNodes{i}(j), numComp);
            if compid == 0, compid = numComp; end
            fprintf(fid, '%s,%d,%2.1f,%2.1f\t', phrasenames{ngramid}, compid, phrasecompaps_full(inNodes{i}(j)), phrasecompaps(inNodes{i}(j)));
        end
        
        % print outcoming edges
        fprintf(fid, '\n\t\t->\t');
        for j=1:length(outNodes{i})
            ngramid = ceil(outNodes{i}(j)/numComp);
            compid = rem(outNodes{i}(j), numComp);
            if compid == 0, compid = numComp; end
            fprintf(fid, '%s,%d,%2.1f,%2.1f\t', phrasenames{ngramid}, compid, phrasecompaps_full(outNodes{i}(j)), phrasecompaps(outNodes{i}(j)));
        end
        
        fprintf(fid, '\n\n');
        k = k+ 1;
    end
end
totalSelected2 = k-1;
disp(['selected ' num2str(totalSelected2) ' out of ' num2str(totalSelected)]);

% just print all deleted nodes at the end of file
kk=1;
for i=1:numel(simNodes)
    if length(simNodes{i}) >= 1 && (length(inNodes{i}) < 1 && length(outNodes{i}) < 1)
        ngramid = ceil(simNodes{i}(1)/numComp);
        compid = rem(simNodes{i}(1), numComp);
        if compid == 0, compid = numComp; end
        fprintf(fid, '%d :%s,%d,%2.1f,%2.1f\n', kk, phrasenames{ngramid}, compid, phrasecompaps_full(simNodes{i}(1)), phrasecompaps(simNodes{i}(1)));
        kk= kk+1;
    end
end
fclose(fid);

disp('creating web visualization');   
createWebPageWithTrainingDisplay_selected(phrasename_sel, ngramid_sel, compid_sel, cachedir, wwwdispdir, wwwdispdir_part, phrasenames);

disp(' save info for further processing');
selcomps_all = zeros(numcls, numComp);
% 0=> bad pr, -1 => merged with sth else (check selcompsInfo_all), -2 => ignored bcoz island, 1 => selected (check selcompsInfo_all for siblings)
selcompsInfo_all = cell(numcls, numComp);
for i=snodeacc_sind(:)'
    if length(simNodes{i}) >= 1 && (length(inNodes{i}) >=1 || length(outNodes{i}) >= 1)    
        parngramid = [];
        parcompid = [];
        for j=1:length(simNodes{i})
            ngramid = ceil(simNodes{i}(j)/numComp);
            compid = rem(simNodes{i}(j), numComp);
            if compid == 0, compid = numComp; end
            if j==1
                selcomps_all(ngramid,compid) = 1;
                parngramid = ngramid;
                parcompid = compid;
            else
                selcomps_all(ngramid,compid) = -1;
            end
            selcompsInfo_all{parngramid,parcompid} = [selcompsInfo_all{parngramid,parcompid}; ngramid compid];
            selcompsInfo_all{ngramid, compid} = [parngramid parcompid];
        end
    end
    if length(simNodes{i}) >= 1 && (length(inNodes{i}) < 1 && length(outNodes{i}) < 1)
        ngramid = ceil(simNodes{i}(1)/numComp);
        compid = rem(simNodes{i}(1), numComp);
        if compid == 0, compid = numComp; end
        selcomps_all(ngramid,compid) = -2;  % -2 indicates it has been ignored becauuse its island (0 => just bad pr)
    end
end

for f=1:numel(phrasenames)
    myprintf(f,10);
    selcomps = selcomps_all(f,:);
    selcompsInfo = selcompsInfo_all(f,:);
    save([cachedir '/../' phrasenames{f} '/' phrasenames{f} this_suffix2], 'selcomps', 'selcompsInfo');
end
myprintfn;
disp(length(find(selcomps_all==1)));

catch
    s = lasterror;
    disp(lasterr); keyboard;
end
