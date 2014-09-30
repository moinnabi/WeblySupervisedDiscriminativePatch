function [ds, bs] = mergeBoxes_helper(numids, ds_all, bs_all)

[ds, bs] = deal(cell(numids,1));
for c=1:numel(ds_all)
    myprintf(c, 10);
    for i=1:numel(ds_all{c})
        if ~isempty(ds_all{c}{i})
            ds{i} = [ds{i}; ds_all{c}{i}(:,1:end-1) bs_all{c}{i}(:,end-1) c*ones(size(ds_all{c}{i},1),1) ds_all{c}{i}(:,end)];
        end
    end
end
myprintfn;
