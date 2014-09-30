function [cphrasenames, cphrasenames_disp] = getPhrasenamesPerComp(phrasenames, phrasenames_disp, numComp)

numcls = numel(phrasenames);
cphrasenames = cell(numcls*numComp,1);
cphrasenames_disp = cell(numcls*numComp,1);
for c=1:numcls
    for ck=1:numComp
        cphrasenames{(c-1)*numComp+ck} = [num2str(ck) '_' phrasenames{c}];
        cphrasenames_disp{(c-1)*numComp+ck} = [num2str(ck) '_' phrasenames_disp{c}];
    end
end
