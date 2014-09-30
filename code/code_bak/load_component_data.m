function ps = load_component_data(dir_data,dir_class,posscores_thresh,component)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

[ps_all,~,num_sample_per_comp] = Load_Subcategory_data(dir_data,dir_class,posscores_thresh);

%disp([num2str(comp),'/',num2str(length(selected_comp))]);
ps = [];
for sample_index = 1:num_sample_per_comp(component)
    ps{1,sample_index} = ps_all{component,sample_index};
end        


end

