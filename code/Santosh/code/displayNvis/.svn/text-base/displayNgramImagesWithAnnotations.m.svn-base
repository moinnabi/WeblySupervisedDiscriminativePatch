function displayNgramImagesWithAnnotations(inpfname, ngramDispdir_obj, imgsetdir, jpgdir)

try
    
mymatlabpoolopen;
   
[~, phrasenames] = system(['cat ' inpfname]);
phrasenames = regexp(phrasenames, '\n', 'split');
phrasenames(cellfun('isempty', phrasenames)) = [];
numcls = numel(phrasenames);

parfor f = 1:numcls
    myprintf(f,10); %disp(['processing ' num2str(f)]); 
    ngramPhraseName2 = strrep(phrasenames{f}, ' ', '_');
    svname = [ngramDispdir_obj '/' ngramPhraseName2 '.jpg']; 
    if ~exist(svname, 'file')        
        [ids, gt] = textread([imgsetdir '/' ngramPhraseName2 '_train.txt'],'%s %d');
        ids = ids(gt == 1);
        imcell = cell(numel(ids),1);
        for j=1:numel(ids)
            imcell{j} = color(uint8(imread([jpgdir '/' ids{j} '.jpg'])));
        end
        mimg = single(montage_list(imcell, 2, [1 1 1], [1000 1000 3]));
        imwrite(mimg, svname);
    end
end
myprintfn;

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end
