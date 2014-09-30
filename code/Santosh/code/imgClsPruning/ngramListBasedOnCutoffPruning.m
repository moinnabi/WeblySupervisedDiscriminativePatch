function ngramListBasedOnCutoffPruning(outfname1, outfname3)

% prune based on 1. cutoff  & 2. frequency (this freq is higher than earlier freq thresh used)
[~,~,~,phrasenames] = selectTopPhrasenames(outfname1);
fid = fopen(outfname3, 'w');
for ii=1:numel(phrasenames), fprintf(fid, '%s\n', phrasenames{ii}); end
fprintf(fid, '\n');   % needed for the download gui
fclose(fid);

%disp(['Found ' num2str(numel(phrasenames)) ' ngrams to download']); 
