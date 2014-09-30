function [ds_santosh_moin] = merge_ds_moin_santosh(ds_moin,ds_santosh,thresh)


%ds_santosh_moin = ds_santosh;
ds_santosh_moin = [];
    
for i = 1:length(ds_moin)
    if ~isempty(ds_moin{i})
        ds_moin_sel = [];
         for j = 1:size(ds_moin{i},1)
             if ds_moin{i}(j,5) ~= 0 && ds_moin{i}(j,5) > thresh
                 ds_moin_sel = [ds_moin_sel;ds_moin{i}(j,:)];
             end
         end
    end
     if ~isempty(ds_santosh{i})
        ds_santosh_sel = [];
         for j = 1:size(ds_santosh{i},1)
             %if ds_santosh{i}(j,5) > thresh
                 ds_santosh_sel = [ds_santosh_sel;ds_santosh{i}(j,:)];
             %end
         end         
         
         ds_santosh_moin{i} = [ds_santosh_sel ; ds_moin_sel];
    end
end
