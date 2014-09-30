function [ds_all, bs_all] = getBoxes_helper(cachedir, dataset, year, phrasenames, modelname)

try
    
if nargin < 5
    modelname = '';
end

if isempty(modelname)    
    this_suffix = ['_boxes_' dataset '_' year];
    savename = [cachedir 'allboxes_data_' dataset '_' year];
else    
    this_suffix = ['_boxes_' dataset '_' year '_' modelname];
    savename = [cachedir 'allboxes_data_' dataset '_' year '_' modelname];
end

try
    load(savename, 'ds_all', 'bs_all');
catch    
    numcls = numel(phrasenames);
    ds_all = cell(numcls, 1); bs_all = cell(numcls, 1);
    disp(' loading bbox predictions');
    parfor c = 1:numcls            % Load bbox predicted detections (loads vars ds, bs)
        myprintf(c, 10);
        try
            tmp = load([cachedir '/../' phrasenames{c} '/' phrasenames{c} this_suffix], 'ds', 'bs');
            ds_all{c} = tmp.ds(:);
            bs_all{c} = tmp.bs(:);
        end
    end
    myprintfn;
     
    disp(' keep only highest scoring detections');
    parfor c = 1:numcls
        myprintf(c, 10);
        data = cell2mat(ds_all{c});        
        if size(data,1) > 50000     % keep only highest scoring detections
            s = data(:,end);
            s = sort(s);
            v = s(end-50000+1);
            for i = 1:numel(ds_all{c})
                if ~isempty(ds_all{c}{i})
                    I = find(ds_all{c}{i}(:,end) >= v);
                    ds_all{c}{i} = ds_all{c}{i}(I,:);
                    bs_all{c}{i} = bs_all{c}{i}(I,:);
                end
            end
        end
    end
    myprintfn;
    
    save(savename, 'ds_all', 'bs_all', '-v7.3');
end

catch
    disp(lasterr); keyboard;
end
