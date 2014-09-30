function phrase_imagenames = getPhraseIconImages(phrasenames, VOCopts)

datatype = 'train';
numcls = numel(phrasenames);
phrase_imagenames = cell(numcls, 1);
for c=1:numcls
    ids = textread(sprintf(VOCopts.clsimgsetpath, phrasenames{c}, datatype), '%s');
    %phrase_imagenames{c} = sprintf(VOCopts.imgpath, ids{1});
    tmpname = sprintf(VOCopts.imgpath, ids{1});
    tmpname_ps = [tmpname(1:end-3) 'ps'];    
    if ~exist(tmpname_ps, 'file')        
        error('file doesnot exist; cant run on mframe bcoz of convert version issues');
        myprintf(c);
        system(['convert ' tmpname ' -resize x64 ' tmpname_ps]);
    end
    phrase_imagenames{c} = tmpname_ps;
end
