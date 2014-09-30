function getAdjacencyMatrix_tensor(cachedir, phrasenames, data_year, datatype, doComp, numComp, modelname)

try    

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = data_year;
conf = voc_config('pascal.year', data_year);
cachedir = conf.paths.model_dir;

if nargin < 7
    modelname = '';
end

disp(['getAdjacencyMatrix(''' cachedir ''','' phrasenames '',''' data_year ''',''' datatype ''',''' num2str(doComp) ''',''' num2str(numComp)  ''',''' modelname ''')' ]);

ids = textread(sprintf(conf.pascal.VOCopts.imgsetpath, datatype), '%s');
numids = length(ids);
numcls = numel(phrasenames);

if isempty(modelname)
    fname = ['matrix_' datatype '_' data_year];
else
    fname = ['matrix_' datatype '_' data_year '_' modelname];
end

try
    load([cachedir '/' fname '.mat'], 'edgeval', 'ovlap');
    disp('  loaded pre computed adjacency matrix');
catch    
    disp(' getting top box per image info across all ngrams');
    ds_top = get_dstop(cachedir, datatype, data_year, phrasenames, conf, modelname);
    
    disp(' compute matrix');
    maxmatval = numids;
    if ~doComp
        disp(' doing detector level computations');
        edgeval = maxmatval*ones(numcls, numcls);
        ovlap = zeros(numcls, numcls);
        for c=1:numcls                      % for each ngram detector "c"
            myprintf(c,10);
            if ~isempty(ds_top{c})          % case when all boxes are unavaialble
                for j=1:numcls              % compute edges to all other ngram
                    if ~isempty(ds_top{j})  % case when all boxes are unavaialble
                        % get edge weight
                        thisinds_1 = ds_top{c}(:,end-1) == j | ds_top{c}(:,end-1) == 0; % list of images belonging to ngram j and background negs
                        thisinds = find(ds_top{c}(thisinds_1,end-1) == j);              % find rank of positives in the list
                        if numel(thisinds)>1, edgeval(c, j) = median(thisinds)/(numel(thisinds)/2); end     % compute normalized median rank
                        
                        % get overlap score
                        thisinds = find(ds_top{c}(:,end-1) == j);   % list of all images belonging to ngram j
                        if ~isempty(thisinds)
                            tmpovlap = zeros(numel(thisinds),1);
                            for jj=1:numel(thisinds)                % for each image i the list
                                gtruthboxid = find(ds_top{j}(:,end-4) == ds_top{c}(thisinds(jj),end-4));    % get its fake gtruth box (assigned by the ngram detector this image belongs to)
                                if length(gtruthboxid) == 1
                                    tmpovlap(jj) = getBoxOverlap2(ds_top{c}(thisinds(jj), :), ds_top{j}(gtruthboxid, :));
                                    %tmpovlap(jj) = getBoxOverlap_pedroNMS(ds_top{c}(thisinds(jj), [1 3 2 4]), ds_top{j}(gtruthboxid, [1 3 2 4]));
                                    %tmpovlap(jj) = getBoxOverlap_pedroNMS2(ds_top{c}(thisinds(jj), [1 3 2 4]), ds_top{j}(gtruthboxid, [1 3 2 4]));
                                    %tmpovlap(jj) = getBoxOverlap(ds_top{c}(thisinds(jj), [1 3 2 4]), ds_top{j}(gtruthboxid, [1 3 2 4]));
                                elseif length(gtruthboxid) > 1
                                    disp('multiple ids'); keyboard;
                                end
                            end
                            ovlap(c,j) = median(tmpovlap);
                        end
                    end
                end
            end
        end
        myprintfn;
    else
        disp(' doing component level computations');
        edgeval = maxmatval*ones(numcls, numcls, numComp, numComp);
        ovlap = zeros(numcls, numcls, numComp, numComp);
        for c=1:numcls
            myprintf(c,10);
            if ~isempty(ds_top{c})              % case when all boxes are unavaialble
                for ci=1:numComp
                    for j=1:numcls
                        if ~isempty(ds_top{j})  % case when all boxes are unavaialble
                            for ji=1:numComp
                                % get edge weight
                                thisinds_1 = find(ds_top{c}(:,end-3) == ci & ds_top{c}(:,end-1) == j & ds_top{c}(:,end-2) == ji |...
                                    ds_top{c}(:,end-1) == 0);
                                thisinds = find(ds_top{c}(thisinds_1,end-3) == ci & ds_top{c}(thisinds_1,end-1) == j & ds_top{c}(thisinds_1,end-2) == ji );
                                %if numel(thisinds)>1, edgeval((c-1)*numComp+ci, (j-1)*numComp+ji) = median(thisinds)/(numel(thisinds)/2); end
                                if numel(thisinds)>1, edgeval(c, j, ci, ji) = median(thisinds)/(numel(thisinds)/2); end
                                
                                % get overlap score
                                thisinds = find(ds_top{c}(:,end-3) == ci & ds_top{c}(:,end-1) == j & ds_top{c}(:,end-2) == ji);
                                if ~isempty(thisinds)
                                    tmpovlap = zeros(numel(thisinds),1);
                                    for jj=1:numel(thisinds)
                                        gtruthboxid = find(ds_top{j}(:,end-4) == ds_top{c}(thisinds(jj),end-4));
                                        if length(gtruthboxid) == 1
                                            tmpovlap(jj) = getBoxOverlap2(ds_top{c}(thisinds(jj), :), ds_top{j}(gtruthboxid, :));
                                        elseif length(gtruthboxid) > 1
                                            disp('multiple ids'); keyboard;
                                        end
                                    end
                                    ovlap(c, j, ci, ji) = median(tmpovlap);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    save([cachedir '/' fname '.mat'], 'edgeval', 'ovlap');
end

catch
    disp(lasterr); keyboard;
end
