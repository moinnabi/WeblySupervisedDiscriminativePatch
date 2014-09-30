function [mimg, mlab, mimg_avg] = get3x3MontagesForModel_latent_wsup(inds, inds_past, inds_fut, posscores,...
    possccalib, lbbox, pos, numToDisplay, numComps, model)
% from getMontagesForModel_latent_wsup

try
    
numToDisplay = 9;

[mimg, mlab, mimg_avg] = deal(cell(numComps+1,1));    % +1 to accomodate 0 index
for jj=1:numel(mimg)                        % initialize to dummy
    mimg{jj} = ones(10,10,3);
    mimg_avg{jj} = ones(10,10,3);
    mlab{jj} = ' ';
end

numpos = numel(pos);

unids = unique(inds(:)); %31May12
unids(unids == 0) = [];
for jj = 1:length(unids)
    myprintf(unids(jj));
    
    A = find(inds == unids(jj));
    thisNum = min(numToDisplay, numel(A));
    allimgs = cell(thisNum,1);
    allimgs_foravg = cell(thisNum,1);
    alllabs = cell(thisNum,2);
    %alllabs = cell(thisNum,1);
    
    if ~isempty(possccalib) %~isempty(posscores)
        %thisscores_tmp = posscores(A,1);
        thisscores_tmp = possccalib(A);
        [sval sinds] = sort(thisscores_tmp, 'descend');
        selInds = sinds(1:thisNum);
    else
        randInds = randperm(numel(A));
        selInds = randInds(1:thisNum);
        %sval = zeros(thisNum, 1);
    end
    
    posindex_col = floor(A(selInds)/(numpos+1));
    %posindex_off = posindex_col+mod(A(selInds),numpos+1);
    % updated 24Mar12
    posindex_off = mod(A(selInds),numpos);
    posindex_off(posindex_off==0) = numpos;
    spos = pos(posindex_off);
    
    siz = model.filters(unids(jj)).size.*40;
    
    %thisbbox = lbbox(posindex_off,repmat((posindex_col*4),1,4)+repmat(1:4, size(posindex_col,1), 1));
    thisbbox = zeros(size(posindex_col,1),4);
    for j=1:size(posindex_col,1)
        thisbbox(j,:) = lbbox(posindex_off(j), posindex_col(j)*4 + [1:4]);
    end
    thisscores = posscores(A(selInds));
    thissccalib = possccalib(A(selInds));
    thisinds_nb = inds(posindex_off, :);
    thisinds_past = inds_past(posindex_off, :);
    thisinds_fut = inds_fut(posindex_off, :);
    for j=1:thisNum
        im = color(imreadx(spos(j)));
        allimgs{j} = draw_box_image(im, thisbbox(j,:));
        allimgs_foravg{j} = imresize(croppos_nopad_nocrop(im, thisbbox(j,:)), siz);
        
        printScore = num2str(thisscores(j), '%1.2f');
        if unids(jj) == 0, printScore = ['* ' printScore]; end
        
        printSccalib = num2str(thissccalib(j), '%1.2f');
        if unids(jj) == 0, printSccalib = ['* ' printSccalib]; end
        
        pastinds = thisinds_past(j,:);
        pastinds = pastinds(pastinds ~= 0);
        futinds = thisinds_fut(j,:);
        futinds = futinds(futinds~=0);
        othrinds = thisinds_nb(j,:);
        othrinds = othrinds(othrinds~=0);
        
        if ~isempty(othrinds), othrinds = othrinds(1); end
        alllabs{j,1} = [num2str(uint8(othrinds)) ' ' printScore ' ' printSccalib];
        alllabs{j,2} = [num2str(uint8(pastinds)) ' = ' num2str(uint8(futinds))];
    end
    % +1 as assuming first is always '0' (even for init)
    mimg{unids(jj)+1} = single(montage_list(allimgs, 2, [1 1 1]));
    mlab{unids(jj)+1} = num2str(numel(A));
    
    % create averageImage
    mimg_avg{unids(jj)+1} = single(mean(cat(4,allimgs_foravg{:}),4))/255;
end
myprintfn;

catch
    disp(lasterr); keyboard;
end
