function totalNumOfGoodComps(cachedir, phrasenames, this_suffix, numComp)

numcls = numel(phrasenames);

disp(' calculating good components');
totalgudcomps = 0;
allGoodCompInfo = cell(numcls, 1);
for f=1:numcls
    myprintf(f, 10);
    load([cachedir '/../' phrasenames{f} '/' phrasenames{f} this_suffix], 'goodcomps');
    allGoodCompInfo{f} = goodcomps;
    totalgudcomps = totalgudcomps + sum(goodcomps);        
end
myprintfn;

%length(find(cellfun(@isempty, ds_top)==0))*numComp
disp(['Total of ' num2str(totalgudcomps) '/' num2str(numcls*numComp) ' good comps']);

save([cachedir '/allGoodCompInfo.mat'], 'allGoodCompInfo', 'totalgudcomps', 'numcls', 'numComp');
