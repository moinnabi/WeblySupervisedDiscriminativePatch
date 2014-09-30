function tree = getItemsetTrees(savedir, minsupport, nwords)
% tree = getItemsetTrees(savedir, minsupport)
% 
% Gets all trees for transaction lists in savedir

for f = 1:nwords

    disp(num2str(f))
    
    tf = mod(f, 1000);
    strnum = num2str(1E7 + f);
    strnum = strnum(2:end);
    fn = fullfile(savedir, [strnum '.dat']);
    
    if tf==0
        tf = 1000; 
    end

    
    if exist(fn, 'file')
        tree(tf) = transactionlist2closedTree(fn, minsupport);
        tree(tf).rootid = uint32(f);
    end


    if tf==1000
        for k = 1:numel(tree)
            if isempty(tree(k).rootid)
                tree(k).rootid = uint32(0);
            end
        end
        tree = compressTree(tree);
        tmpname = ['tree' num2str(floor(f/1000)) '.mat'];
        save(fullfile(savedir, tmpname), 'tree');
        clear tree;
    end

end
