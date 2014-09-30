function [itemsets, counts] = trans2itemsets(trans, tree, keys)

% if cell, call for each transation
if iscell(trans)
    for k = 1:numel(trans)
        itemsets = [itemsets ; trans2itemsets(trans{k}, tree)];
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
    
    tree = tree([tree.rootid]==rootid);

    if ~isempty(tree)        

        isvalid = ismember(items, tree.items);
        keymap = find(isvalid);
        items = items(isvalid);
        %items = intersect(items, tree.items);

        itemsets{1} = keys(1);
        counts(1) = tree.count;
        
        for k = 1:numel(items)

            nextitems = [items(k) items(1:k-1) items(k+1:end)];
            nextkeys = keys(keymap([k (1:k-1) (k+1:end)]));
            [tmpsets, tmpcounts] = trans2itemsets(nextitems, tree.tree, nextkeys);
            
            nsets = numel(itemsets);            
            itemsets = [itemsets ; cell(numel(tmpsets), 1)];
            for k2 = 1:numel(tmpsets)
                itemsets{nsets+k2} = [keys(1) tmpsets{k2}];
            end            
            
            counts = [counts ; tmpcounts];
            
        end
    end    

end    
    
           