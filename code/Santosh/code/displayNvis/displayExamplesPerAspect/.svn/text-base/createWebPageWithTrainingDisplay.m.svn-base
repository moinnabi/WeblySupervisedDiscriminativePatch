function createWebPageWithTrainingDisplay(phrasenames, numComp, cachedispdir, wwwdispdir_part, rocdir, weburl)

try

%weburl = 'http://grail.cs.washington.edu/projects/visual_ngrams/display/';
disp(' read im link info');
[mimlink, mimlink11, mimlink12, mimlink12b] = deal(cell(numel(phrasenames), numComp));
mimlink2 = cell(numel(phrasenames), numComp);
for f = 1:numel(phrasenames)    
    for k=2:numComp+1        
        mimlink{f,k-1} = [weburl wwwdispdir_part '/' phrasenames{f} '_montage3x3_' num2str(k-1, '%02d')  '.jpg'];
        mimlink11{f,k-1} = [weburl  wwwdispdir_part '/' phrasenames{f} '_montageAVG_' num2str(k-1, '%02d')  '_100.jpg'];
        mimlink12{f,k-1} = [weburl  wwwdispdir_part '/' phrasenames{f} '_pr' num2str(k-1, '%d')  '_100.jpg'];
        mimlink12b{f,k-1} = [weburl  wwwdispdir_part '/' phrasenames{f} '_pr' num2str(k-1, '%d')  '.jpg'];
        mimlink2{f,k-1} = [weburl wwwdispdir_part '/' phrasenames{f} '_montageOverIt_' num2str(k-1, '%02d')  '.jpg'];
    end
end

disp(' load roc info');
if 0
    load([rocdir '/rocInfo_val2_9990_mix.mat'], 'roc', 'numTrngInst');
else
    clear roc numTrngInst
    for f = 1:numel(phrasenames)
        myprintf(f,10);
        tmp1 = load([rocdir '/../' phrasenames{f} '/' phrasenames{f} '_mix_goodInfo.mat'], 'roc');
        for kk=1:numComp, roc{f,kk} = tmp1.roc{kk}; end
        tmp2 = load([rocdir '/../' phrasenames{f} '/' phrasenames{f} '_mix.mat'], 'model');
        numTrngInst(f,:) = tmp2.model.stats.filter_usage;
    end
    myprintfn;
end

disp(' create webpage'); 
%outdir = [ngimgModeldir_obj '/summaryStats/']; mymkdir(outdir);
%fid = fopen([outdir '/allTrainingDisplay.html'], 'w');
fid = fopen([cachedispdir '/allTrainingDisplay.html'], 'w');

fprintf(fid, '<html>\n\n');
fprintf(fid, '<table>\n\n');    %cellspacing="25"
for f = 1:numel(phrasenames)
    myprintf(f, 10);
    fprintf(fid, '<tr>\n\n');
    for k=2:numComp+1
        fprintf(fid, '<td>\t');
        fprintf(fid, '<img src=%s>\t', mimlink{f,k-1});
        fprintf(fid, '</td>\n');
    end    
    fprintf(fid, '</tr>\n\n<tr>\n');
    
    for k=2:numComp+1
        fprintf(fid, '<td>\t');
        fprintf(fid, '<img src=%s>\t', mimlink11{f,k-1});
        fprintf(fid, '<a href=%s><img src=%s></a>\t', mimlink12b{f,k-1}, mimlink12{f,k-1});
        fprintf(fid, '</td>\n');
    end
    fprintf(fid, '</tr>\n\n<tr>\n');
    
    for k=2:numComp+1
        fprintf(fid, '<td><center>\t');
        fprintf(fid, '<a href=%s>%s</a>, %d, %d, %2.1f, %2.1f\t', mimlink2{f,k-1}, [phrasenames{f} ' ' num2str(k-1)], numTrngInst(f,k-1), roc{f,k-1}.npos, roc{f,k-1}.ap_full_new*100, roc{f,k-1}.ap_new*100);
        fprintf(fid, '</center></td>\n');
    end
    fprintf(fid, '</tr>\n\n\n');
    fprintf(fid, '\n\n');
end
myprintfn;
fprintf(fid, '</table>\n\n');
fprintf(fid, '</html>\n\n');

fclose(fid);

catch
    disp(lasterr); keyboard;
end
