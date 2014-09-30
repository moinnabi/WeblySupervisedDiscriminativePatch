function ps = load_component_data(dir_data,dir_class,posscores_thresh,component)
% Function to load data of each componenet into PS
%   by: Moin

[ps_all,~,num_sample_per_comp] = Load_Subcategory_data(dir_data,dir_class,posscores_thresh);

%disp([num2str(comp),'/',num2str(length(selected_comp))]);
ps = [];
for sample_index = 1:num_sample_per_comp(component)
    ps{1,sample_index} = ps_all{component,sample_index};
end


end

