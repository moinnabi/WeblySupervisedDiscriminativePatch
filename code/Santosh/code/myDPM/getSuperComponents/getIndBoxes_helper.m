function [ds, bs] = getIndBoxes_helper(cachedir, dataset, year, thisphrasename, modelname)
% used by get_dstop

if isempty(modelname)    
    this_suffix = ['_boxes_' dataset '_' year];    
else    
    this_suffix = ['_boxes_' dataset '_' year '_' modelname];    
end

load([cachedir '/../' thisphrasename '/' thisphrasename this_suffix], 'ds', 'bs');
data = cell2mat(ds);
if size(data,1) > 50000     % keep only highest scoring detections
    s = data(:,end);
    s = sort(s);
    v = s(end-50000+1);
    for i = 1:numel(ds)
        if ~isempty(ds{i})
            I = find(ds{i}(:,end) >= v);
            ds{i} = ds{i}(I,:);
            bs{i} = bs{i}(I,:);
        end
    end
end
