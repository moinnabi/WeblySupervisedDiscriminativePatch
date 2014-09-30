function getDiverseNgrams_fastImgCl(cachedir, outfname, outfname1, outfname2, accfname)

try    
    
disp(['getDiverseNgrams_fastImgCl(''' cachedir ''',''' outfname ''',''' outfname2 ''',''' accfname   ''')']);

conf = voc_config('paths.model_dir', 'blah');
rankThresh = conf.threshs.rankThresh_fastImgClfrAcc;
domode = conf.threshs.featExtMode_imgClfr;

load([cachedir '/edgematrix.mat'], 'edgeval');
if domode == 1, [phrasenames, accval, ngramval, phrasenames_orig] = selectTopPhrasenames(accfname);
elseif domode == 2, [phrasenames, accval, ngramval] = selectTopPhrasenames_slow(accfname); end
numcls = numel(phrasenames);

DISP = 0;
if DISP
    % binary asymmetric
    d=edgeval/max(edgeval(:));      % need to have values between 0 & 1, otherwise graph appears very tiny
    sd = sort(d(:));
    thresh = sd(max(1,round(.005*length(sd))));  % make it sparse for easier visualization
    A = (d<thresh) .* d;
    
    params = sexy_graph_params(A);
    params.sfdp_coloring = 1;
    params.tmpdir = cachedir;    
    params.node_names = phrasenames;
    sexy_graph_asym_img(A,'',params);
end

% assume nodes are already sorted by their fast Img Cl scores
% for each node (in sorted order), pick all other nodes that it 'likes'
% i.e., gives high classification accuracy/low rank, and remove those nodes
% i.e., merge them with this node; now amongst the remaining nodes repeat
% the above process

disp(' update the matrix such that edgeval(i,j) has score at least as much as  edgeval(j,j) ');
dmat = edgeval;
for j=1:size(edgeval,1)
    inds = find(dmat(:,j) < dmat(j,j));  
    dmat(inds, j) = dmat(j,j);
    
    inds = find(dmat(j,:) < dmat(j,j));
    dmat(j, inds) = dmat(j,j);
end

disp(' finding similar nodes');
if 0        
    cluster_label = bottom_up_clustering(dmat, rankThresh);     %%apcluster1
    simNodes = cell(size(edgeval,1), 1);
    for i=1:length(cluster_label)
        simNodes{i} = find(cluster_label == i);
    end
else    
    offsetThresh = rankThresh;    
    simNodes = cell(size(edgeval,1), 1);
    remNodes = 1:size(edgeval,1);
    while ~isempty(remNodes)
        pickNode = remNodes(1);
        fprintf('%d ', pickNode);
        %likeNodes = find(dmat(pickNode, remNodes) < rankThresh);        
        %likeNodes = find([dmat(remNodes, pickNode) < rankThresh] & [dmat(pickNode, remNodes)' < rankThresh]);      % find bidirectional edges of high similarity
        likeNodes = find(...
            [dmat(remNodes, pickNode) < max(rankThresh, dmat(pickNode, pickNode) + offsetThresh)] & ...
            [dmat(pickNode, remNodes)' < max(rankThresh, diag(dmat(remNodes, remNodes)) + offsetThresh)]);
        if isempty(find(likeNodes==1, 1))
            if ~isempty(likeNodes), disp('here'); keyboard; end
            likeNodes = [1 likeNodes];
        end
        %likeNodes = remNodes(likeNodes);
        simNodes{pickNode} = remNodes(likeNodes);
        remNodes(likeNodes) = [];
    end
    myprintfn;
end

disp(' sort simNodes within based on dmat values');
for i=1:numel(simNodes)
    if length(simNodes{i}) >= 1
        sumval = zeros(length(simNodes{i}),1);
        for jj=1:length(simNodes{i})
            if length(simNodes{i}) > 3                  % sort based on edge strength
                sumval(jj) = sum(dmat(simNodes{i}(jj), simNodes{i}(:)));
            else                                        % sort based on accuracies (based on observation of results on horses)
                sumval(jj) = -accval(simNodes{i}(jj));  % "-" becausse i am sorting "ascending" order
            end
        end
        [~, sind] = sort(sumval, 'ascend');
        simNodes{i} = simNodes{i}(sind);        
    end
end

disp(' print info for reference/debugging');
fid = fopen(outfname1, 'w');
k = 1;
for i=1:numcls
    if length(simNodes{i}) >= 1
        fprintf(fid, '%d (%2.1f,%d)::', k, accval(i), ngramval(i));
        for j=1:length(simNodes{i})
            fprintf(fid, '%s,%2.1f ', phrasenames{simNodes{i}(j)}, accval(simNodes{i}(j)));            
        end
        fprintf(fid, '\n\n');
        k = k+ 1;
    end
end
fclose(fid);

disp(' print list for dwonload');
fid = fopen(outfname, 'w');
for i=1:numcls
    if length(simNodes{i}) >= 1                
        fprintf(fid, '%s\n', phrasenames_orig{simNodes{i}(1)});        
    end
end
fprintf(fid, '\n');
fclose(fid);

save(outfname2, 'phrasenames', 'simNodes');

catch
    disp(lasterr); keyboard;
end
