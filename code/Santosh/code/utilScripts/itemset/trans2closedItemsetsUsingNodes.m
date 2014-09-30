function [itemsets, counts, rawsets, ids] = ...
    trans2closedItemsetsUsingNodes(trans, nodes, keys, nextidx)
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

% if cell, call for each transation
if iscell(trans)
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
                trans2closedItemsetsUsingNodes(trans{k}, nodes, keys{k}, ni);
        else
            [tmpsets, tmpcounts, tmpraw, tmpids] = ...
                trans2closedItemsetsUsingNodes(trans{k}, nodes, [], ni);
        end
        itemsets = [itemsets ; tmpsets];
        rawsets = [rawsets ; tmpraw];
        counts = [counts ; tmpcounts];
        ids = [ids ; tmpids];
    end
    
else % get itemsets matching trans within tree
    
    if ~exist('keys', 'var') || isempty(keys) 
        keys = (1:numel(trans));
    end
    
    %disp(num2str(trans))
    %disp(num2str(trans))
    
    rootid = trans(1);
    %items = trans(2:end);
    items = trans;
    
    %itemsets{1} = rootid;
    itemsets = cell(1,0);
    rawsets = cell(1,0);
    counts = zeros(1, 0);        
    ids = zeros(1, 0);
    
    
    if ~isempty(nextidx)
        nn = nextidx;
    else
        nn = nodes.children{1}(nodes.items{1}==rootid);        
    end
    
    if nodes.rootid(nn)~=0 %~isempty(nodes.children{nn}) && nodes.rootid(nn)~=0 % descend into tree        
        
        if ~isempty(nodes.allitems{nn})
            isvalid = ismember(items, nodes.allitems{nn});
        else
            isvalid = ismember(items, nodes.items{nn});
        end
        keymap = find(isvalid);
        items = items(isvalid);
        %items = intersect(items, tree.items);

        itemsets{1} = keys(1);
        rawsets{1} = trans(1);
        counts(1) = nodes.count(nn);
        ids(1) = nodes.setid(nn);
        
        for k = 1:numel(items)

            nextitems = [items(k) items(1:k-1) items(k+1:end)];
            nextkeys = keys(keymap([k (1:k-1) (k+1:end)]));
            nextidx = nodes.children{nn}(nodes.items{nn}==items(k));
            [tmpsets, tmpcounts, tmpraw, tmpids] = ...
                trans2closedItemsetsUsingNodes(nextitems, nodes, nextkeys, nextidx);
            
            if ~isempty(tmpsets)
            
                nsets = numel(itemsets);            
                itemsets = [itemsets ; cell(numel(tmpsets), 1)];
                rawsets = [rawsets ; cell(numel(tmpsets), 1)];
                for k2 = 1:numel(tmpsets)
                    itemsets{nsets+k2} = [keys(1) tmpsets{k2}];
                    rawsets{nsets+k2} = [rootid tmpraw{k2}];
                end            
            
                counts = [counts ; tmpcounts];
                ids = [ids ; tmpids];
                
            else % check for supersets
                inds = numel(itemsets)+1;                
                for k2 = find(nodes.issuperset{nn})
                    if nodes.superset{nn}{k2}(1)==items(k)
                        itemsets{end+1, 1} = [keys(1) keys(keymap(ismember(items, nodes.superset{nn}{k2})))];
                        rawsets{end+1, 1} = [rootid intersect(items, nodes.superset{nn}{k2})];
                        counts(end+1, 1) = nodes.count(nodes.children{nn}(k2));
                        ids(end+1, 1) = nodes.setid(nodes.children{nn}(k2)); 
                    end
                end
                inds = [inds numel(itemsets)];
                [itemsets, counts, rawsets, ids] = ...
                    removeRedundantItemsets(itemsets, counts, rawsets, ids, inds);
        
            end
                            
        end
    end    

end    
    

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