function getPopularNounsFromNgramData_2012(ngramtype, indir, outdir)

try
    
if isdeployed, ngramtype = str2num(ngramtype); end

mymatlabpoolopen; 

tmpdir = [outdir '/tempFiles_' num2str(ngramtype) '/'];
mymkdir(tmpdir);

conf = voc_config('paths.model_dir', 'blah');
minNgramCnt = conf.threshs.minNgramFreqInBooks;

savename = [outdir '/' num2str(ngramtype) '_all_popular.txt'];
savename4 = [outdir '/' num2str(ngramtype) '_all_popular_uniquedNsort_rewrite.txt'];
savename3 = [outdir '/' num2str(ngramtype) '_all_popular_uniquedNsort_rewrite_tmp.txt'];
savename2 = [outdir '/' num2str(ngramtype) '_all_popular_uniquedNsort.txt'];
savename1 = [outdir '/' num2str(ngramtype) '_all_popular_wrkng.txt'];
if exist(savename1, 'file'), delete(savename1); end

disp([' searching ngram data for all popular nouns']);

numNgramFiles = ngramGoogFileInfo(ngramtype);
parfor f=1:numNgramFiles
    disp(f);
    savename_tmp = [tmpdir '/' num2str(ngramtype) '_tmp_' num2str(f) '.txt'];
    if ~exist(savename_tmp, 'file')
        inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' getfcode_forngram(ngramtype, f)];
        if exist(inpfname,'file')
            if ngramtype == 0
                filenameWithPath = which('getPopularNgrams_2012.sh');   %'/projects/grail/santosh/objectNgrams/code/ngram/getPopularNgrams_2012.sh'
                system([filenameWithPath ' ' ...
                    inpfname ' '  num2str(ngramtype) ' ' savename_tmp]);
            end
        end
    end
end
myprintfn;

for f=1:numNgramFiles           % cant parfor this as appending to file
    myprintf(f);
    savename_tmp = [tmpdir '/' num2str(ngramtype) '_tmp_' num2str(f) '.txt'];
    inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' getfcode_forngram(ngramtype, f)];
    if exist(inpfname,'file')
        system(['cat ' savename_tmp ' >> ' savename1]);
    end
end
myprintfn;

system(['mv ' savename1 ' ' savename]);

disp(' uniquify ngram data');
merge2345ngram_topData(minNgramCnt, 2012, savename, savename2);

disp(' rewrting 1. without PoS info');
if ngramtype == 0
    filenameWithPath = which('rewriteNgramdata_2012_forPopularNgrams.sh');  %'/projects/grail/santosh/objectNgrams/code/ngram/rewriteNgramdata_2012_forPopularNgrams.sh' 
    system([filenameWithPath ' ' ...
        savename2 ' ' savename3]);
end
merge2345ngram_topData(minNgramCnt, 2012, savename3, savename4);

try matlabpool('close', 'force'); end
    
catch    
    disp(lasterr); keyboard;
end
