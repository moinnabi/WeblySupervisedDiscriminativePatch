function getGraphFromAdjacencyMatrix_joint(cachedir, cls, objname, data_year, datatype)

try    

disp(['getGraphFromAdjacencyMatrix_joint(''' cachedir ''',''' cls ''',''' objname ''',''' data_year ''',''' datatype ''')' ]);

% define isa and part of relations for "horse" (and then later recurse that)
OVL_ISA = 0.5;
OVL_PART1l = 0.05;
OVL_PART1h = 0.50;  %.2
OVL_PART2 = 0.5; 
EDGE_T = 5.0;
EDGE_RT = 1.5;

% terminology for graphviz
% init: 0
% isaInds: 10
% hasPartInds: 20

fname = ['tree_' datatype '_' data_year]; 
try
    load([cachedir '/' fname '.mat'], 'gviz');
    disp(' loaded precomputed graph');
catch    
    disp(' loading precomputed adjacency matrix');
    load([cachedir '/' 'matrix_' datatype '_' data_year '_mix' '.mat'], 'edgeval', 'ovlap');
    load([cachedir '/' cls '_' 'joint_data' '.mat'], 'listOfSelNgramComps_globalIds', 'listOfSelNgramComps_accs', 'model');
        
    %highlyGoodInds = find(listOfSelNgramComps_accs > 0.6);    
    numcls = numel(listOfSelNgramComps_globalIds);
    gviz = zeros(numcls, numcls);
    allRoots =[];
    
    phrasenames_disp = cell(numcls, 1);
    for i=1:numcls
        if ~isempty(strfind(model.phrasenames{i}, ['_' objname '_super ']))
            phrasenames_disp{i} = strrep(model.phrasenames{i}, ['_' objname '_super '], '');
        else
            phrasenames_disp{i} = strrep(model.phrasenames{i}, ['_' objname ' '], '');
        end
        if length(phrasenames_disp{i}) > 5
            phrasenames_disp{i} = [phrasenames_disp{i}(1:5) phrasenames_disp{i}(end)];
        end
        phrasenames_disp{i} = [phrasenames_disp{i} '_' num2str(i)];
    end 
    
    %objname = textread(basefname, '%s');        % keyword typed by user
    %initRootInd = find(strcmp(phrasenames, objname));
    initRootInd = 3;
    
    disp(' get two-layered DAG');
        
    ovlap = ovlap(listOfSelNgramComps_globalIds, listOfSelNgramComps_globalIds);
    edgeval = edgeval(listOfSelNgramComps_globalIds, listOfSelNgramComps_globalIds);
    
    %gviz = getAllIsA(gviz, ovlap, edgeval, OVL_ISA, EDGE_T);
    %gviz = getAllKindOf(gviz, ovlap, edgeval, OVL_ISA, EDGE_T);
    gviz = getAllHasPart(gviz, ovlap, edgeval, OVL_PART1l, OVL_PART1h, OVL_PART2, EDGE_T, max(edgeval(:)), EDGE_RT,listOfSelNgramComps_accs);
          
    disp(' display full graph');
    %A = normalise(gviz,2);     % dont normalize graph as each value has a specific meaning and it is lost upon normalization
    A = gviz/max(gviz(:));      % need to have values between 0 & 1, otherwise graph appears very tiny
    params = sexy_graph_params(A);
    params.sfdp_coloring = 0;
    params.NC = 1;  
    params.tmpdir = cachedir;
    params.file_prefix = ['fullGraph_' fname];
    params.node_names = phrasenames_disp;
    sexy_graph_asym_img(A,'',params);
    imwrite(imresize(imread([params.tmpdir params.file_prefix '.png']), 0.25), [params.tmpdir params.file_prefix '_resize.png']);
    
    
    disp('here'); keyboard;
    
    isaInds = getIsA(ovlap, edgeval, initRootInd, OVL_T, EDGE_T);
    hasPartInds = getHasPart(ovlap, edgeval, initRootInd, OVL_T, EDGE_T, EDGE_RT);    
    noRelInds = getNoRel(numcls, isaInds, hasPartInds);
    
    % update graph
    gviz(initRootInd, isaInds) = 10;
    gviz(initRootInd, hasPartInds) = 20;
    allRoots = [allRoots; initRootInd];
        
    disp('building Forest: repeat above process (recurse isa, hasPart and partOf steps) for each unrelated node');    
    
    while ~isempty(noRelInds)
        thisovlap = ovlap(noRelInds, noRelInds);
        thisedgeval = edgeval(noRelInds, noRelInds);
        %rootInd = noRelInds(1);    % no need to do unvisited(1) as you use thisovlap and thisedgeval
        rootInd = 1;
        isaInds_this = getIsA(thisovlap, thisedgeval, rootInd, OVL_T, EDGE_T);
        hasPartInds_this = getHasPart(thisovlap, thisedgeval, rootInd, OVL_T, EDGE_T, EDGE_RT);        
        noRelInds_this = getNoRel(size(thisovlap,1), isaInds_this, hasPartInds_this);
        
        % updte graph
        gviz(noRelInds(rootInd), noRelInds(isaInds_this)) = 10;
        gviz(noRelInds(rootInd), noRelInds(hasPartInds_this)) = 20;        
        allRoots = [allRoots; noRelInds(rootInd)];
        
        %noRelInds = sortNoRel(noRelInds(noRelInds_this));
        noRelInds = noRelInds(noRelInds_this);
    end
        
    disp(' display graph uptil now');
    %A = normalise(gviz,2);     % dont normalize graph as each value has a specific meaning and it is lost upon normalization
    A = gviz/max(gviz(:));      % need to have values between 0 & 1, otherwise graph appears very tiny
    params = sexy_graph_params(A);
    params.sfdp_coloring = 0;
    params.NC = 2;
    params.tmpdir = cachedir;
    params.file_prefix = ['noChild_' fname];
    params.node_names = phrasenames_disp;
    sexy_graph_asym_img(A,'',params);
    imwrite(imresize(imread([params.tmpdir params.file_prefix '.png']), 0.25), [params.tmpdir params.file_prefix '_resize.png']);
    
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

%%%%%%%%%%%%%%%%%%%%%
function gviz = getAllIsA(gviz, ovlap, edgeval, OVL_T, EDGE_T)
% isa: ovlap and edgeval along both directions is high (>0.5); the greater
% edgeval defines the direction

for k=1:size(gviz,1)
    isaInds = find([ovlap(k,:) > OVL_T & ovlap(:,k)' > OVL_T] & ...
        [edgeval(k,:) < EDGE_T & edgeval(:,k)' < EDGE_T]);
    % make sure the node itself is included to avoid infinite while loop (when
    % adding noRelInds); node may not be added due to the edgeval < T constraint
    if ~ismember(k, isaInds), isaInds = [k; isaInds]; end
    
    gviz(k, isaInds) = 10;    
end

%%%%%%%%%%%%%%%%%%%%%
function gviz = getAllKindOf(gviz, ovlap, edgeval, OVL_T, EDGE_T)
% kindOf: ovlap along both directions is high (>0.5); edgeval along one
% direction is good and on other direction is poor

for k=1:size(gviz,1)
    kindOfInds = find([ovlap(k,:) > OVL_T & ovlap(:,k)' > OVL_T] & ...
        [edgeval(k,:) >= EDGE_T & edgeval(:,k)' < EDGE_T]);
    % make sure the node itself is included to avoid infinite while loop (when
    % adding noRelInds); node may not be added due to the edgeval < T constraint
    %if ~ismember(k, isaInds), isaInds = [k; isaInds]; end
    
    gviz(kindOfInds, k) = 30;
end


%%%%%%%%%%%%%%%%%%%%%
function gviz = getAllHasPart(gviz, ovlap, edgeval, OVL_T1l, OVL_T1h, OVL_T2, EDGE_T1, EDGE_T2, EDGE_RT, accvals)

minHighGoodAcc = 0.6;
for k=1:size(gviz,1)      
    %hasPartInds = find([ovlap(k,:) < OVL_T & ovlap(:,k)' < OVL_T] & ...
    %    [edgeval(k,:) ./ edgeval(:,k)' > EDGE_RT]);
    hasPartInds = find([ovlap(k,:) < OVL_T2 & ovlap(:,k)' >= OVL_T1l & ovlap(:,k)' <= OVL_T1h] & ...
        [edgeval(k,:) ./ edgeval(:,k)' > EDGE_RT & edgeval(k,:) < EDGE_T2 & edgeval(:,k)' < EDGE_T1] & ...
        accvals(:)' > minHighGoodAcc);
    gviz(k, hasPartInds) = 20; 
end 

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
function noRelInds = getNoRel(numcls, isaInds, hasPartInds)

noRelInds = setdiff(1:numcls, [isaInds(:)' hasPartInds(:)']);

%%%%%%%%%%%%%%%%%%%%%
function noRelInds = sortPartIndicies(noRelInds, rootNow, edgeval, ovlap)

[~, sind] = sort(ovlap(noRelInds,rootNow), 'descend');     % sort based on overlap being largest
    %edgeval(noRelInds,rootNow)  % may be also include edge strengh as criterea
noRelInds = noRelInds(sind);
