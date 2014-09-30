function createWebPageWithTrainingDisplay_selected_reorder(cachedir, wwwdispdir, wwwdispdir_part, objname, fname_imgcl_sprNg, n_perngram, weburl)

try

phrasenames = getNgramNamesForObject_new(objname, fname_imgcl_sprNg); 

disp(' read im link info');
[mimlink, mimlink12] = deal(cell(numel(phrasenames), 1));
mimlink2 = cell(numel(phrasenames), 1); 
for f = 1:numel(phrasenames)                
    for k=1:n_perngram
        mimlink{f,k} = [weburl  wwwdispdir_part '/' phrasenames{f} '_montage3x3_' num2str(k, '%02d')  '.jpg'];
        mimlink12{f,k} = [weburl  wwwdispdir_part '/' phrasenames{f} '_pr' num2str(k, '%d')  '_100.jpg'];
        mimlink2{f,k} = [weburl  wwwdispdir_part '/' phrasenames{f} '_montageOverIt_' num2str(k, '%03d')  '.jpg'];
    end
end

disp(' load roc info');
if 0
    load([rocdir '/rocInfo_val2_9990_mix.mat'], 'roc', 'numTrngInst');
else
    clear roc numTrngInst
    for f = 1:numel(phrasenames)
        myprintf(f,10);
        tmp1 = load([cachedir '/../' phrasenames{f} '/' phrasenames{f} '_mix_goodInfo.mat'], 'roc');
        for kk=1:n_perngram, roc{f,kk} = tmp1.roc{kk}; end
        tmp2 = load([cachedir '/../' phrasenames{f} '/' phrasenames{f} '_mix.mat'], 'inds_mix');        
        for kk=1:n_perngram
            numTrngInst(f,kk) = length(find(tmp2.inds_mix == kk)); 
        end
    end    
    myprintfn;
end

disp(' create webpage');
fid = fopen([wwwdispdir '/selectedComponetsDisplay.html'], 'w'); 

fprintf(fid, '<html>\n\n');
fprintf(fid, '<table>\n\n');    %cellspacing="25"
compind = 0;
selComp_numTrng = [];
for c = 1:numel(phrasenames)
    myprintf(c, 10);
    load([cachedir '/../' phrasenames{c} '/' phrasenames{c} '_mix_goodInfo2'], 'selcomps');
    for j=1:n_perngram
        if selcomps(j) == 1                        
            compind = compind + 1;
            selComp_numTrng(compind) = numTrngInst(c,j);
            fprintf(fid, '<tr>\n\n');
            fprintf(fid, '<td>\t');
            fprintf(fid, '<img src=%s>\t', mimlink{c,j});
            fprintf(fid, '</td>\n');
            fprintf(fid, '<td>\t');
            fprintf(fid, '<img src=%s>\t', mimlink12{c,j});
            fprintf(fid, '</td>\n');
            fprintf(fid, '</tr>\n\n<tr>\n');
            fprintf(fid, '<td><center>\t');
            %fprintf(fid, '<a href=%s>%s</a>\t', mimlink2{c}, [phrasenames_sel{c} ' ' num2str(comp_sel(c))]);
            fprintf(fid, '%d, <a href=%s>%s</a>, %d, %d, %2.1f, %2.1f\t', ...
                compind, mimlink2{c,j}, [phrasenames{c} ' ' num2str(j)], numTrngInst(c,j), ...
                roc{c,j}.npos, roc{c,j}.ap_full_new*100, roc{c,j}.ap_new*100);
            fprintf(fid, '</center></td>\n'); 
            fprintf(fid, '</tr>\n\n\n');
            fprintf(fid, '\n\n');
        end
    end
end
myprintfn;
fprintf(fid, '</table>\n\n');
fprintf(fid, '</html>\n\n');

fclose(fid);

%{
disp('saving max value of trng instances across ngrams');   
%numInstToTrain_allNgrams = median(selComp_numTrng);
numInstToTrain_allNgrams = max(selComp_numTrng); 
save([cachedir '/medianNumInstances.mat'], 'numTrngInst', 'selComp_numTrng', 'numInstToTrain_allNgrams');
%}

catch
    disp(lasterr); keyboard;
end
