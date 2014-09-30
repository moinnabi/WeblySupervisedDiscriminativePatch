function [nodes, nn] = tree2nodes(tree)

nnodes = countNodes(tree, 0);

nnodes = nnodes+1;

nodes.rootid = zeros([nnodes 1], 'uint32');
nodes.setid = zeros([nnodes 1], 'uint32');
nodes.nitems = zeros([nnodes 1], 'uint32');
nodes.count = zeros([nnodes 1], 'uint32');
nodes.items = cell([nnodes 1]);
nodes.allitems = cell([nnodes 1]);
nodes.issuperset = cell([nnodes 1]);
nodes.superset = cell([nnodes 1]);
nodes.children = cell([nnodes 1]);
nodes.parent = zeros([nnodes 1], 'uint32');

% nodes = repmat(struct('rootid', 0, 'setid', uint32(0), 'nitems', [], 'count', [], 'items', [], ...
%     'allitems', [], 'issuperset', [], 'superset', [], 'children', []), nnodes, 1);

nodes.nitems(1) = uint32(numel(tree));
nodes.count(1) = uint32(sum([tree.count]));
nodes.items{1} = uint32([tree.rootid]);
nodes.children{1} = zeros([numel(nodes.items{1}) 1], 'uint32');
nn = 1;

[nodes, nn] = tree2nodes_helper(tree, nodes, nn);   


%% 
function [nodes, nn] = tree2nodes_helper(tree, nodes, nn)

nn1 = nn; 

if mod(nn, 1E4)==0    
    disp(num2str(nn))
end

for k = 1:numel(tree)
    
    nn = nn + 1;
    nodes.children{nn1}(k) = nn;
      
    if isempty(tree(k).rootid)
        nodes.rootid(nn) = uint32(0);
    else
        nodes.rootid(nn) = uint32(tree(k).rootid);
    end
    nodes.setid(nn) = tree(k).setid;
    if ~isempty(tree(k).nitems)
        nodes.nitems(nn) = uint32(tree(k).nitems);
        nodes.count(nn) = uint32(tree(k).count);
    end
    nodes.items{nn} = tree(k).items;
    if any(tree(k).issuperset)
        nodes.issuperset{nn} = tree(k).issuperset;
        nodes.superset{nn} = tree(k).superset;
        nodes.allitems{nn} = tree(k).allitems;
    end
    nodes.children{nn} = zeros([numel(nodes.items{nn}) 1], 'uint32');
    nodes.parent(nn) = uint32(nn1);
    
    [nodes, nn] = tree2nodes_helper(tree(k).tree, nodes, nn);
end
    


%% Count number of nodes in tree
function nnodes = countNodes(tree, nnodes)

if ~isempty(tree)    
    for k = 1:numel(tree)
        nnodes = nnodes+1;
        nnodes = countNodes(tree(k).tree, nnodes);
    end
end

