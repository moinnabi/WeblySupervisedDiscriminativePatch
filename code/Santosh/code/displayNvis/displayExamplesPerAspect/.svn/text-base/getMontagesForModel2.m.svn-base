function [mimg, mlab] = getMontagesForModel2(inds, inds_past, inds_fut, posscores, lbbox, pos, numToDisplay, numComps)

if isempty(lbbox)
    lbbox = zeros(numel(pos), 4);
    for j = 1:numel(pos)
        lbbox(j,:) = [pos(j).x1 pos(j).y1 pos(j).x2 pos(j).y2];
    end
end

if isempty(posscores)
    posscores = zeros(numel(pos), 2);    
end

[mimg, mlab] = deal(cell(numComps+1,1)); % +1 to accomodate 0 index    
for jj=1:numel(mimg)    % initialize to dummy
    mimg{jj} = ones(10,10,3);
    mlab{jj} = ' ';
end

unids = unique(inds(:,1));
for jj = 1:length(unids)    
    myprintf(jj);
    %savename = [dispdir '/montage_' num2str(jj) '.jpg'];    
    %if ~exist(savename, 'file')
        A = find(inds(:,1) == unids(jj));
        thisNum = min(numToDisplay, numel(A));
        allimgs = cell(thisNum,1); alllabs = cell(thisNum,1);
        
        if ~isempty(posscores)
            thisscores_tmp = posscores(A,1);
            [sval sinds] = sort(thisscores_tmp, 'descend');
            selInds = sinds(1:thisNum);
        else
            randInds = randperm(numel(A));
            selInds = randInds(1:thisNum);
            %sval = zeros(thisNum, 1);
        end
        spos = pos(A(selInds));
        thisbbox = lbbox(A(selInds),1:4);
        thisscores = posscores(A(selInds),1);
        thisscores_nb = posscores(A(selInds),2);
        if size(inds,2) == 2, thisinds_nb = inds(A(selInds), 2);
        else thisinds_nb = inds(A(selInds), 1); end
        %warptmp = warppos_display(model, spos);        
        for j=1:thisNum
            im = color(imreadx(spos(j)));
            allimgs{j} = croppos_nopad(im, thisbbox(j,:));
            %allimgs{j} = uint8(warptmp{j});
            printScore = num2str(thisscores(j), '%1.2f');
            if unids(jj) == 0, printScore = ['* ' printScore]; end
            
            %if inds_past(A(selInds(j))) == unids(jj), alllabs{j} = ['0 ' printScore];
            %else
            %%%alllabs{j} = [num2str(inds_past(A(selInds(j)))) ' ' printScore];
            alllabs{j} = [num2str(uint8(inds_past(A(selInds(j)),1))) ' ' printScore ' ' ...
                num2str(uint8(inds_fut(A(selInds(j)),1))) ' ' ...
                num2str(uint8(thisinds_nb(j))) ' ' num2str(thisscores_nb(j), '%1.2f')];
            %end
            %alllabs{j} = '';        %% added this plug for generating results for CVPR supplementary deadline
        end
        % +1 as assuming first is always '0' (even for init)
        mimg{unids(jj)+1} = montage_list_w_text2(allimgs, alllabs, 2);
        mlab{unids(jj)+1} = num2str(numel(A));
        %imwrite(mimg{unids(jj)+1}, savename);
     %end
end
%mim = montage_list_w_text2(mimg, mlab, 2, [], [], [3000 3000 3]);
%imwrite(mim, fullsavename);
myprintfn;

function [im, box, x1, y1] = croppos_nopad(im, box)
% [newim, newbox] = croppos(im, box) % Crop positive example to speed up latent search
% no pad as this is not to extract features but for visualization

padx = 0; pady = 0;
x1 = max(1, round(box(1) - padx));
y1 = max(1, round(box(2) - pady));
x2 = min(size(im, 2), round(box(3) + padx));
y2 = min(size(im, 1), round(box(4) + pady));

im = im(y1:y2, x1:x2, :);
box([1 3]) = box([1 3]) - x1 + 1;
box([2 4]) = box([2 4]) - y1 + 1;
