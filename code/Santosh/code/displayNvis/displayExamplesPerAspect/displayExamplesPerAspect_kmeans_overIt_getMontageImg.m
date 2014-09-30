function [mim mimg mlab] = displayExamplesPerAspect_kmeans_overIt_getMontageImg...
    (inds, pos, posscores, model, numToDisplay)

unids = unique(inds);
for jj = 1:length(unids)
    myprintf(jj);
    A = find(inds == unids(jj));
    thisNum = min(numToDisplay, numel(A));
    allimgs = cell(thisNum,1); alllabs = cell(thisNum,1);
        
    if ~isempty(posscores)
        thisscores = posscores(A);
        [sval sinds] = sort(thisscores, 'descend');
        selInds = sinds(1:thisNum);
    else
        randInds = randperm(numel(A));
        selInds = randInds(1:thisNum);
        sval = zeros(thisNum, 1);
    end
    spos = pos(A(selInds));
    warptmp = warppos_display(model, spos);    
    for j=1:thisNum        
        allimgs{j} = uint8(warptmp{j});
        %[blah alllabs{j}] = myStrtokEnd(strtok(spos(j).im, '.'), '/');
        alllabs{j} = num2str(sval(j));
    end
    mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
    mlab{jj} = num2str(numel(A));
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1000 1000 3]);
myprintfn;
