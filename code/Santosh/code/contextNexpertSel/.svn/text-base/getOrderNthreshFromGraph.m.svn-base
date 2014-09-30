function getOrderNthreshFromGraph(cachedir, phrasenames, data_year, datatype, datatype_val, doComp, numComp)

try    

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = data_year;
conf = voc_config('pascal.year', data_year);
cachedir = conf.paths.model_dir;

disp(['getOrderNthreshFromGraph(''' cachedir ''','' phrasenames '',''' data_year ''',''' datatype ''',''' num2str(doComp) ''',''' num2str(numComp) ''')' ]);
mymkdir([cachedir '/display/pr/']);

fname = ['tree_' datatype '_' data_year];

disp(' compute order given graph');
%try
%    load([cachedir '/order_' fname '.mat'], 'phraseorder', 'phrasethreshs');
%    disp(' loading precomputed order and thresh');
%catch
    disp(' loading graph info');
    load([cachedir '/' fname '.mat'], 'gviz', 'allRoots', 'edgeval', 'ovlap');    
    numcls = size(edgeval, 1);
    
    disp('  getting phraseorder');    
    allRoots = sortNdiscardRoots(allRoots, edgeval, ovlap);
    phraseorder = addTheseRoots(allRoots, gviz, edgeval, ovlap);
    %{
    ds_top1 = get_dstop(cachedir, datatype, data_year, phrasenames, conf);
    [phraseorder, phrasethreshs] = addTheseRootsWithThresh(allRoots, gviz, edgeval, ovlap, ds_top1);
    phrasethreshs(phraseorder,:) = phrasethreshs;
    %}
    %%%for i=1:numel(allRoots), phraseorder = [phraseorder; addThisRoot(allRoots(i), givz)]; end    
    
    disp('  getting phrasethresh');    
    ds_top2 = get_dstop(cachedir, datatype_val, data_year, phrasenames, conf);    
    disp('   generate img cls pr curve');
    if ~doComp, roc = getROCInfo(ds_top2, cachedir, phrasenames);
    else roc = getROCInfoPerComp(ds_top2, cachedir, phrasenames, numComp); end
    
    precvals = [0.75 0.5 0.25 0.2 0.15 0.1 0.05 0];
    recvals = [0.5 0.5 0.75 0.75 0.75 1 1 1];
    phrasethreshs = 10*ones(numcls, numel(precvals));
    for c=1:numcls
        for i=1:numel(precvals)
            scoreind = find(roc{c}.p >= precvals(i) & roc{c}.r <= recvals(i), 1, 'last');
            if ~isempty(scoreind)
                phrasethreshs(c,i) = roc{c}.scores(scoreind);
            end
        end
    end
    
    otherRootStart = 2;
    if doComp, otherRootStart = 7; end
    for c=1:numcls        
        if ~isempty(find(gviz(:,c) == 30, 1))       % find all partOf inds and shift/set their first two threshs to be high
            phrasethreshs(c,3:end) = phrasethreshs(c,1:end-2);
            phrasethreshs(c,1:2) = 10;            
        elseif ~isempty(find(gviz(:,c) == 20, 1))   % find all hasPart inds and set their first thresh to be high
            phrasethreshs(c,2:end) = phrasethreshs(c,1:end-1);
            phrasethreshs(c,1:1) = 10;            
        elseif ~isempty(find(allRoots(otherRootStart:end) == c, 1)) % find all root inds and set their first thresh to be high
            phrasethreshs(c,2:end) = phrasethreshs(c,1:end-1);
            phrasethreshs(c,1:1) = 10;
        end
    end
    
    if 0
    % set horse_front after reining_horse explicitly
    ind97 = find(phraseorder == 97);
    phraseorder(ind97) = [];
    ind96 = find(phraseorder == 33);
    phraseorder(end+1) = 0;
    phraseorder(ind96+2:end) = phraseorder(ind96+1:end-1);
    phraseorder(ind96+1) = 97;
    phrasethreshs(97,1:end-1) = phrasethreshs(97,2:end);
    phrasethreshs(97,:) = phrasethreshs(97,:) - 0.03;
    end
            
    save([cachedir '/order_' fname '.mat'], 'phraseorder', 'phrasethreshs');
    
    disp('here'); keyboard;
%end

catch
    disp(lasterr); keyboard;
end

%%%%%%%%%%%%%%%%%%%%%
function allRoots = sortNdiscardRoots(allRoots, edgeval, ovlap)
% for each island


%%%%%%%%%%%%%%%%%%%
function phraseorder = addTheseRoots(allRoots, gviz, edgeval, ovlap)

% initialize
phraseorder = [];

% add specifics across all roots
for i=1:numel(allRoots)
    isaInds = find(gviz(allRoots(i), :) == 10);
    isaInds = isaInds(isaInds ~= allRoots(i));
    %isaInds = sortBasedOnImportance(isaInds, edgeval, ovlap);   % reorder
    phraseorder = [phraseorder; isaInds(:)];        
end

% add all roots
for i=1:numel(allRoots)
    phraseorder = [phraseorder; allRoots(i)];        
end

% add hasParts across all roots
for i=1:numel(allRoots)
    hasPartsInds = find(gviz(allRoots(i), :) == 20);
    %hasPartsInds = sortBasedOnImportance(hasPartsInds, edgeval, ovlap);   % reorder
    thisphraseorder = addTheseRoots(hasPartsInds, gviz, edgeval, ovlap);
    phraseorder = [phraseorder; thisphraseorder(:)];
end

% add partOf across all roots
for i=1:numel(allRoots)
    partOfInds = find(gviz(allRoots(i), :) == 30);
    %partOfInds = sortBasedOnImportance(partOfInds, edgeval, ovlap);   % reorder
    phraseorder = [phraseorder; partOfInds(:)];    
end


%%%%%%%%%%%%%%%%%%%
function [phraseorder, phrasethresh] = addTheseRootsWithThresh(allRoots, gviz, edgeval, ovlap, ds_top)

% initialize
phraseorder = [];
phrasethresh = [];

% add specifics across all roots
for i=1:numel(allRoots)
    isaInds = find(gviz(allRoots(i), :) == 10);
    isaInds = isaInds(isaInds ~= allRoots(i));
    %isaInds = sortBasedOnImportance(isaInds, edgeval, ovlap);   % reorder
    phraseorder = [phraseorder; isaInds(:)];    
    for j=1:numel(isaInds)
        %phrasethresh = [phrasethresh; getThreshold(isaInds(j), [allRoots(i); setdiff(isaInds, isaInds(j))], ds_top)];
        phrasethresh = [phrasethresh; getThreshold(isaInds(j), allRoots(i), ds_top)];
    end
end

% add all roots
for i=1:numel(allRoots)
    phraseorder = [phraseorder; allRoots(i)];
    
    hasPartsInds = find(gviz(allRoots(i), :) == 20);    
    phrasethresh = [phrasethresh; getThreshold(allRoots(i), [], ds_top)];    
end

% add hasParts across all roots
for i=1:numel(allRoots)
    hasPartsInds = find(gviz(allRoots(i), :) == 20);
    %hasPartsInds = sortBasedOnImportance(hasPartsInds, edgeval, ovlap);   % reorder
    [thisphraseorder, thisphrasethresh] = addTheseRootsWithThresh(hasPartsInds, gviz, edgeval, ovlap, ds_top);
    phraseorder = [phraseorder; thisphraseorder(:)];    
    phrasethresh = [phrasethresh; thisphrasethresh];
end

% add partOf across all roots
for i=1:numel(allRoots)
    partOfInds = find(gviz(allRoots(i), :) == 30);
    %partOfInds = sortBasedOnImportance(partOfInds, edgeval, ovlap);   % reorder
    phraseorder = [phraseorder; partOfInds(:)];
    for j=1:numel(partOfInds)
        phrasethresh = [phrasethresh; getThreshold(partOfInds(j), [], ds_top)];
    end
end

%%%%%%%%%%%%%%%%%%
function thresh = getThreshold(thisnode, othernodes, ds_top)

numbgdet = 1;

if 1
    % othernode could be a single node, bunch of nodes or empty
    if ~isempty(othernodes)
        thisthreshs = 10*ones(numel(othernodes),1);
        for i=1:numel(othernodes)
            % run "arabian horse" detector on "horse" images
            detinds = find(ds_top{thisnode}(:, end-1) == othernodes(i));
            
            bgdetinds = find(ds_top{thisnode}(:, end-1) == 0);
            % need to check for overlap?
            
            % pick highest score as its threhold
            objthresh = max(ds_top{thisnode}(detinds, end));
            % but that threshold should be at least as high as the nth false positive on background
            bgthresh = ds_top{thisnode}(bgdetinds(numbgdet), end);
            thisthreshs(i) = max(objthresh, bgthresh);
        end
        % ran horse on horse parts; now pick max of all threhsold
        thresh = max(thisthreshs);
    else
        % look at dets and pick nth false positive threshold
        detinds = find(ds_top{thisnode}(:, end-1) == 0);
        thresh = ds_top{thisnode}(detinds(numbgdet), end);
    end
else
    thresh = zeros(1,10);
    for i=1:10
        thresh(i) = ds_top{thisnode}(i*10,end);
    end        
end
