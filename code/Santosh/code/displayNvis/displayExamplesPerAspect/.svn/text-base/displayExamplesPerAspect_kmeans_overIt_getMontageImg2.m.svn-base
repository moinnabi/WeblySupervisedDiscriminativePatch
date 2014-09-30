function [mim mimg mlab] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (inds, inds_old, pos, posscores, model, numToDisplay, modelthresh, mtitle)

% this is pretty much similar to
% displayExamplesPerAspect_kmeans_overIt_getMontageImg.m; few updates made
% to make visualizations more meaningful (like sorting by scores and
% displaying them and also old indices etc?!)

if ~exist('mtitle', 'var'), mtitle = ''; end

[mimg, mlab] = deal(cell(numel(model.rootfilters)+1,1)); % +1 to accomodate 0 index    
for jj=1:numel(mimg)    % initialize to dummy
    mimg{jj} = ones(10,10,3);
    mlab{jj} = ' ';
end

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
        if unids(jj) ~= 0 & ~isempty(modelthresh) & sval(j) >= modelthresh(unids(jj))
            printScore = num2str(sval(j));
        else
            printScore = ['* ' num2str(sval(j))];
        end
        
        if inds_old(A(selInds(j))) == unids(jj)
            alllabs{j} = ['0 ' printScore];
        else
            alllabs{j} = [num2str(inds_old(A(selInds(j)))) ' ' printScore];
        end
        %% added this plug for generating results for CVPR supplementary
        %% deadline
        alllabs{j} = '';
    end
    %if unids(1) == 0, mimgInd = unids(jj)+1;    % if there is 0 ind, then shift mimgInd, else directly use unids
    %else mimgInd = unids(jj); end
    %mimg{unids(jj)+1} = montage_list_w_text2(allimgs, alllabs, 2);
    mimg{unids(jj)+1} = montage_list_w_text2(allimgs, alllabs, 2, mtitle);
    mlab{unids(jj)+1} = num2str(numel(A));
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [3000 3000 3]);
myprintfn;
