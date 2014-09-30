function [ps_all,selected_comp,num_sample_per_comp] = Load_Subcategory_data(dir_data,dir_class,posscores_thresh)
    
load([dir_data,dir_class,'_mix.mat'], 'lbbox_mix', 'posscores_mix','inds_mix');
load([dir_data,dir_class,'_train_9990.mat'], 'impos');
load([dir_data,dir_class,'_mix_goodInfo2.mat'], 'selcomps');

%Reform data
ps_all = []; %should be refined
comp_ind = ones(1,6); %number of components = 6
for i = 1:2:length(impos)
    if posscores_mix(i) > posscores_thresh
        comp = inds_mix(i);
        if comp ~=0
            ps_all{comp,comp_ind(comp)}.I = impos(i).im;
            ps_all{comp,comp_ind(comp)}.component = inds_mix(i);
            ps_all{comp,comp_ind(comp)}.bbox = lbbox_mix(i,:);
            ps_all{comp,comp_ind(comp)}.cls = dir_class;
            ps_all{comp,comp_ind(comp)}.id = ps_all{comp,comp_ind(comp)}.I(end-15:end);
            comp_ind(comp) = comp_ind(comp) +1;            
        end
    end
end

%selcomps is binary vector showing which componenets are active for subcategory
selected_comp = find(selcomps);
num_sample_per_comp = comp_ind(selcomps ~= 0) - 1;
end