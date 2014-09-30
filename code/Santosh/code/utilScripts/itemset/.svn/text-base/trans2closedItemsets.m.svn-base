function [itemsets, counts, rawsets, ids] = ...
    trans2closedItemsets(trans, tree, keys, nextidx)
% [itemsets, counts, rawItemsets, ids] = trans2closedItemsets(trans, tree, keys)
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
                trans2closedItemsets(trans{k}, tree, keys{k}, ni);
        else
            [tmpsets, tmpcounts, tmpraw, tmpids] = ...
                trans2closedItemsets(trans{k}, tree, [], ni);
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
    
    rootid = trans(1);
    %items = trans(2:end);
    items = trans;
    
    %itemsets{1} = rootid;
    itemsets = cell(1,0);
    rawsets = cell(1,0);
    counts = zeros(1, 0);        
    ids = zeros(1, 0);
    
    
    if ~isempty(nextidx)
        tree = tree(nextidx);
    else
        tree = tree([tree.rootid]==rootid);
    end
    
    if ~isempty(tree) && tree.rootid~=0 % descend into tree

        isvalid = ismember(items, tree.allitems);
        keymap = find(isvalid);
        items = items(isvalid);
        %items = intersect(items, tree.items);

        itemsets{1} = keys(1);
        rawsets{1} = trans(1);
        counts(1) = tree.count;
        ids(1) = tree.setid;
        
        for k = 1:numel(items)

            nextitems = [items(k) items(1:k-1) items(k+1:end)];
            nextkeys = keys(keymap([k (1:k-1) (k+1:end)]));
            nextidx = find(items(k)==tree.items);
            [tmpsets, tmpcounts, tmpraw, tmpids] = ...
                trans2closedItemsets(nextitems, tree.tree, nextkeys, nextidx);
            
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
                for k2 = find(tree.issuperset)
                    if tree.superset{k2}(1)==items(k)
                        itemsets{end+1, 1} = [keys(1) keys(keymap(ismember(items, tree.superset{k2})))];
                        rawsets{end+1, 1} = [rootid intersect(items, tree.superset{k2})];
                        counts(end+1, 1) = tree.tree(k2).count;
                        ids(end+1, 1) = tree.tree(k2).setid;
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