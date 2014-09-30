function getAdjacencyMatrix_noTensor(cachedir, phrasenames, data_year, datatype, doComp, numComp, modelname, objname)
% this version is before edgeval for comp became a tensor

try    

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = data_year;
conf = voc_config('pascal.year', data_year);
cachedir = conf.paths.model_dir;

disp(['getAdjacencyMatrix_noTensor(''' cachedir ''','' phrasenames '',''' data_year ''',''' datatype ''',''' num2str(doComp) ''',''' num2str(numComp)  ''',''' modelname ''',''' objname ''')' ]);

ids = textread([conf.pascal.VOCopts.imgsetpath(1:end-6) '/baseobjectcategory_' objname '_' datatype '.txt'], '%s');
numids = length(ids);
numcls = numel(phrasenames);

mymkdir([cachedir '/matrix']);
if isempty(modelname)
    fname = ['matrix_' datatype '_' data_year];
else
    fname = ['matrix_' datatype '_' data_year '_' modelname];
end

try
    load([cachedir '/' fname '.mat'], 'edgeval', 'ovlap');
    disp('  loaded pre computed adjacency matrix');
catch    
    
    mymatlabpoolopen;

    disp(' getting top box per image info across all ngrams');
    ds_top = get_dstop(cachedir, datatype, data_year, phrasenames, conf, modelname, objname);
    
    disp(' compute matrix');
    maxmatval = numids;
    if ~doComp
        disp(' doing detector level computations');
        edgeval = maxmatval*ones(numcls, numcls);
        ovlap = zeros(numcls, numcls);
        parfor c=1:numcls                       % for each ngram detector "c"
            myprintf(c,10);
            if ~isempty(ds_top{c})              % case when all boxes are unavaialble
                for j=1:numcls                  % compute edges to all other ngram
                    if ~isempty(ds_top{j})      % case when all boxes are unavaialble
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
        edgeval = maxmatval*ones(numcls*numComp, numcls*numComp);
        ovlap = zeros(numcls*numComp, numcls*numComp);
        tmp = load([cachedir '/allGoodCompInfo.mat'], 'allGoodCompInfo');
        allGoodCompInfo = tmp.allGoodCompInfo;
        %edgeval_cell = cell(numcls, numComp, numcls, numComp); 
        %ovlap_cell = cell(numcls, numComp, numcls, numComp);
        %[edgeval_cell{:}] = deal(maxmatval); %[ovlap_cell{:}] = deal(0);
        for c=1:numcls  
            myprintf(c);
            dstopc = ds_top{c};
            if ~isempty(dstopc)                     % case when all boxes are unavaialble
                for ci=1:numComp
                    edgeval_tmp = maxmatval*ones(numcls, numComp);
                    ovlap_tmp = zeros(numcls, numComp);
                    if allGoodCompInfo{c}(ci) == 1
                        parfor j=1:numcls
                            if ~isempty(ds_top{j})  % case when all boxes are unavaialble
                                for ji=1:numComp
                                    if allGoodCompInfo{j}(ji) == 1
                                        % get edge weight
                                        thisinds_1 = find(dstopc(:,end-3) == ci & dstopc(:,end-1) == j & dstopc(:,end-2) == ji |...
                                            dstopc(:,end-1) == 0);
                                        thisinds = find(dstopc(thisinds_1,end-3) == ci & dstopc(thisinds_1,end-1) == j & dstopc(thisinds_1,end-2) == ji );
                                        %if numel(thisinds)>1, edgeval((c-1)*numComp+ci, (j-1)*numComp+ji) = median(thisinds)/(numel(thisinds)/2); end
                                        if numel(thisinds)>1, edgeval_tmp(j,ji) = median(thisinds)/(numel(thisinds)/2); end
                                        
                                        % get overlap score
                                        thisinds = find(dstopc(:,end-3) == ci & dstopc(:,end-1) == j & dstopc(:,end-2) == ji);
                                        if ~isempty(thisinds)
                                            tmpovlap = zeros(numel(thisinds),1);
                                            for jj=1:numel(thisinds)
                                                gtruthboxid = find(ds_top{j}(:,end-4) == dstopc(thisinds(jj),end-4));
                                                if length(gtruthboxid) == 1
                                                    tmpovlap(jj) = getBoxOverlap2(dstopc(thisinds(jj), :), ds_top{j}(gtruthboxid, :));
                                                elseif length(gtruthboxid) > 1
                                                    disp('multiple ids'); keyboard;
                                                end
                                            end
                                            %ovlap((c-1)*numComp+ci, (j-1)*numComp+ji) = median(tmpovlap);
                                            ovlap_tmp(j,ji) = median(tmpovlap);
                                        end
                                    end
                                end
                            end
                        end
                    end
                    save([cachedir '/matrix/value_' num2str(c) '_' num2str(ci) '.mat'], 'edgeval_tmp', 'ovlap_tmp');
                end
            end
        end 
        myprintfn;
        
        for c=1:numcls
            myprintf(c,10);
            for ci=1:numComp
                load([cachedir '/matrix/value_' num2str(c) '_' num2str(ci) '.mat'], 'edgeval_tmp', 'ovlap_tmp');
                for j=1:numcls
                    for ji=1:numComp
                        edgeval((c-1)*numComp+ci, (j-1)*numComp+ji) =  edgeval_tmp(j,ji);
                        ovlap((c-1)*numComp+ci, (j-1)*numComp+ji) = ovlap_tmp(j,ji);
                    end
                end
            end
        end                                                                                                        
    end
    myprintfn;
    
    save([cachedir '/' fname '.mat'], 'edgeval', 'ovlap');
    
    try matlabpool('close', 'force'); end
end

catch
    disp(lasterr); keyboard;
end
