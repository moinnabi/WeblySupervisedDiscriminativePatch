function orderNgramsUsingFastImgClRes(cachedir, inpfname, outfname1, outfname2, DO_MODE)
% orderNgramsUsingFastImgClRes('/projects/grail/santosh/objectNgrams/results/ngramPruning/bird/','/projects/grail/santosh/objectNgrams/results/object_ngram_data/bird/bird_0_all_uniquedNsort_rewrite.txt','/projects/grail/santosh/objectNgrams/results/object_ngram_data/bird/bird_0_all_fastICorder1.txt', '/projects/grail/santosh/objectNgrams/results/object_ngram_data/bird/bird_0_all_fastICorder2.txt')

try
    
accval_old = [];
ngram_uniq = [];
if DO_MODE == 1    
    disp('load data');
    [~, phrasenames] = system(['cat ' inpfname ' | gawk ''{NF--};1'' ']);
    phrasenames = regexp(phrasenames, '\n', 'split');
    phrasenames(cellfun('isempty', phrasenames)) = [];
    
    [~, ngram_cnt2] = system(['cat ' inpfname ' | gawk ''{print $NF}'' ']);
    ngram_cnt2 = regexp(ngram_cnt2, '\n', 'split');
    ngram_cnt2(cellfun('isempty', ngram_cnt2)) = [];    
    %ngram_cnt = zeros(numItems,1);
    %for i=1:numItems, ngram_cnt(i) = str2num(ngram_cnt2{i}); end
    ngram_cnt = sscanf(CStr2String(ngram_cnt2, '*'), '%f*');
    ngram_cnt = ngram_cnt';
    
    % after uniqifying in objectNgramData_2012.m, I rewrite data. so need
    % to uniqify again here
    disp('do unique');
    [phrasenames_uniq, ~, ib] = unique(phrasenames); 
    
    disp('add similar items ');
    ngram_uniq = accumarray(ib(:), ngram_cnt(:));
    
elseif DO_MODE == 2
    cutoffThresh = 10;
    [~, accval_old, ngram_uniq, phrasenames_uniq] = selectTopPhrasenames(inpfname, cutoffThresh);
    
elseif DO_MODE == 3
    [~, phrasenames] = system(['cat ' inpfname]);
    phrasenames = regexp(phrasenames, '\n', 'split');
    phrasenames(cellfun('isempty', phrasenames)) = [];
    phrasenames_uniq = phrasenames;
end

disp('load computed results');
prvals = zeros(numel(phrasenames_uniq), 1);
for i=1:numel(phrasenames_uniq)
    myprintf(i, 100);
    cls = strrep(phrasenames_uniq{i}, ' ', '_');
    try
        tmp = load([cachedir '/results/' cls '_result.mat'], 'pr');
        prvals(i) = tmp.pr.ap;
    catch
        disp(['couldnt load ' cls]);
    end
end

disp('write output file1');
[~, sind] = sort(prvals, 'descend');
fid = fopen(outfname1, 'w');
%fid3 = fopen(outfname3, 'w');
for i = 1:numel(phrasenames_uniq)
    if ~isempty(accval_old) && ~isempty(ngram_uniq)
        fprintf(fid, '%25s\t%2.1f\t%2.1f\t%d\n', phrasenames_uniq{sind(i)}, 100*prvals(sind(i)), accval_old(sind(i)), ngram_uniq(sind(i)));
    elseif ~isempty(ngram_uniq)
        fprintf(fid, '%25s\t%2.1f\t%d\n', phrasenames_uniq{sind(i)}, 100*prvals(sind(i)), ngram_uniq(sind(i)));
    else 
        fprintf(fid, '%25s\t%2.1f\n', phrasenames_uniq{sind(i)}, 100*prvals(sind(i)));
    end
    %fprintf(fid3, '%s\n', phrasenames_uniq{sind(i)});    
end
fclose(fid);
%fclose(fid3);

if ~isempty(ngram_uniq)
    disp('write output file2');
    [~, sind] = sort(ngram_uniq, 'descend');
    fid = fopen(outfname2, 'w');
    for i = 1:numel(phrasenames_uniq)
        fprintf(fid, '%25s\t%2.1f\t%d\n', phrasenames_uniq{sind(i)}, 100*prvals(sind(i)), ngram_uniq(sind(i)));
    end
    fclose(fid);
end

catch
    disp(lasterr); keyboard;
end
