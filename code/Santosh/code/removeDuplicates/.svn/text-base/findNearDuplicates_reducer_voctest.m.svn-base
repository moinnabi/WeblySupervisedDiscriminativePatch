function findNearDuplicates_reducer_voctest(cachedir, dtype, imgsetdir, objname)
% HOG based dup detection

try
    
disp(' write out text files with dup info removed');
ids = textread([imgsetdir '/test.txt'], '%s');
oldl = numel(ids);
pids = ids;
 
dupfnd_vect = zeros(numel(pids),1);
fid = fopen([cachedir '/' dtype '_' objname '.txt'], 'w');
for f=1:numel(pids)
    myprintf(f,1000);
    load([cachedir '/file_' num2str(f) '.mat'], 'dupfnd');    
    dupfnd_vect(f) = dupfnd;
    if dupfnd == 0
        fprintf(fid, '%s\n', pids{f});
    end
end
myprintfn;
fclose(fid);

ids = textread([cachedir '/' dtype '_' objname '.txt'], '%s');     % can read from "_withLabels" as dups have been removed
newl = length(ids);

disp(['old length was ' num2str(oldl) '; new length is ' num2str(newl)]);
      
catch
    disp(lasterr); keyboard;
end
