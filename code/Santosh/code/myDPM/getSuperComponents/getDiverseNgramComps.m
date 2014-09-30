function getDiverseNgramComps(cachedir, phrasenames, numComp)

try    

disp(['getDiverseNgramComps(''' cachedir ''')']);

load([cachedir '/edgematrix.mat'], 'edgeval');
numcls = numel(phrasenames);

% update the matrix such that edgeval(i,j) has score at least as much as  edgeval(j,j) 
dmat = edgeval;
for j=1:numcls
    inds = dmat(:,j) < dmat(j,j);  
    dmat(inds, j) = dmat(j,j);
    
    inds = dmat(j,:) < dmat(j,j);    
    dmat(j, inds) = dmat(j,j);
end

% for each node, pick all other nodes that it 'likes'
% i.e., gives high AP/low rank, and remove those nodes
% now amongst the remaining nodes, repeat the above process

rankThresh = 5;
offsetThresh = rankThresh/2;
remNodes = 1:numcls;
simNodes = cell(numcls, 1);
while ~isempty(remNodes)
    pickNode = remNodes(1);
    fprintf('%d ', pickNode);    
    %likeNodes = find(dmat(pickNode, remNodes) < rankThresh);
    likeNodes = find(...
        [dmat(remNodes, pickNode) < max(rankThresh, dmat(pickNode, pickNode) + offsetThresh)] & ...
        [dmat(pickNode, remNodes)' < max(rankThresh, diag(dmat(remNodes, remNodes)) + offsetThresh)]);
    if isempty(find(likeNodes==1, 1))
        if ~isempty(likeNodes), disp('here'); keyboard; end
        likeNodes = [1 likeNodes]; 
    end
    %likeNodes = remNodes(likeNodes);
    simNodes{pickNode} = remNodes(likeNodes);
    remNodes(likeNodes) = [];    
end

disp('here'); keyboard;

catch
    disp(lasterr); keyboard;
end

%{
colsum = sum(dmat, 1);
[~, cind] = sort(colsum, 'ascend');

rowsum = sum(dmat, 2);
[~, rind] = sort(rowsum, 'ascend');

ngids(rind(1:10))

disp('here'); keyboard;
%}
