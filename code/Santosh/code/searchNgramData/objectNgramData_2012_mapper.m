function objectNgramData_2012_mapper(ngramtype, objname, indir, tmpdir)

try
    
if isdeployed, ngramtype = str2num(ngramtype); end

%tmpdir = [outdir '/tempFiles_' num2str(ngramtype) '/']; 
mymkdir(tmpdir);

objname_plural = getPlural(objname);
objname_syns = getObjectSynonyms(objname);
numNgramFiles = ngramGoogFileInfo(ngramtype);

resdir = tmpdir;
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numNgramFiles);
%for f=1:numNgramFiles
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
    
    disp(['Processing file ' num2str(f) '/' num2str(numNgramFiles)]);
    
    for ij = 1:numel(objname_syns)
        thisobjname = objname_syns{ij};        
        %disp([' searching ngram data ' thisobjname]);        
        savename_tmp = [tmpdir '/' thisobjname '_' num2str(ngramtype) '_tmp_' num2str(f) '.txt'];
        inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20120701-' getfcode_forngram(ngramtype, f)];
        if ~exist(savename_tmp, 'file') && exist(inpfname,'file')
            if ngramtype == 0
                filenameWithPath = which('fetchNgramdata_2012.sh');     %'/projects/grail/santosh/objectNgrams/code/ngram/fetchNgramdata_2012.sh'
                system([filenameWithPath  ' ' ...
                    thisobjname ' ' inpfname ' '  num2str(ngramtype) ' ' objname_plural ' ' savename_tmp]);
            elseif ngramtype == 2 || ngramtype == 3 || ngramtype == 4 || ngramtype == 5
                filenameWithPath = which('fetchNgramdata_2012_2345.sh');    %'/projects/grail/santosh/objectNgrams/code/ngram/fetchNgramdata_2012_2345.sh'
                system([filenameWithPath ' ' ...
                    thisobjname ' ' inpfname ' '  num2str(ngramtype) ' ' objname_plural ' ' savename_tmp]);
            end            
        end
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done']);
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch    
    disp(lasterr); keyboard;
end
   