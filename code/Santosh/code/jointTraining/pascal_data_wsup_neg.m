function neg = pascal_data_wsup_neg(VOCopts, dataset_bg, year)
  
% Negative examples from the background dataset
%[ids, gt]    = textread(sprintf(VOCopts.clsimgsetpath, objname, dataset_bg), '%s %d');
[ids, gt]    = textread(sprintf(VOCopts.imgsetpath, dataset_bg), '%s %d');
ids = ids(gt == -1);
neg    = [];
numneg = 0;
dataid = 0;
for i = 1:length(ids)
    myprintf(i,100); 
    %tic_toc_print('parsing negatives (%s %s): %d/%d\n', dataset_bg, year,i, length(ids)); 
    dataid             = dataid + 1;
    numneg             = numneg+1;
    neg(numneg).im     = sprintf(VOCopts.imgpath, ids{i});
    neg(numneg).flip   = false;
    neg(numneg).dataid = dataid;
end
