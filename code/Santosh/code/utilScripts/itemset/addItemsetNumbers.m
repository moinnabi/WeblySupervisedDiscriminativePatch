function [tree, nitems] = addItemsetNumbers(tree, nitems)

if ~exist('tree', 'var')
    tmp = load('~/data/flickr/misc/closedFimTree2_1.mat');
    tree = tmp.tree1;
    tmp = load('~/data/flickr/misc/closedFimTree2_2.mat');
    tree = [tree tmp.tree2];
    clear tmp;
end

if ~exist('nitems', 'var')
    nitems = 0;
end

for k = 1:numel(tree)
    
    nitems = nitems + 1;

    tree(k).setid = uint32(nitems);
    
    [tree(k).tree, nitems] = addItemsetNumbers(tree(k).tree, nitems);
end

