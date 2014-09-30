function objectNgramData(ngramtype, objname, indir, outdir)

try

objname_plural = getPlural(objname);

savename1 = [outdir '/' objname '_' num2str(ngramtype) '_all.txt'];
savename_tmp = [outdir '/' objname '_' num2str(ngramtype) '_tmp.txt'];
if ~exist(savename1, 'file')    
    numNgramFiles = ngramGoogFileInfo(ngramtype);
    %disp('first put all stuff together');
    for f=1:numNgramFiles
        myprintf(f);
        delete(savename_tmp);
        inpfname = [indir '/googlebooks-eng-all-' num2str(ngramtype) 'gram-20090715-' num2str(f) '.csv'];
        outfname = savename_tmp;        
        filenameWithPath = which('fetchNgramdata.sh');  %'/projects/grail/santosh/objectNgrams/code/ngram/fetchNgramdata.sh'
        system([filenameWithPath ' ' objname ' ' inpfname ' '  num2str(ngramtype) ' ' outfname]);        
        system(['cat ' savename_tmp ' >> ' savename1]);
    end        
    myprintfn;
end
    
catch    
    disp(lasterr); keyboard;
end

function B = getB(fidr, ngramtype)

if ngramtype == 2, B = textscan(fidr, '%s %s %d');
elseif ngramtype == 3, B = textscan(fidr, '%s %s %s %d');
elseif ngramtype == 4, B = textscan(fidr, '%s %s %s %s %d');
elseif ngramtype == 5, B = textscan(fidr, '%s %s %s %s %s %d');
end
    
%{
if ngramtype == 2, B = textscan(fidr, '%s %s %d');
    elseif ngramtype == 3, B = textscan(fidr, '%s %s %s %d');
    elseif ngramtype == 4, B = textscan(fidr, '%s %s %s %s %d');
    elseif ngramtype == 5, B = textscan(fidr, '%s %s %s %s %s %d');
    end
    %}
