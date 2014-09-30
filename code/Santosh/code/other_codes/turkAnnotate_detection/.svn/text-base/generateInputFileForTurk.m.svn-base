function generateInputFileForTurk(objname, turkdir, objturkdir_www, baseurl, imgsetdir, jpgdir)

try
    
% get test data image names
[ids gt] = textread([imgsetdir '/test_withLabels.txt'] , '%s %d');
ids2 = textread([imgsetdir '/test.txt'] , '%s');
if length(ids) ~= length(ids2), disp('some issue here'); keyboard; end
ids = ids(gt == 1);

fname = [turkdir '/' objname '/' objname '.input'];
fid = fopen(fname, 'w');
fprintf(fid, 'urls\n');
for f=1:numel(ids)
    myprintf(f, 100);
    fprintf(fid, '%s%s,%s.jpg\n', baseurl, objname, ids{f});
end
myprintfn;
fclose(fid);

copyfile([turkdir '/object.properties'], [turkdir '/' objname '/' objname '.properties']);
copyfile([turkdir '/object.question'], [turkdir '/' objname '/' objname '.question']);

disp(' copy images to wwwdir');
for f=1:numel(ids)
    myprintf(f, 100);    
    copyfile([jpgdir '/' ids{f} '.jpg'], [objturkdir_www '/' ids{f} '.jpg']);
end
myprintfn;

catch
    disp(lasterr); keyboard;
end
