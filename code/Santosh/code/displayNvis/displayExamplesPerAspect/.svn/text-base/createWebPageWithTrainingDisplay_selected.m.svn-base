function createWebPageWithTrainingDisplay_selected(phrasenames_sel, ngramid_sel, comp_sel, cachedir, wwwdispdir, wwwdispdir_part, phrasenames)

try
    
disp(' read im link info');
[mimlink, mimlink12] = deal(cell(numel(phrasenames_sel), 1));
mimlink2 = cell(numel(phrasenames_sel), 1); 
for f = 1:numel(phrasenames_sel)                
    mimlink{f} = ['http://grail.cs.washington.edu/projects/visual_ngrams/display/' wwwdispdir_part '/' phrasenames_sel{f} '_montage3x3_' num2str(comp_sel(f), '%02d')  '.jpg'];
    mimlink12{f} = ['http://grail.cs.washington.edu/projects/visual_ngrams/display/' wwwdispdir_part '/' phrasenames_sel{f} '_pr' num2str(comp_sel(f), '%d')  '_100.jpg'];
    mimlink2{f} = ['http://grail.cs.washington.edu/projects/visual_ngrams/display/' wwwdispdir_part '/' phrasenames_sel{f} '_montageOverIt_' num2str(comp_sel(f), '%03d')  '.jpg'];
end

disp(' load roc info');
if 0
    load([rocdir '/rocInfo_val2_9990_mix.mat'], 'roc', 'numTrngInst');
else
    clear roc numTrngInst
    for f = 1:numel(phrasenames)
        myprintf(f,10);
        tmp1 = load([cachedir '/../' phrasenames{f} '/' phrasenames{f} '_mix_goodInfo.mat'], 'roc');
        for kk=1:numel(tmp1.roc), roc{f,kk} = tmp1.roc{kk}; end
        tmp2 = load([cachedir '/../' phrasenames{f} '/' phrasenames{f} '_mix.mat'], 'model');
        numTrngInst(f,:) = tmp2.model.stats.filter_usage;
    end
    myprintfn;
end


disp(' create webpage');
fid = fopen([wwwdispdir '/preorder_selectedComponetsDisplay.html'], 'w'); 

fprintf(fid, '<html>\n\n');
fprintf(fid, '<table>\n\n');    %cellspacing="25"
for c = 1:numel(phrasenames_sel)
    myprintf(c, 10);
    fprintf(fid, '<tr>\n\n');
    fprintf(fid, '<td>\t');
    fprintf(fid, '<img src=%s>\t', mimlink{c});
    fprintf(fid, '</td>\n');
    fprintf(fid, '<td>\t');
    fprintf(fid, '<img src=%s>\t', mimlink12{c});
    fprintf(fid, '</td>\n');
    fprintf(fid, '</tr>\n\n<tr>\n');
    fprintf(fid, '<td><center>\t');
    %fprintf(fid, '<a href=%s>%s</a>\t', mimlink2{c}, [phrasenames_sel{c} ' ' num2str(comp_sel(c))]);
    fprintf(fid, '<a href=%s>%s</a>, %d, %d, %2.1f, %2.1f\t', mimlink2{c}, [phrasenames_sel{c} ' ' num2str(comp_sel(c))], numTrngInst(ngramid_sel(c),comp_sel(c)), roc{ngramid_sel(c),comp_sel(c)}.npos, roc{ngramid_sel(c),comp_sel(c)}.ap_full_new*100, roc{ngramid_sel(c),comp_sel(c)}.ap_new*100);
    fprintf(fid, '</center></td>\n');
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
