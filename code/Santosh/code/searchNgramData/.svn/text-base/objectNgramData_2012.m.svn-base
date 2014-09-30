function objectNgramData_2012(ngramtype, objname, indir, outdir, savename_final, posname)

try
    
if isdeployed, ngramtype = str2num(ngramtype); end

mymatlabpoolopen; 

tmpdir = [outdir '/tempFiles_' num2str(ngramtype) '/'];
mymkdir(tmpdir);

conf = voc_config('paths.model_dir', 'blah');
minNgramCnt = conf.threshs.minNgramFreqInBooks;

objname_plural = getPlural(objname);

objname_syns = getObjectSynonyms(objname);

if ~exist(savename_final, 'file')    
    for ij = 1:numel(objname_syns)        
        thisobjname = objname_syns{ij};
        savename = [outdir '/' thisobjname '_' num2str(ngramtype) '_all_syn.txt'];
        savename3 = [outdir '/' thisobjname '_' num2str(ngramtype) '_all_syn_uniquedNsort_rewrite.txt'];
        savename2 = [outdir '/' thisobjname '_' num2str(ngramtype) '_all_syn_uniquedNsort.txt'];        
        savename1 = [outdir '/' thisobjname '_' num2str(ngramtype) '_all_syn_wrkng.txt'];
        if exist(savename1, 'file'), delete(savename1); end
               
        disp([' searching ngram data ' thisobjname]);
                        
        numNgramFiles = ngramGoogFileInfo(ngramtype);        
        parfor f=1:numNgramFiles
            disp(f);
            savename_tmp = [tmpdir '/' thisobjname '_' num2str(ngramtype) '_tmp_' num2str(f) '.txt'];
            if ~exist(savename_tmp, 'file')
                inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' getfcode_forngram(ngramtype, f)];
                if exist(inpfname,'file')                    
                    if ngramtype == 0                         
                        filenameWithPath = which('fetchNgramdata_2012.sh');    % avoids hardcoding filepath ('/projects/grail/santosh/objectNgrams/code/ngram/fetchNgramdata_2012.sh')
                        system([filenameWithPath ' ' ...
                            thisobjname ' ' inpfname ' '  num2str(ngramtype) ' ' posname ' ' savename_tmp]);
                    elseif ngramtype == 2 || ngramtype == 3 || ngramtype == 4 || ngramtype == 5
                        filenameWithPath = which('fetchNgramdata_2012_2345.sh'); % '/projects/grail/santosh/objectNgrams/code/ngram/fetchNgramdata_2012_2345.sh'
                        system([filenameWithPath ' ' ...
                            thisobjname ' ' inpfname ' '  num2str(ngramtype) ' ' objname_plural ' ' savename_tmp]);
                    end
                end
            end
        end
        myprintfn;
        
        for f=1:numNgramFiles           % cant parfor this as appending to file
            myprintf(f);
            savename_tmp = [tmpdir '/' thisobjname '_' num2str(ngramtype) '_tmp_' num2str(f) '.txt'];
            inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' getfcode_forngram(ngramtype, f)]; 
            if exist(inpfname,'file')
                system(['cat ' savename_tmp ' >> ' savename1]);
            end
        end
        myprintfn;
        
        system(['mv ' savename1 ' ' savename]);
        
        disp(' uniquify ngram data');
        merge2345ngram_topData(minNgramCnt, 2012, savename, savename2);
        
        %disp(' rewrting 1. without PoS info 2. strict word (car insted of vicar) 3. X horse (instead of horse X)');
        disp(' rewrting 1. without PoS info 2. strict word (car insted of vicar)');    
        if ngramtype == 0
            filenameWithPath = which('rewriteNgramdata_2012.sh');   %'/projects/grail/santosh/objectNgrams/code/ngram/rewriteNgramdata_2012.sh'
            system([filenameWithPath ' ' ...
                savename2 ' ' savename3 ' ' lower(thisobjname)]);   % added lower while running 'Tehran' (objname might be capital during search but here capital is not needed as it has already been lowercased in fetchNgramData.sh
        elseif ngramtype == 2 || ngramtype == 3 || ngramtype == 4 || ngramtype == 5  
            filenameWithPath = which('rewriteNgramdata_2012.sh');   %/projects/grail/santosh/objectNgrams/code/ngram/rewriteNgramdata_2012_2345.sh'
            system([filenameWithPath ' ' ...
                savename2 ' ' savename3 ' ' lower(thisobjname)]);
        end
    end  
    
    disp('combining all synonym data');
    for ij = 1:numel(objname_syns)           % cant parfor this as appending to file
        myprintf(ij);
        thisobjname = objname_syns{ij};
        savename_tmp = [outdir '/' thisobjname '_' num2str(ngramtype) '_all_syn_uniquedNsort_rewrite.txt'];
        system(['cat ' savename_tmp ' >> ' savename_final]);
    end
    myprintfn;
    
    [~, numofngrams] = system(['wc -l ' savename_final ' | gawk ''{NF--};1'' ']);
    disp(['Got a total of ' numofngrams(1:end-1) ' ngrams']);
end

try matlabpool('close', 'force'); end
    
catch    
    disp(lasterr); keyboard;
end
   
 %{
    numNgramFiles = ngramGoogFileInfo(ngramtype);
    for f=1:numNgramFiles           % cant parfor this as appending to file
        myprintf(f);        
        if exist(savename_tmp, 'file'), delete(savename_tmp); end
        inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' getfcode_forzerogram(f)];        
        system(['/projects/grail/santosh/objectNgrams/code/ngram/fetchNgramdata_2012.sh' ' ' ...
            objname ' ' inpfname ' '  num2str(ngramtype) ' ' objname_plural ' ' savename_tmp]);
        system(['cat ' savename_tmp ' >> ' savename1]);
    end        
    myprintfn;
    %}

%{
function objectNgramData_2012(ngramtype, objname, indir, outdir)

try
    
if isdeployed, ngramtype = str2num(ngramtype); end

mymatlabpoolopen; 

conf = voc_config('paths.model_dir', 'blah');
minNgramCnt = conf.threshs.minNgramFreqInBooks;

objname_plural = getPlural(objname);

objname_syns = getSynonyms(objname);

savename = [outdir '/' objname '_' num2str(ngramtype) '_all.txt'];
savename1 = [outdir '/' objname '_' num2str(ngramtype) '_all_wrkng.txt'];
savename2 = [outdir '/' objname '_' num2str(ngramtype) '_all_uniquedNsort.txt'];
savename2b = [outdir '/' objname '_' num2str(ngramtype) '_all_uniquedNsort_rewrite.txt'];
if ~exist(savename, 'file')
    disp('searching ngram data');
    if exist(savename1, 'file'), delete(savename1); end
    
    numNgramFiles = ngramGoogFileInfo(ngramtype);
    parfor f=1:numNgramFiles           % cant parfor this as appending to file
        disp(f); 
        savename_tmp = [outdir '/' objname '_' num2str(ngramtype) '_tmp_' num2str(f) '.txt'];
        %if exist(savename_tmp, 'file'), delete(savename_tmp); end
        inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' getfcode_forzerogram(f)];        
        system(['/projects/grail/santosh/objectNgrams/code/ngram/fetchNgramdata_2012.sh' ' ' ...
            objname ' ' inpfname ' '  num2str(ngramtype) ' ' objname_plural ' ' savename_tmp]);        
    end        
    myprintfn;
    
    for f=1:numNgramFiles           % cant parfor this as appending to file
        myprintf(f);       
        savename_tmp = [outdir '/' objname '_' num2str(ngramtype) '_tmp_' num2str(f) '.txt'];    
        system(['cat ' savename_tmp ' >> ' savename1]);
    end
    myprintfn;
    
    system(['mv ' savename1 ' ' savename]);
    
    disp('uniquify ngram data');
    merge2345ngram_topData(objname, outdir, minNgramCnt, 2012);
    
    disp('rewrting 1. without PoS info 2. strict word (car insted of vicar) 3. X horse (instead of horse X)');
    system(['/projects/grail/santosh/objectNgrams/code/ngram/rewriteNgramdata_2012.sh' ' ' ...
        savename2 ' ' savename2b ' ' objname]);
end
    
catch    
    disp(lasterr); keyboard;
end
%}
