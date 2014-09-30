function [itemsets, counts, rawsets, ids] = ...
    trans2closedItemsetsUsingNodesNoRecursion(trans, nodes, keys, nextidx, maxtime)
% [itemsets, counts, rawItemsets, ids] = trans2closedItemsets(trans, nodes, keys)
% 
% Gets all subsets of trans that are in tree.
%
% itemsets: subsets indexed by key
% rawsets: subsets without key indexing
%

if ~exist('nextidx', 'var')
    nextidx = [];
end

if ~exist('maxtime', 'var')
    maxtime = Inf;
end

% if cell, call for each transation
if iscell(trans)
    
    currtime = cputime;
    maxtime = currtime + 30;
    
    itemsets = {};
    rawsets = {};
    counts = [];
    ids = [];
    for k = 1:numel(trans)        
        if isempty(nextidx)
            ni = [];
        else
            ni = nextidx(k);
        end
        if exist('keys', 'var') && ~isempty(keys)
            [tmpsets, tmpcounts, tmpraw, tmpids] = ...
                trans2closedItemsetsUsingNodesNoRecursion(trans{k}, nodes, keys{k}, ni, maxtime);
        else
            [tmpsets, tmpcounts, tmpraw, tmpids] = ...
                trans2closedItemsetsUsingNodesNoRecursion(trans{k}, nodes, [], ni, maxtime);
        end
        itemsets = [itemsets ; tmpsets];
        rawsets = [rawsets ; tmpraw];
        counts = [counts ; tmpcounts];
        ids = [ids ; tmpids];
        
        if cputime>maxtime
            disp(['time = ' num2str(cputime-currtime) ' seconds ... breaking']);
            break;
        end
        
    end
    
else % get itemsets matching trans within tree
            
    if ~exist('keys', 'var') || isempty(keys) 
        keys = (1:numel(trans));
    end
    
    rootid = trans(1);    
    if isempty(nextidx)
        nextidx = nodes.children{1}(nodes.items{1}==rootid);        
    end    
    
    [utrans, uind] = unique(trans(2:end));
    
    keys = [keys(1) keys(uind+1)];
    trans = [trans(1) utrans];        
    
    [itemsets, counts, rawsets, ids] = ...    
        checkRegularSets(unique(trans), nodes, keys, nextidx, maxtime);
       
    if 0
        [itemsets2, counts2, rawsets2, ids2] = ...    
            checkSupersets(trans, nodes, keys, nextidx);    

        itemsets = [itemsets ; itemsets2];
        counts = [counts ; counts2];
        rawsets = [rawsets ; rawsets2];
        ids = [ids ; ids2];
    end
    
end
   

%% Check for regular (recursive) itemsets
function [itemsets, counts, rawsets, ids] = ...
        checkRegularSets(trans, nodes, inkeys, nextidx, maxtime)

    
stack = 1;
maxstack = 0;

% ipreset = cell(maxstack, 1);
% rpreset = cell(maxstack, 1);
% keymap = cell(maxstack, 1);
% items = cell(maxstack, 1);
% keys = cell(maxstack, 1);
% ii = zeros(maxstack, 1);
% nn = zeros(maxstack, 1);

nn(stack) = nextidx;
items{stack} = trans;           
keys{stack} = inkeys;
ii(stack) = 0;
ipreset{stack} = [];
rpreset{stack} = [];

% maxsets = 0;
% itemsets = cell(maxsets, 1);
% rawsets = cell(maxsets, 1);
% counts = zeros(maxsets, 1);        
% ids = zeros(maxsets, 1);    

nsets = 0;


while stack>0                               

    nns = nn(stack);    
    
    if ii(stack) == 0                                 
                    
        % add current set
        nsets = nsets+1;                                 

        itemsets{nsets,1} = [ipreset{stack} keys{stack}(1)];
        rawsets{nsets,1} = [rpreset{stack} items{stack}(1)];
        ids(nsets,1) = nodes.setid(nns);  
        counts(nsets,1) = nodes.count(nns);
        
        ipreset{stack+1} = itemsets{nsets};
        rpreset{stack+1} = rawsets{nsets};                        

        % get items for larger sets
        if ~isempty(nodes.allitems{nns})
            isvalid = ismember(items{stack}, nodes.allitems{nns}); 
            [itemsets2, counts2, rawsets2, ids2] = ...
               checkSupersets(items{stack}(isvalid), nodes, keys{stack}(isvalid), nns);           
           for k = 1:numel(itemsets2)
               nsets = nsets+1;
               itemsets{nsets,1} = [ipreset{stack+1} itemsets2{k}];
               rawsets{nsets,1} = [rpreset{stack+1} rawsets2{k}];
               counts(nsets,1) = counts2(k);
               ids(nsets,1) = ids2(k);
           end
        end        
        
        isvalid = ismember(items{stack}, nodes.items{nns});                          
        keymap{stack} = find(isvalid);
        items{stack} = items{stack}(isvalid);               
        
          
        
    end
    
    ii(stack) = ii(stack) + 1; % step through orderings of items

    if ii(stack) > numel(items{stack}) 

        % return to previous level in tree

        stack = stack - 1;        
        
        %disp(num2str(stack))
        
    else

        % descend further into tree

        nns = nn(stack);

        k = ii(stack);     

        items{stack+1} = items{stack}([k (1:k-1) (k+1:end)]); 
        keys{stack+1} = keys{stack}(keymap{stack}([k (1:k-1) (k+1:end)])); 
        nn(stack+1) = nodes.children{nns}(nodes.items{nns}==items{stack}(k));      
        ii(stack+1) = 0;
        
        stack = stack+1;

    end    
        
    if cputime > maxtime        
        break;
    end
    
end

ind = counts>0;

itemsets = itemsets(ind);
rawsets = rawsets(ind);
counts = counts(ind);
ids = ids(ind);


%% Check for supersets
function [itemsets, counts, rawsets, ids] = ...
        checkSupersets(items, nodes, keys, nextidx)
            
itemsets = cell(0, 1);
rawsets = cell(0, 1);
counts = zeros(0, 1);        
ids = zeros(0, 1);             
    
nsets = 0;

for k = 1:numel(items)
    nn = nextidx;               
    for k2 = find(nodes.issuperset{nn})
        if nodes.superset{nn}{k2}(1)==items(k)
            itemsets{end+1, 1} = keys(ismember(items, nodes.superset{nn}{k2}));
            rawsets{end+1, 1} = intersect(items, nodes.superset{nn}{k2});
            counts(end+1, 1) = nodes.count(nodes.children{nn}(k2));
            ids(end+1, 1) = nodes.setid(nodes.children{nn}(k2)); 
        end        
    end
end
[itemsets, counts, rawsets, ids] = ...
    removeRedundantItemsets(itemsets, counts, rawsets, ids, [1 numel(itemsets)]);  
    



%% helper: remove redundant itemsets
function [itemsets, counts, rawsets, ids] = removeRedundantItemsets(itemsets, counts, rawsets, ids, inds)

% remove redundant itemsets
keep = true(size(itemsets));
for k1 = inds(1):inds(2)
    for k2 = k1+1:inds(2)
        if numel(itemsets{k1})==numel(itemsets{k2}) && ...
                all(itemsets{k1}==itemsets{k2})
            if counts(k1)<counts(k2)
                keep(k1) = false;
            else
                keep(k2) = false;
            end
        end
    end
end        

itemsets = itemsets(keep);
counts =counts(keep);
rawsets = rawsets(keep);           
ids = ids(keep); 