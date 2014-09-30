function [X, boxes] = context_data_carlos_wsup(cachedir, dataset, year, phrasenames)

try
    
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;    
conf = voc_config('pascal.year', year);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;
nmsolap = 0.6;  % ensures between 91% to 95% recall    

ids = textread(sprintf(VOCopts.imgsetpath, dataset), '%s');
numids = length(ids);
numcls = length(phrasenames);

numToKeep = 50000;
%disp(['numToKeep is ' num2str(numToKeep)]);

disp(' get dimensions of each image in the dataset');
try
    load([cachedir 'sizes_' dataset '_' year])
catch
    sizes = cell(numids,1);
    for i = 1:numids
        tic_toc_print('caching image sizes: %d/%d\n', i, numids);
        name = sprintf(VOCopts.imgpath, ids{i});
        im = imread(name);
        sizes{i} = size(im);
    end
    save([cachedir 'sizes_' dataset '_' year], 'sizes');
end

disp(' generate the context data')
try
    load([cachedir 'context_data_' dataset '_' year]);
catch
    disp('Constructing context features (this will take a little while)...');

    disp(' loading bbox predictions');
    ds_all = cell(numcls, 1);
    bs_all = cell(numcls, 1);    
    for c = 1:numcls
        myprintf(c, 10);
        load([cachedir '/../' phrasenames{c} '/' phrasenames{c} '_boxes_' dataset '_' year], 'ds', 'bs');
        ds_all{c} = ds;
        %bs_all{c} = bs;
    end
    myprintfn;
    
    disp(' keep only highest scoring detections');
    for c = 1:numcls
        myprintf(c, 10);
        data = cell2mat(ds_all{c}');
        % keep only highest scoring detections
        if size(data,1) > numToKeep
            s = data(:,end);
            s = sort(s);
            v = s(end-numToKeep+1);
            for i = 1:numids;
                if ~isempty(ds_all{c}{i})
                    I = find(ds_all{c}{i}(:,end) >= v);
                    ds_all{c}{i} = ds_all{c}{i}(I,:);
                    %bs_all{c}{i} = bs_all{c}{i}(I,:);
                end
            end
        end
    end
    myprintfn;
    
    disp('consolidate boxes and do nms');
    boxes = cell(numids,1);
    for i=1:numids
        myprintf(i,100);
        
        % consolidate boxes
        boxes{i} = [];
        for c=1:numcls
            thisbox = ds_all{c}{i};
            if ~isempty(thisbox)
                boxes{i} = [boxes{i}; thisbox(:,1:4) ones(size(thisbox,1),1)*c ones(size(thisbox,1),1)*i thisbox(:,5)];
            end
        end
        
        % apply nms        
        [blah, blah, nmsinds] = bboxNonMaxSuppression(boxes{i}(:,1:4), boxes{i}(:,end), nmsolap);
        boxes{i} = boxes{i}(nmsinds,:);
    end            
    
    disp(' get all pairs overlap and build feature');
    OVP = cell(numids,1);    
    X = cell(numids,1);
    for i=1:numids
        myprintf(i,10);
        s = sizes{i};
        numboxes = size(boxes{i},1);
        
        % get overlap
        ov = zeros(numboxes,numboxes);
        for j=1:numboxes
            ov(j,:) = getBoxOverlap_pedroNMS(boxes{i}(j,[1 3 2 4]), boxes{i}(:, [1 3 2 4]));
        end                                
                
        %{
        % compute feature
        x = zeros(numboxes,2*numcls);
        for j=1:numboxes
            for c=1:numcls                
                thisngramids = find(boxes{i}(:,5) == c);
                if ~isempty(thisngramids)
                    thisovs = ov{i}(j,thisngramids);
                    thisscores = boxes{i}(thisngramids, 6);
                    [~, ind] = max(thisovs);
                    x(j,2*c-1) = thisovs(ind);
                    x(j,2*c) = thisscores(ind);
                end
            end
        end
        %}
        % compute feature
        x = zeros(numboxes,4+(2*numcls));
        for j=1:numboxes
            x(j,1:4) = boxes{i}(j,1:4); % Normalize detection window coordinates
            x(j,1) = x(j,1) / s(2);
            x(j,2) = x(j,2) / s(1);
            x(j,3) = x(j,3) / s(2);
            x(j,4) = x(j,4) / s(1);            
            for c=1:numcls                
                thisngramids = find(boxes{i}(:,5) == c & ov(j,:)' > 0);
                if ~isempty(thisngramids)
                    thisovs = ov(j,thisngramids);
                    thisscores = boxes{i}(thisngramids, 6);
                    [~, ind] = max(thisscores);
                    x(j,4+(2*c-1)) = thisovs(ind);
                    x(j,4+(2*c)) = 1 ./ (1 + exp(-1.5*thisscores(ind)));
                end
            end
        end
        X{i} = x;
        %OVP{i} = ov;
    end
    myprintfn;
        
    save([cachedir 'context_data_' dataset '_' year], 'X', 'ds_all', 'OVP', 'boxes', '-v7.3');
    fprintf('done!\n');
end

catch
    disp(lasterr); keyboard;
end
