function getGraphFromAdjacencyMatrix(cachedir, phrasenames, phrasenames_disp, basefname, data_year, datatype, doComp, numComp)

try    

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = data_year;
conf = voc_config('pascal.year', data_year);
cachedir = conf.paths.model_dir;

disp(['getGraphFromAdjacencyMatrix(''' cachedir ''','' phrasenames '','' phrasenames_disp '',''' basefname ''',''' data_year ''',''' datatype ''',''' num2str(doComp) ''',''' num2str(numComp) ''')' ]);

% define isa and part of relations for "horse" (and then later recurse that)
OVL_T = 0.5;
EDGE_T = 10.0;
EDGE_RT = 1.5;

% terminology for graphviz
% init: 0
% isaInds: 10
% hasPartInds: 20
% partOfInds: 30

if doComp, [~, phrasenames_disp] = getPhrasenamesPerComp(phrasenames, phrasenames_disp, numComp); end
if doComp, disp('format of edgeval changed from numcls*numcomp to a tensor, update code here'); keyboard; end

fname = ['tree_' datatype '_' data_year];
try
    load([cachedir '/' fname '.mat'], 'gviz');
    disp(' loaded precomputed graph');
catch    
    disp(' loading precomputed adjacency matrix');
    load([cachedir '/' 'matrix_' datatype '_' data_year '.mat'], 'edgeval', 'ovlap');
    
    numcls = size(edgeval, 1);
    gviz = zeros(numcls, numcls);
    allRoots =[];
    
    objname = textread(basefname, '%s');        % keyword typed by user
    
    disp(' get two-layered DAG');
    %if ~doComp
        initRootInd = find(strcmp(phrasenames, objname));
        if doComp, initRootInd = (initRootInd-1)*numComp+1; end
        isaInds = getIsA(ovlap, edgeval, initRootInd, OVL_T, EDGE_T);
        hasPartInds = getHasPart(ovlap, edgeval, initRootInd, OVL_T, EDGE_T, EDGE_RT);
        partOfInds = getPartOf(ovlap, edgeval, initRootInd, OVL_T, EDGE_T, EDGE_RT);
        noRelInds = getNoRel(numcls, isaInds, partOfInds, hasPartInds);
        
        % update graph
        gviz(initRootInd, isaInds) = 10;
        gviz(initRootInd, hasPartInds) = 20;
        gviz(initRootInd, partOfInds) = 30;
        allRoots = [allRoots; initRootInd];
    %{    
    else            
        for i=1:numComp
            initRootInd = find(strcmp(phrasenames, objname));    % keyword typed by user
            initRootInd = (initRootInd-1)*numComp+i;
        
            indsToConsider = setdiff(1:numcls, (initRootInd-1)*numComp+[1:6]);
            indsToConsider = [initRootInd indsToConsider];
            thisovlap = ovlap(indsToConsider, indsToConsider);
            thisedgeval = edgeval(indsToConsider, indsToConsider);
            
            isaInds = getIsA(thisovlap, thisedgeval, 1, OVL_T, EDGE_T);
            hasPartInds = getHasPart(thisovlap, thisedgeval, 1, OVL_T, EDGE_T, EDGE_RT);
            partOfInds = getPartOf(thisovlap, thisedgeval, 1, OVL_T, EDGE_T, EDGE_RT);
            noRelInds = getNoRel(numcls, isaInds, partOfInds, hasPartInds);
            disp('need to append noRelInds to elarlier ones'); keyboard;
            
            % update graph
            gviz(initRootInd, indsToConsider(isaInds)) = 10;
            gviz(initRootInd, indsToConsider(hasPartInds)) = 20;
            gviz(initRootInd, indsToConsider(partOfInds)) = 30;
            allRoots = [allRoots; initRootInd];
        end
    end
    %}
        
    disp('building Forest: repeat above process (recurse isa, hasPart and partOf steps) for each unrelated node');    
    %noRelInds = sortNoRel(noRelInds); % make sure you pick frontal horse and not frontal horse drawn carraige or frontal horse head
    % for now not doing any sort
    
    while ~isempty(noRelInds)
        thisovlap = ovlap(noRelInds, noRelInds);
        thisedgeval = edgeval(noRelInds, noRelInds);
        %rootInd = noRelInds(1);    % no need to do unvisited(1) as you use thisovlap and thisedgeval
        rootInd = 1;
        isaInds_this = getIsA(thisovlap, thisedgeval, rootInd, OVL_T, EDGE_T);
        hasPartInds_this = getHasPart(thisovlap, thisedgeval, rootInd, OVL_T, EDGE_T, EDGE_RT);
        partOfInds_this = getPartOf(thisovlap, thisedgeval, rootInd, OVL_T, EDGE_T, EDGE_RT);
        noRelInds_this = getNoRel(size(thisovlap,1), isaInds_this, partOfInds_this, hasPartInds_this);
        
        % updte graph
        gviz(noRelInds(rootInd), noRelInds(isaInds_this)) = 10;
        gviz(noRelInds(rootInd), noRelInds(hasPartInds_this)) = 20;
        gviz(noRelInds(rootInd), noRelInds(partOfInds_this)) = 30;
        allRoots = [allRoots; noRelInds(rootInd)];
        
        %noRelInds = sortNoRel(noRelInds(noRelInds_this));
        noRelInds = noRelInds(noRelInds_this);
    end
        
    disp(' display graph uptil now');
    %A = normalise(gviz,2);     % dont normalize graph as each value has a specific meaning and it is lost upon normalization
    A = gviz/max(gviz(:));      % need to have values between 0 & 1, otherwise graph appears very tiny
    params = sexy_graph_params(A);
    params.sfdp_coloring = 0;
    params.NC = 3;
    params.tmpdir = cachedir;
    params.file_prefix = ['noChild_' fname];
    params.node_names = phrasenames_disp;
    sexy_graph_asym_img(A,'',params);
        
    disp('expanding each Tree: repeat above process (recurse isa, hasPart and partOf steps) for each part node in each tree');
    for i=1:numel(allRoots)
        rootNow = allRoots(i);                      % pick the current root
        noRelInds = find(gviz(rootNow, :) == 20);   % get its part indicies
        noRelInds = sortPartIndicies(noRelInds, rootNow, edgeval, ovlap);    % sort them (so that you pick head before nose)
        while ~isempty(noRelInds)
            thisovlap = ovlap(noRelInds, noRelInds);
            thisedgeval = edgeval(noRelInds, noRelInds);
            %rootInd = noRelInds(1);    % no need to do unvisited(1) as you use thisovlap and thisedgeval
            rootInd = 1;
            isaInds_this = 1;       % no "ISA" relationship for parts ?
            partOfInds_this = [];
            hasPartInds_this = getHasPart(thisovlap, thisedgeval, rootInd, OVL_T, EDGE_T, EDGE_RT);
            noRelInds_this = getNoRel(size(thisovlap,1), isaInds_this, partOfInds_this, hasPartInds_this);
            
            %%% updte graph            
            gviz(rootNow, noRelInds(hasPartInds_this)) = 0;             % delete existing edge            
            gviz(noRelInds(rootInd), noRelInds(hasPartInds_this)) = 20; % add new edge
            
            %noRelInds = sortNoRel(noRelInds(noRelInds_this));
            noRelInds = noRelInds(noRelInds_this);
        end
    end
    
    disp(' display graph with children');
    %A = normalise(gviz,2);     % dont normalize graph as each value has a specific meaning and it is lost upon normalization
    A = gviz/max(gviz(:));      % need to have values between 0 & 1, otherwise graph appears very tiny
    params = sexy_graph_params(A);
    params.sfdp_coloring = 0;
    params.NC = 3;
    params.tmpdir = cachedir;
    params.file_prefix = fname;
    params.node_names = phrasenames_disp;
    sexy_graph_asym_img(A,'',params);
    
    save([cachedir '/' fname '.mat'], 'gviz', 'allRoots', 'edgeval', 'ovlap');
end

catch
    disp(lasterr); keyboard;
end

%{
function phraseorder = addThisRoot(rootNow, gviz)

% initialize
phraseorder = [];

% add specifics
isaInds = find(gviz(rootNow, :) == 10);
phraseorder = [phraseorder; isaInds];
% add root
phraseorder = [phraseorder; rootNow];
% add hasParts
hasPartsInds = find(gviz(rootNow, :) == 20);
for j=1:numel(hasPartsInds)
    phraseorder = [phraseorder; addThisRoot(hasPartsInds(j))];
end
% add partOf
partOfInds = find(gviz(rootNow, :) == 30);
phraseorder = [phraseorder; partOfInds];
%}

%%%%%%%%%%%%%%%%%%%%%
function isaInds = getIsA(ovlap, edgeval, k, OVL_T, EDGE_T)
% isa: ovlap and edgeval along both directions is high (>0.5); the greater
% edgeval defines the direction

isaInds = find([ovlap(k,:) > OVL_T & ovlap(:,k)' > OVL_T] & ...
    [edgeval(k,:) < EDGE_T & edgeval(:,k)' < EDGE_T]);
% make sure the node itself is included to avoid infinite while loop (when
% adding noRelInds); node may not be added due to the edgeval < T constraint
if ~ismember(k, isaInds), isaInds = [k; isaInds]; end

%%%%%%%%%%%%%%%%%%%%%
function hasPartInds = getHasPart(ovlap, edgeval, k, OVL_T, EDGE_T, EDGE_RT)

%hasPartInds = find([ovlap(k,:) < OVL_T & ovlap(:,k)' < OVL_T] & ...
%    [edgeval(k,:) ./ edgeval(:,k)' > EDGE_RT]);
hasPartInds = find([ovlap(k,:) < OVL_T & ovlap(:,k)' < OVL_T] & ...
    [edgeval(k,:) ./ edgeval(:,k)' > EDGE_RT & edgeval(:,k)' < EDGE_T]);

%%%%%%%%%%%%%%%%%%%%%
function partOfInds = getPartOf(ovlap, edgeval, k, OVL_T, EDGE_T, EDGE_RT)
% ovlap along both directions is low (<0.5) and edgeval is high along only
% one direction (H -> HH while H <- HDC)

%partOfInds = find([ovlap(k,:) < OVL_T & ovlap(:,k)' < OVL_T] & ...
%    [edgeval(:,k)' ./ edgeval(k,:) > EDGE_RT]);
partOfInds = find([ovlap(k,:) < OVL_T & ovlap(:,k)' < OVL_T] & ...
    [edgeval(:,k)' ./ edgeval(k,:) > EDGE_RT & edgeval(k,:) < EDGE_T]);

%%%%%%%%%%%%%%%%%%%%%%
function noRelInds = getNoRel(numcls, isaInds, partOfInds, hasPartInds)

noRelInds = setdiff(1:numcls, [isaInds(:)' partOfInds(:)' hasPartInds(:)']);

%%%%%%%%%%%%%%%%%%%%%
function noRelInds = sortPartIndicies(noRelInds, rootNow, edgeval, ovlap)

[~, sind] = sort(ovlap(noRelInds,rootNow), 'descend');     % sort based on overlap being largest
    %edgeval(noRelInds,rootNow)  % may be also include edge strengh as criterea
noRelInds = noRelInds(sind);
