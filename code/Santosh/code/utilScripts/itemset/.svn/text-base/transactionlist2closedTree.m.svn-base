function tree = transactionlist2closedTree(fn, minsupport)
% tree = transactionlist2tree(fn, minsupport)
%
% Computes itemsets that satisfy minimum support (using ./fim_all) and
% stores them in a tree structure.

system(['./fim_closed ' fn ' ' num2str(minsupport) ' ./result.txt > message.txt']);
fid = fopen('./result.txt', 'r');    
tree = list2tree(fid, [], [], minsupport, minsupport);
fclose(fid);

%% recursive function to build tree
function [tree, line] = list2tree(fid, itemlist, line, currmin, absmin)

level = numel(itemlist);
if isempty(itemlist)
    itemlist = zeros([1 0]);
end

%treestruct = struct('rootid', [], 'nitems', uint32(0), 'count', uint32(0), ...
%    'level', level, 'items', [], 'issuperset', [], 'itemset', {}, 'tree', []);
tree.rootid = zeros([1 0], 'uint32');  tree.nitems = uint32(0);  
tree.count = uint32(0);  tree.level = level;  tree.items = zeros([1 0], 'uint32');
tree.allitems = zeros([1 0], 'uint32');
tree.issuperset = false([1 0]);  tree.superset = {}; tree.tree = [];
%tree = struct('rootid', [], 'nitems', uint32(0), 'count', uint32(0), ...
%    'level', level, 'items', [], 'issuperset', [], 'superset', cell(1,0), 'tree', []);
emptytree = tree;
tree.tree = repmat(tree, [0 1]);



while 1

    if isempty(line)
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end
    elseif ~ischar(line)
        break;
    end
    
    toks = strtokAll(line, ' ');
    ntoks = numel(toks);
    nitems = ntoks-1;   
    
    items = zeros(1, nitems);
    for k = 1:nitems
        items(k) = str2double(toks{k});
    end

    count = str2double(toks{end}(2:end-1));

    % insufficient support
    if count<currmin
        line = [];
        continue;
    end    
    
    % support is larger of (original support) and (0.1%*num transactions)
    if count>absmin*1000
        currmin = ceil(count/1000); 
    else
        currmin = absmin;
    end
    
    if nitems==level  % return tree
        if level==0
            tree.count = count;
            %disp(num2str(count))
            line = [];
        else        
            break;
        end
        
    elseif (nitems>=level+1) && all(itemlist==items(1:level)) % add item/subtree
        
        tree.nitems = uint32(tree.nitems+1);
        if nitems==level+1 % single item branch
            lastitem = items(nitems);
            tree.items(tree.nitems) = uint32(lastitem);
            tree.issuperset(tree.nitems) = false;
            [tree.tree(tree.nitems), line] = list2tree(fid, items, [], currmin, absmin);
            tree.tree(tree.nitems).rootid = uint32(lastitem); 
        else % multiple item (superset) branch            
            lastitem = items(level+1:nitems);
            tree.items(tree.nitems) = uint32(0);
            tree.issuperset(tree.nitems) = true;  
            tree.superset{tree.nitems} = uint32(lastitem);
            tree.tree(tree.nitems) = emptytree;
            line = [];
        end
                
        %[tree.tree(tree.nitems), line] = list2tree(fid, items, []);       
        tree.tree(tree.nitems).count = uint32(count);                                   
        tree.allitems = union(tree.allitems, lastitem);
        
%         if nitems > level+1
%             break;
%         end
        
        %tree.allitems = union(tree.items, tree.tree(tree.nitems).allitems);
        
    else % return tree
        break;        
    end
end

