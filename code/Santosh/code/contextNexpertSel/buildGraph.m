function buildGraph(cachedir, phrasenames, phrasenames_disp, data_year, datatype)

try    

global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = data_year;
conf = voc_config('pascal.year', data_year);
cachedir = conf.paths.model_dir;
VOCopts  = conf.pascal.VOCopts;

algotype = 'aliRank';   %'santoshEntr'
doComp = 1

disp(['buildGraph(''' cachedir ''','' phrasenames '',''' data_year ''',''' datatype ''',''' algotype ''',''' num2str(doComp) ''')' ]);

numcls = numel(phrasenames);

ids = textread(sprintf(VOCopts.imgsetpath, datatype), '%s');
numids = length(ids);
numComp = 6;

fname = ['graph_' algotype '_' num2str(doComp) '_' datatype '_' data_year];

if doComp
    cphrasenames = cell(numcls*numComp,1);
    cphrasenames_disp = cell(numcls*numComp,1);
    for c=1:numcls
        for ck=1:numComp
            cphrasenames{(c-1)*numComp+ck} = [num2str(ck) '_' phrasenames{c}];
            cphrasenames_disp{(c-1)*numComp+ck} = [num2str(ck) '_' phrasenames_disp{c}];
        end
    end
end

disp(' get boxes');
[ds_all, bs_all] = getBoxes_helper(cachedir, datatype, data_year, phrasenames);

disp(' include info abt dataset');
dinds = zeros(numids,1);
dcinds = zeros(numids,1);
for i=1:numcls
    myprintf(i, 10);
    if strcmp(datatype, 'val1')
        [thisids, tgt] = textread(sprintf(conf.pascal.VOCopts.clsimgsetpath, phrasenames{i}, 'train'), '%s %d');
        thisids = thisids(tgt == 1);
    elseif strcmp(datatype, 'val2')
        [thisids, tgt] = textread(sprintf(conf.pascal.VOCopts.clsimgsetpath, phrasenames{i}, 'test'), '%s %d');
        thisids = thisids(tgt == 1);
    end
    iset = find(doStringMatch(ids, thisids));
    if any(dinds(iset))
        error('multiple matches');
    else
        dinds(iset) = i;
    end
    for j=1:numel(iset)
        if ~isempty(bs_all{i}{iset(j)})
            dcinds(iset(j)) = bs_all{i}{iset(j)}(1,end-1);
        end
    end
end
myprintfn;

disp(' keep top box');
ds_top = cell(numcls,1);
for c=1:numcls
    myprintf(c,10);
    ds_top{c} = -10*ones(numids,size(cat(1,ds_all{1}{:}),2)+4);
    for i=1:numids
        if ~isempty(ds_all{c}{i})
            ds_top{c}(i,:) = [ds_all{c}{i}(1,1:end-1) i bs_all{c}{i}(1,end-1) dcinds(i) dinds(i) ds_all{c}{i}(1,end)];
        end
    end
    [~, sind] = sort(ds_top{c}(:,end), 'descend');
    ds_top{c} = ds_top{c}(sind,:);
end
myprintfn;

%disp([' merge detections ']);
%[ds, bs] = mergeBoxes_helper(numids, ds_all, bs_all);

maxmatval = numids;
disp(' build graph');
if doComp    
    %{
    edgeval = maxmatval*ones(numcls*numComp, numcls*numComp);
    for c=1:numcls          % for each ngram
        myprintf(c,10);
        for cj=1:numComp
            for j=1:numcls  % get the rank of all other ngram
                for jj=1:numComp
                    if strcmp(algotype, 'santosh')
                        thisinds = [ds_top{c}(:,end-3) == cj & ds_top{c}(:,end-1) == j & ds_top{c}(:,end-2) == jj];
                        edgeval((c-1)*numComp+cj, (j-1)*numComp+jj) = mean(ds_top{c}(thisinds,end));
                    elseif strcmp(algotype, 'aliRank')
                        thisinds = find(ds_top{c}(:,end-3) == cj & ds_top{c}(:,end-1) == j & ds_top{c}(:,end-2) == jj);
                        if numel(thisinds)>1, edgeval((c-1)*numComp+cj, (j-1)*numComp+jj) = mean(thisinds); end
                    end
                end
            end
        end
        if strcmp(algotype, 'santosh')
            edgeval(c,:) = (edgeval(c,:) - min(edgeval(c,:))) / (max(edgeval(c,:)) - min(edgeval(c,:)));   % first get between [0 1]
            %edgeval(c,:) = edgeval(c,:)/sum(edgeval(c,:));  % then normalize
        end
    end
    myprintfn;        
    %}
    edgeval = maxmatval*ones(numcls*numComp, numcls);
    for c=1:numcls          % for each ngram
        myprintf(c,10);
        for cj=1:numComp
            for j=1:numcls  % get the rank of all other ngram                
                if strcmp(algotype, 'santosh')
                    thisinds = [ds_top{c}(:,end-3) == cj & ds_top{c}(:,end-1) == j & ds_top{c}(:,end-2) == jj];
                    edgeval((c-1)*numComp+cj, (j-1)*numComp+jj) = mean(ds_top{c}(thisinds,end));
                elseif strcmp(algotype, 'aliRank')
                    thisinds = find(ds_top{c}(:,end-3) == cj & ds_top{c}(:,end-1) == j);
                    if numel(thisinds)>1, edgeval((c-1)*numComp+cj, j) = mean(thisinds); end
                end
            end
        end
        if strcmp(algotype, 'santosh')
            edgeval(c,:) = (edgeval(c,:) - min(edgeval(c,:))) / (max(edgeval(c,:)) - min(edgeval(c,:)));   % first get between [0 1]
            %edgeval(c,:) = edgeval(c,:)/sum(edgeval(c,:));  % then normalize
        end
    end
    myprintfn;        
else
    edgeval = maxmatval*ones(numcls, numcls);
    for c=1:numcls          % for each ngram
        myprintf(c,10);
        for j=1:numcls      % get the rank of all other ngram
            if strcmp(algotype, 'santosh')
                thisinds = [ds_top{c}(:,end-1) == j];
                edgeval(c, j) = mean(ds_top{c}(thisinds,end));
            elseif strcmp(algotype, 'aliRank')
                thisinds = find(ds_top{c}(:,end-1) == j);
                if ~isempty(thisinds), edgeval(c, j) = mean(thisinds); end
            end
        end
        
        if strcmp(algotype, 'santosh')
            edgeval(c,:) = (edgeval(c,:) - min(edgeval(c,:))) / (max(edgeval(c,:)) - min(edgeval(c,:)));   % first get between [0 1]
            %edgeval(c,:) = edgeval(c,:)/sum(edgeval(c,:));  % then normalize
        end
    end
    myprintfn;
end

% make it symmetric
edgeval_unsym = edgeval;
%edgeval = edgeval_unsym + edgeval_unsym';

%{
edgeval_unsym2 = zeros(numel(cphrasenames), numel(phrasenames));
for i=1:numel(phrasenames)
    edgeval_unsym2(:,i) = sum(edgeval_unsym(:,((i-1)*numComp)+1:i*numComp), 2);
end
%}
    
disp(' find phrase order');
entr = zeros(size(edgeval,1),1);
for c=1:size(edgeval,1)
    %pv = edgeval(c,:);
    entr(c) = myEntropy(edgeval_unsym(c,:)); %-sum(pv.*log2(pv));
end
[~, phraseorder_entr] = sort(entr, 'descend');
[~, phraseorder_sumasym] = sort(sum(edgeval_unsym, 2), 'ascend');
[~, phraseorder_sum] = sort(sum(edgeval, 2), 'ascend');

disp('25');
sumval = zeros(size(edgeval,1),1);
for i=1:size(edgeval,1)
    %thisinds = find(edgeval_unsym(i,:) < numids);    
    %if ~isempty(thisinds), sumval(i) = sum(edgeval_unsym(i,thisinds))/length(thisinds);
    %else sumval(i) = maxmatval; end
    [sval sind] = sort(edgeval_unsym(i,:), 'ascend');
    sumval(i) = mean(edgeval_unsym(i,sind(1:25)));
end
[~, phraseorder_sum2] = sort(sumval, 'ascend');
phraseorder = phraseorder_sum2;

disp(' find phrasethreshs');
precatk = [100 200 300 500 1000];
phrasethreshs = 10*ones(size(edgeval,1),numel(precatk));
for c=1:numcls          % for each ngram
    myprintf(c,10);    
    for j=1:numel(precatk)
        if doComp
            for ck=1:numComp
                arrind = find(ds_top{c}(1:precatk(j),end-3) == ck & ds_top{c}(1:precatk(j),end-1) == c,1,'last');
                if ~isempty(arrind), phrasethreshs((c-1)*numComp+ck, j) = ds_top{c}(arrind, end); end
            end            
        else
            arrind = find(ds_top{c}(1:precatk(j),end-1) == c,1,'last');
            if ~isempty(arrind), phrasethreshs(c, j) = ds_top{c}(arrind, end); end
        end                
    end    
end

% load sigmoid params needed for doExpertSel_test
load([cachedir '/sigmoid.mat'], 'sigparams');

if 1
    if 0
        % binary symmetric
        d=edgeval;
        sd = sort(d(:));
        thresh = sd(max(1,round(.1*length(sd))));
        A = d<thresh;
        A = A&A';
        
        params = sexy_graph_params(A);
        %params.node_names = phrasenames;
        params.sfdp_coloring = 1;
        params.tmpdir = cachedir;
        params.file_prefix = fname;
        sexy_graph(A,'',params);        
    elseif 0
        % binary asymmetric
        d=edgeval_unsym;
        sd = sort(d(:));
        thresh = sd(max(1,round(.05*length(sd))));
        A = d<thresh;
        
        params = sexy_graph_params(A);
        %params.node_names = phrasenames;
        params.sfdp_coloring = 1;
        params.tmpdir = cachedir;
        params.file_prefix = fname;
        sexy_graph_asym(A,'',params);
    elseif 1                
        if doComp
            dispmat = zeros(numel(phrasenames), numel(phrasenames));
            for i=1:numel(phrasenames)
                dispmat(i,:) = min(edgeval_unsym(((i-1)*numComp)+1:i*numComp, :));
            end
        else
            dispmat = edgeval_unsym;
        end
        
        % asymmetric
        d=dispmat;
        sd = sort(d(:));
        thresh = sd(max(1,round(.05*length(sd))));
        %thresh = sd(1000);
        A = normalise(dispmat,2).*(d<thresh);
        
        params = sexy_graph_params(A);
                       
        params.sfdp_coloring = 1;
        params.tmpdir = cachedir;
        params.file_prefix = fname;
        %params.node_names = getPhraseIconImages(phrasenames, VOCopts);        
        if doComp
            %params.node_names = cphrasenames_disp;
            params.node_names = phrasenames_disp;
        else
            params.node_names = phrasenames_disp; 
        end
        
        %sexy_graph_asym(A,'',params);
        sexy_graph_asym_img(A,'',params);
    end
end

disp('done'); keyboard;

save([cachedir '/' fname '.mat'], 'edgeval', 'edgeval_unsym', 'phraseorder', 'phrasethreshs', ...
    'phraseorder_entr', 'phraseorder_sumasym', 'phraseorder_sum', 'sigparams');

catch
    disp(lasterr); keyboard;
end
