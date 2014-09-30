function tree = transactionlist2tree(fn, minsupport)
% tree = transactionlist2tree(fn, minsupport)
%
% Computes itemsets that satisfy minimum support (using ./fim_all) and
% stores them in a tree structure.

system(['./fim_all ' fn ' ' num2str(minsupport) ' ./result.txt > message.txt']);
fid = fopen('./result.txt', 'r');    
tree = list2tree(fid, 0, []);
fclose(fid);

%% recursive function to build tree
function [tree, line] = list2tree(fid, level, line)

tree = struct('rootid', [], 'nitems', uint32(0), 'count', uint32(0), 'level', level, 'items', [], 'tree', []);
tree.tree = repmat(struct('rootid', [], 'nitems', uint32(0), 'count', uint32(0), 'level', level, 'items', [], 'tree', []), [0 1]);

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
    
    count = str2double(toks{end}(2:end-1));
        
    if nitems==level  % return tree
        if level==0
            tree.count = count;
            disp(num2str(count))
            line = [];
        else        
            break;
        end
        %
        %line = [];
%         if level>0
%             lastitem = str2double(toks{nitems});
%             tree.items(end+1) = lastitem;
%             tree.nitems = tree.nitems+1;
%             tree.tree(tree.nitems) = struct('nitems', 0, 'count', 0, ...
%                 'level', level+1, 'items', [], 'tree', []);
%         end
%         line = [];
        
    elseif nitems==level+1 % add item/subtree
        lastitem = str2double(toks{nitems});
        tree.items(end+1) = uint32(lastitem);
        tree.nitems = uint32(tree.nitems+1);
        [tree.tree(tree.nitems), line] = list2tree(fid, level+1, []);
        tree.tree(tree.nitems).count = uint32(count);
        tree.tree(tree.nitems).rootid = uint32(lastitem);
        
    elseif nitems<level % return tree
        break;
        
    else % nitems>level+1: should not happen
        error('unexpected jump in branch length')
    end
end

