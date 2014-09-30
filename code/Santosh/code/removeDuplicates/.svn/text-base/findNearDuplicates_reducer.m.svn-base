function findNearDuplicates_reducer(cachedir, dtype, imgsetdir, objname, phrasenames)
% HOG based dup detection

try
    
disp(' write out text files with dup info removed');
if ~exist([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels_withDups.txt'], 'file')    
    disp(' copying file1');
    copyfile([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels.txt'], [imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels_withDups.txt']);
end

[ids, gt] = textread([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels_withDups.txt'], '%s %d');
oldl = numel(ids);
pids = ids(gt == 1);
nids = ids(gt == -1);

fid = fopen([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels.txt'], 'w');
for f=1:numel(pids)
    myprintf(f,1000);
    load([cachedir '/file_' num2str(f) '.mat'], 'dupfnd');    
    if dupfnd == 0
        fprintf(fid, '%s 1\n', pids{f});
    end
end
myprintfn;
for f=1:numel(nids)
    myprintf(f,1000);
    fprintf(fid, '%s -1\n', nids{f});    
end
myprintfn;
fclose(fid);

disp(' write out text files with dup info removed');
if ~exist([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withDups.txt'], 'file')
    disp(' copying file2');
    copyfile([imgsetdir '/baseobjectcategory_' objname '_' dtype '.txt'], [imgsetdir '/baseobjectcategory_' objname '_' dtype '_withDups.txt']);
end
[ids, gt] = textread([imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels.txt'], '%s %d');     % can read from "_withLabels" as dups have been removed
newl = length(ids);
fid = fopen([imgsetdir '/baseobjectcategory_' objname '_' dtype '.txt'], 'w');
for f=1:numel(ids)
    myprintf(f,1000);
    fprintf(fid, '%s\n', ids{f});
end
myprintfn;
fclose(fid);

disp(['old length was ' num2str(oldl) '; new length is ' num2str(newl)]);

disp('update val files belonging to all ngrams to remove dups');
parfname = [imgsetdir '/baseobjectcategory_' objname '_' dtype '_withLabels.txt'];
for f=1:numel(phrasenames) 
    myprintf(f, 10);
    fname = [imgsetdir '/' phrasenames{f} '_val.txt'];
    fname_keep = [imgsetdir '/' phrasenames{f} '_val_beforeDups.txt'];
    movefile(fname, fname_keep);    % keep for records    
    system(['grep -F -f ' fname_keep ' ' parfname ' > ' fname]);    
end

%{
    [thisids, thisgt] = textread(fname_keep, '%s %d');        
    % keep only those thisids that exists in ids (dont need to worry abt negs as they are the same and would be retained)
    [thisids_new, ia]= intersect(thisids, ids);
    
    fid = fopen(fname, 'w');
    for i=1:numel(thisids_new)
        myprintf(i,1000);
        fprintf(fid, '%s %d\n', thisids_new{i}, thisgt(ia(i)));
    end
    myprintfn;
    fclose(fid);        
    %}


catch
    disp(lasterr); keyboard;
end
