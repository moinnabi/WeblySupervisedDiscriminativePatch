function [phrasenames, compSize] = getphraseInfo_modelmerged(models, fname)

numcls = numel(models);
phrasenames = cell(numcls, 1);
for i =1:numcls
    phrasenames{i} = models{i}.class;
end

% also print to file for reference
fid = fopen(fname, 'w');
for i =1:numcls
    fprintf(fid, '%d %s\n', i, phrasenames{i});     
end
fclose(fid);

compSize = zeros(numcls, 1);
for i =1:numcls
    compSize(i) = models{i}.stats.filter_usage(1);  
end
