function tree = compressTree(tree)

if isempty(tree)
    tree = [];
    return;
end

for k = 1:numel(tree)
    tree(k).rootid = uint32(tree(k).rootid);
    if tree(k).nitems==0
        tree(k).items = [];
        if isfield(tree(k), 'allitems')
            tree(k).allitems = [];
            tree(k).issuperset = [];
            tree(k).superset = {};
        end
        tree(k).tree = [];
    else
        tree(k).allitems = uint32(tree(k).allitems);
        tree(k).tree = compressTree(tree(k).tree);
    end
end