function getListOfValidValImgs(ngramModeldir_obj, ngramDupdir_obj, imgsetdir, phrasenames, phrasevocyear, objname)

try
    
numcls = numel(phrasenames);

disp('identify component info and then retain good comp images');
validids = [];
dcinds = [];
for f=1:numcls
    myprintf(f,10);
    
    % find which comp each (positive) image in val set belongs to
    load([ngramModeldir_obj '/' phrasenames{f} '/' phrasenames{f} '_boxes_val' '_' phrasevocyear '_' 'mix'], 'ds', 'bs');    
    [~, gt] = textread([imgsetdir '/' phrasenames{f} '_val.txt'], '%s %d');    
    valImgCompIds = zeros(length(find(gt==1)), 1);
    for ij = 1:length(gt)
        if gt(ij) == 1 && ~isempty(bs{ij})
            valImgCompIds(ij) = bs{ij}(1,end-1);
        end
    end
    dcinds = [dcinds; valImgCompIds];
    
    % now consider only those images which belong to good comps
    binIndexArr = zeros(length(valImgCompIds),1);
    load([ngramModeldir_obj '/' phrasenames{f} '/' phrasenames{f} '_mix_goodInfo.mat'], 'goodcomps');
    for ij = 1:length(goodcomps)
        if goodcomps(ij) == 1
            binIndexArr(valImgCompIds == ij) = 1;
        end
    end
    validids = [validids; binIndexArr];
end
myprintfn;

mymatlabpoolopen;

disp(' and now, consider all images belonging to negative set');
[~, gt] = textread([imgsetdir '/baseobjectcategory_' objname '_val2_withLabels.txt'], '%s %d');
binIndexArr = ones(length(find(gt==-1)),1);
dcinds = [dcinds; -1*binIndexArr];
validids = [validids; binIndexArr];

if numel(gt) ~= numel(validids), disp('length mismatch'); keyboard; end

save([imgsetdir '/baseobjectcategory_' objname '_val2_validCompIds.mat'], 'validids', 'dcinds');

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end
