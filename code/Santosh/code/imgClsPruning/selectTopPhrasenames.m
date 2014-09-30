function [phrasenames, fimcls_cnt, ngram_cnt, phrasenames_orig] = selectTopPhrasenames(inpfname) %, accthresh1, accthresh2, freqthresh)

try
    
conf = voc_config('paths.model_dir', 'blah');
accthresh1 = conf.threshs.precCutOffThresh_fastImgClfrAcc1;
accthresh2 = conf.threshs.precCutOffThresh_fastImgClfrAcc2;
freqthresh = conf.threshs.freqCutOffThresh_fastImgCl;
maxNumToDwld = conf.threshs.maxNumNgramsToDwld;

[~, phrasenames] = system(['cat ' inpfname ' | gawk ''{NF--};1'' | gawk ''{NF--};1'' ']);
phrasenames = regexp(phrasenames, '\n', 'split');
phrasenames(cellfun('isempty', phrasenames)) = [];

[~, ngram_cnt2] = system(['cat ' inpfname ' | gawk ''{print $NF}'' ']);
ngram_cnt2 = regexp(ngram_cnt2, '\n', 'split');
ngram_cnt2(cellfun('isempty', ngram_cnt2)) = [];
ngram_cnt = sscanf(CStr2String(ngram_cnt2, '*'), '%f*');
ngram_cnt = ngram_cnt';

[~, fimcls_cnt2] = system(['cat ' inpfname ' | gawk ''{NF--};1'' | gawk ''{print $NF}'' ']);
fimcls_cnt2 = regexp(fimcls_cnt2, '\n', 'split');
fimcls_cnt2(cellfun('isempty', fimcls_cnt2)) = [];
fimcls_cnt = sscanf(CStr2String(fimcls_cnt2, '*'), '%f*');
fimcls_cnt = fimcls_cnt';

[svals, sinds] = sort(fimcls_cnt, 'descend');
fimcls_cnt = fimcls_cnt(sinds);
ngram_cnt = ngram_cnt(sinds);
phrasenames = phrasenames(sinds);

% pick ngrams above cut-off accthresh
%lastind = find(fimcls_cnt >= accthresh, 1, 'last');
%phrasenames = phrasenames(1:lastind);
%fimcls_cnt = fimcls_cnt(1:lastind);
%Ngram_cnt = ngram_cnt(1:lastind);
%listind = find(fimcls_cnt >= accthresh1 | (fimcls_cnt >= accthresh2 & ngram_cnt >= freqthresh));
if length(find(fimcls_cnt >= accthresh1)) > maxNumToDwld    % get at least all confident ones    
    disp([num2str(length(find(fimcls_cnt >= accthresh1))) ' => too many confident ones!']);
    listind = find(fimcls_cnt >= accthresh1);
else                                                        % if too many, then keep top ones only
    listind = find(fimcls_cnt >= accthresh1 | (fimcls_cnt >= accthresh2 & ngram_cnt >= freqthresh));
    if length(listind) > maxNumToDwld
        disp([num2str(length(listind)) ' => too many confident & unconfident ones, picking only top ' num2str(maxNumToDwld) ]);
        listind = listind(1:maxNumToDwld);
    end
end

phrasenames = phrasenames(listind);
fimcls_cnt = fimcls_cnt(listind);
ngram_cnt = ngram_cnt(listind);

phrasenames_orig = phrasenames;
for f=1:numel(phrasenames)
    phrasenames{f} = strrep(phrasenames{f}, ' ', '_');
end

disp(['Total of ' num2str(numel(phrasenames)) ' ngrams']);
 
catch
    disp(lasterr); keyboard;
end

%{
function [phrasenames, fimcls_cnt, ngram_cnt, phrasenames_orig] = selectTopPhrasenames(inpfname, accthresh)

try
    
[~, phrasenames] = system(['cat ' inpfname ' | gawk ''{NF--};1'' | gawk ''{NF--};1'' ']);
phrasenames = regexp(phrasenames, '\n', 'split');
phrasenames(cellfun('isempty', phrasenames)) = [];

[~, ngram_cnt2] = system(['cat ' inpfname ' | gawk ''{print $NF}'' ']);
ngram_cnt2 = regexp(ngram_cnt2, '\n', 'split');
ngram_cnt2(cellfun('isempty', ngram_cnt2)) = [];
ngram_cnt = sscanf(CStr2String(ngram_cnt2, '*'), '%f*');
ngram_cnt = ngram_cnt';

[~, fimcls_cnt2] = system(['cat ' inpfname ' | gawk ''{NF--};1'' | gawk ''{print $NF}'' ']);
fimcls_cnt2 = regexp(fimcls_cnt2, '\n', 'split');
fimcls_cnt2(cellfun('isempty', fimcls_cnt2)) = [];
fimcls_cnt = sscanf(CStr2String(fimcls_cnt2, '*'), '%f*');
fimcls_cnt = fimcls_cnt';

[svals, sinds] = sort(fimcls_cnt, 'descend');
fimcls_cnt = fimcls_cnt(sinds);
ngram_cnt = ngram_cnt(sinds);
phrasenames = phrasenames(sinds);

% pick ngrams above cut-off accthresh
lastind = find(fimcls_cnt >= accthresh, 1, 'last');
phrasenames = phrasenames(1:lastind);
fimcls_cnt = fimcls_cnt(1:lastind);
ngram_cnt = ngram_cnt(1:lastind);

phrasenames_orig = phrasenames;
for f=1:numel(phrasenames)
    phrasenames{f} = strrep(phrasenames{f}, ' ', '_');
end

catch
    disp(lasterr); keyboard;
end
%}
