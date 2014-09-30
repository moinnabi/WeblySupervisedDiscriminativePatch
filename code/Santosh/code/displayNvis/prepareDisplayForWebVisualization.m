function prepareDisplayForWebVisualization(objname, phrasenames, ngramModeldir_obj, numcomp, wwwdispdir, wwwdispdir_part, weburl)

try
mymatlabpoolopen;

parfor ii = 1:numel(phrasenames)
    %myprintf(ii);    
    disp(['Processing ngram ' num2str(ii) ' ' phrasenames{ii}]);  
    cachedir = [ngramModeldir_obj '/' phrasenames{ii}];
    if ~exist([wwwdispdir '/' phrasenames{ii} '_pr' num2str(numcomp) '_100.jpg'], 'file')   % if last filename of all the stuff that needs to be copied is not copied
        for kk=1:numcomp
            copyfile([cachedir '/display/montageOverIt_' num2str(kk,'%03d') '.jpg'], [wwwdispdir '/' phrasenames{ii} '_montageOverIt_' num2str(kk,'%03d') '.jpg']);
        end
        for kk=1:numcomp
            copyfile([cachedir '/display/montage3x3_' num2str(kk,'%02d') '.jpg'], [wwwdispdir '/' phrasenames{ii} '_montage3x3_' num2str(kk,'%02d') '.jpg']);
        end
        for kk=1:numcomp
            copyfile([cachedir '/display/montageAVG_' num2str(kk,'%02d') '.jpg'], [wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '.jpg']);
        end
        
        %for kk=1:numcomp, system(['convert -resize 100x100 ' [wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '.jpg'] ' ' [wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '_100.jpg']]); end
        for kk=1:numcomp
            imwrite(imresize(imread([wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '.jpg']), [100 100], 'nearest'), [wwwdispdir '/' phrasenames{ii} '_montageAVG_' num2str(kk,'%02d') '_100.jpg']);
        end
        
        
        try
            copyfile([cachedir '/display_val2_9990_9990/all_val2_9990_mix_001-049.jpg'], [wwwdispdir '/' phrasenames{ii} '_all_val2_9990_mix_001-049.jpg']);
            copyfile([cachedir '/display_val2_9990_9990/all_val2_9990_mix_050-098.jpg'], [wwwdispdir '/' phrasenames{ii} '_all_val2_9990_mix_050-098.jpg']);
            copyfile([cachedir '/display_val2_9990_9990/all_val2_9990_mix_099-147.jpg'], [wwwdispdir '/' phrasenames{ii} '_all_val2_9990_mix_099-147.jpg']);
        end
        
        
        for kk=1:numcomp
            copyfile([cachedir '/display/pr/' num2str(kk) '_ngram.jpg'], [wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '.jpg']);
        end
        
        %for kk=1:numcomp, system(['convert -resize 100x100 ' [wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '.jpg'] ' ' [wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '_100.jpg']]); end
        for kk=1:numcomp
            imwrite(imresize(imread([wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '.jpg']), [100 100], 'nearest'), [wwwdispdir '/' phrasenames{ii} '_pr' num2str(kk) '_100.jpg']);
        end
    end            
end

cachedir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/'];
createWebPageWithTrainingDisplay(phrasenames, numcomp, wwwdispdir, wwwdispdir_part, cachedir, weburl);

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end
 