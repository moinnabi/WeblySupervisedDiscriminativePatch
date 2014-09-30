function [ps] = load_data_comp(ps_tmp,component,dir_class)
    
%Reform data
ps = []; %should be refined

for i = 1 : length(ps_tmp)
      
    ps{i}.imgurl = ps_tmp(i).imgurl;
    %ps{i}.I = filestr;
    ps{i}.component = component;
    ps{i}.bbox = ps_tmp(i).bbox;
    ps{i}.cls = dir_class;
    %ps{i}.id = id;

    ps{i}.flip = ps_tmp(i).flip;
    ps{i}.trunc = ps_tmp(i).trunc;
end