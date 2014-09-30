function [diff ind1 ind2] = max12(conf)

[val1 ind1] = max(conf,[],2);
for i=1:size(conf,1)
    conf(i,ind1(i)) = 0;
end
[val2 ind2] = max(conf,[],2);
diff = val1-val2;
