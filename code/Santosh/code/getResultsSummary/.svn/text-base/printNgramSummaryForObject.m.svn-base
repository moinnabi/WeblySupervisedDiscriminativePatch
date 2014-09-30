function printNgramSummaryForObject(baseobjdir, objname, fname_imgcl_sprNg, summFile, ngramFile, imgclsFile)

% print list of synonyms
objsyns = getObjectSynonyms(objname);

% print #ngrams
phrasenames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg); 

% print raw #ngrams
ngramList = textread(ngramFile, '%s');
num_ngramList = length(ngramList);

% print #ngrams after img classifier thresh pruning
imgclsList = textread(imgclsFile, '%s');
num_imgclsList = length(imgclsList);

% print #components
load([baseobjdir '/' ['baseobjectcategory_' objname] '_joint.mat'], 'model');
numFinComps = numel(model.rules{model.start});

fid = fopen(summFile, 'w');
fprintf(fid, '%%%%%%%%%%%%\n');
fprintf(fid, '+++%s+++\n\n', objname);
fprintf(fid, 'list of synonyms::\n');
for f=1:numel(objsyns)
    fprintf(fid, '%s\t', objsyns{f});
end
fprintf(fid, '\n');

fprintf(fid, 'Total raw #ngrams::%d\n', num_ngramList);

fprintf(fid, 'Total #ngrams after imgcls thresh::%d\n', num_imgclsList);

fprintf(fid, 'Total #ngrams::%d\n', numel(phrasenames));

fprintf(fid, 'Total #final comps::%d\n', numFinComps);
fprintf(fid, '%%%%%%%%%%%%\n');

fclose(fid);
