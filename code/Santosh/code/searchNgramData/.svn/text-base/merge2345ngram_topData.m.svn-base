function merge2345ngram_topData(minCount, domode, inpfname, outfname)

try

if domode == 2009
    %{
    savename1 = [objngramdir '/' objname '_2345_all.txt'];
    fname1 = [];
    ngramtype = 2;
    fname1{ngramtype} = [objngramdir '/' objname '_' num2str(ngramtype) '_all.txt'];
    ngramtype = 3;
    fname1{ngramtype} = [objngramdir '/' objname '_' num2str(ngramtype) '_all.txt'];
    ngramtype = 4;
    fname1{ngramtype} = [objngramdir '/' objname '_' num2str(ngramtype) '_all.txt'];
    ngramtype = 5;
    fname1{ngramtype} = [objngramdir '/' objname '_' num2str(ngramtype) '_all.txt'];
    disp('catting 2 3 4 5');
    [~, b] = system(['cat ' fname1{2} ' ' fname1{3} ' ' fname1{4} ' ' fname1{5} ' > ' savename1]);
    savename2 = [objngramdir '/' objname '_2345_all_uniquedNsort.txt'];
    savename2mat = [objngramdir '/' objname '_2345_all_uniquedNsort.mat'];
    %}
elseif domode == 2012
    %inpfname = [objngramdir '/' objname '_0_all.txt'];
    %savename2 = [objngramdir '/' objname '_0_all_uniquedNsort.txt'];
    %savename2mat = [objngramdir '/' objname '_0_all_uniquedNsort.mat'];
    savename2 = outfname;
    savename2mat = [outfname(1:end-4) '.mat'];
end

if ~exist(savename2, 'file')
    disp('  gettings strings and conts');
    
    [~, ngstrings] = system(['cat ' inpfname ' | gawk ''{NF--};1'' ']);
    [~, ngcnts] = system(['cat ' inpfname ' | gawk ''{print $NF}'' ']);
    
    ngstrings = regexp(ngstrings, '\n', 'split');
    ngcnts = regexp(ngcnts, '\n', 'split');
    
    ngstrings(cellfun('isempty', ngstrings)) = [];
    ngcnts(cellfun('isempty', ngcnts)) = [];
    if length(ngstrings) ~= length(ngcnts), disp('dim mismatch'); keyboard; end    
    %%% get rid of null entry at the end
    %ngstrings = ngstrings(1:end-1);
    %ngcnts = ngcnts(1:end-1);    
    
    disp('  converting counts to mat');
    ngcnts_mat = sscanf(CStr2String(ngcnts, '*'), '%f*');
    ngcnts_mat = ngcnts_mat';
    %{
    numitems = numel(ngcnts);
    ngcnts_mat = zeros(1,numitems);
    for i=1:numitems, ngcnts_mat(i) = str2num(ngcnts{i}); end
    %}
    
    disp('  do unique');
    [ngstrings_uniq, ~, ib] = unique(ngstrings);
    
    disp('  add similar items ');           
    ngcnts_uniq = accumarray(ib(:), ngcnts_mat(:));
    %repmat(ib, [numitems_uniq 1]) == repmat([1:numitems_uniq], [1 numitems])   % too much memory
    %{
    %%% too slow
    numitems_uniq = numel(ngstrings_uniq);
    ngcnts_uniq = zeros(numitems_uniq,1);
    for i=1:numitems_uniq
        myprintf(i, 1000);
        ngcnts_uniq(i) = sum(ngcnts_mat(ib == i));
        %%ngcnts_uniq(i) = sum(ngcnts_mat .* ib == i);  % sme issue 
    end
    myprintfn;
    %}    
    
    disp('  sort data');
    [sval, sind] = sort(ngcnts_uniq, 'descend');
    ngcnts_uniq = ngcnts_uniq(sind);
    ngstrings_uniq = ngstrings_uniq(sind);    
    cutoffInd = find(sval > minCount, 1, 'last');           % pick items that appears at least minCount (=100) times    
    ngcnts_uniq = ngcnts_uniq(1:cutoffInd);
    ngstrings_uniq = ngstrings_uniq(1:cutoffInd);
      
    disp('  write to file and save as mat');
    fid = fopen(savename2, 'w');
    for i = 1:length(ngstrings_uniq);
        fprintf(fid, '%s %d\n', ngstrings_uniq{i}, ngcnts_uniq(i));
    end
    fclose(fid);    
    save(savename2mat, 'ngstrings_uniq', 'ngcnts_uniq');
end

catch
    disp(lasterr); keyboard;
end
