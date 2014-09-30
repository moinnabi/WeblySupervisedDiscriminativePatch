function ds_santosh_rescored_sub = ds_subset_selection(ds_santosh_rescored, th)

for i = 1:length(ds_santosh_rescored)
    ds_santosh_rescored_sub{i} = [];
    if ~isempty(ds_santosh_rescored{i})
        ds_santosh_rescored_sel = [];
         for j = 1:size(ds_santosh_rescored{i},1)
             if ds_santosh_rescored{i}(j,5) > th
                 ds_santosh_rescored_sel = [ds_santosh_rescored_sel;ds_santosh_rescored{i}(j,:)];
             end
         end
         ds_santosh_rescored_sub{i} = ds_santosh_rescored_sel;
    end
end