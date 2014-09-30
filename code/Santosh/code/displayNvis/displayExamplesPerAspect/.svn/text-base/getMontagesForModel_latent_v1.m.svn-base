function [mimg, mlab] = getMontagesForModel_latent_v1(inds, inds_past, inds_fut, posscores,...
    possccalib, lbbox, pos, numToDisplay, numComps)

if isempty(numToDisplay)
    numToDisplay = 49;
end

if isempty(lbbox) % initialization 
    lbbox = zeros(numel(pos), 4);
    for j = 1:numel(pos)
        lbbox(j,:) = [pos(j).x1 pos(j).y1 pos(j).x2 pos(j).y2];
        posscores(j,1) = j;
        possccalib(j,1) = j;
        [blah, fname, blah] = fileparts(pos(j).im);
        posscores(j,2) = str2num(fname);    % note: works only for 2007 naming convention, doesn't work if it has '_'
        possccalib(j,2) = str2num(fname);
    end
end

[mimg, mlab] = deal(cell(numComps+1,1));    % +1 to accomodate 0 index    
for jj=1:numel(mimg)                        % initialize to dummy
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
        allimgs = cell(thisNum,1); 
        alllabs = cell(thisNum,2);
        %alllabs = cell(thisNum,1);
        
        if ~isempty(possccalib)
        %if ~isempty(posscores)            
            %thisscores_tmp = posscores(A,1);
            thisscores_tmp = possccalib(A,1);
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
        thissccalib = possccalib(A(selInds),1);        
        if size(inds,2) > 1
            thisinds_nb = inds(A(selInds), 2);
            thisscores_nb = posscores(A(selInds),2);
            thissccalib_nb = possccalib(A(selInds),2);
        else
            thisinds_nb = inds(A(selInds), 1); 
            thisscores_nb = posscores(A(selInds),1);
            thissccalib_nb = possccalib(A(selInds),1);
        end
        %warptmp = warppos_display(model, spos);        
        for j=1:thisNum
            im = color(imreadx(spos(j)));
            %allimgs{j} = croppos_nopad(im, thisbbox(j,:));
            allimgs{j} = croppos_nopad_nocrop(im, thisbbox(j,:));   % 7Jan12
            %allimgs{j} = uint8(warptmp{j});
            
            printScore = num2str(thisscores(j), '%1.2f');
            if unids(jj) == 0, printScore = ['* ' printScore]; end
            if size(inds,2) == 1, printScore = num2str(thisscores(j)); end
            
            printSccalib = num2str(thissccalib(j), '%1.2f');
            if unids(jj) == 0, printSccalib = ['* ' printSccalib]; end
            if size(inds,2) == 1, printSccalib = num2str(thissccalib(j)); end
            
            printScore2 = num2str(thisscores_nb(j), '%1.2f');
            if size(inds,2) == 1, printScore2 = num2str(thisscores_nb(j)); end
            printSccalib2 = num2str(thissccalib_nb(j), '%1.2f');
            if size(inds,2) == 1, printSccalib2 = num2str(thissccalib_nb(j)); end
                        
            %if inds_past(A(selInds(j))) == unids(jj), alllabs{j} = ['0 ' printScore];
            %else
            %%%alllabs{j} = [num2str(inds_past(A(selInds(j)))) ' ' printScore];
            alllabs{j,1} = [num2str(uint8(inds_past(A(selInds(j)),1))) ' ' printScore ' ' ...
                num2str(uint8(inds_fut(A(selInds(j)),1))) ' ' ...
                num2str(uint8(thisinds_nb(j))) ' ' printScore2];
            alllabs{j,2} = [num2str(uint8(inds_past(A(selInds(j)),1))) ' ' printSccalib ' ' ...
                num2str(uint8(inds_fut(A(selInds(j)),1))) ' ' ...
                num2str(uint8(thisinds_nb(j))) ' ' printSccalib2];
            %end
        end
        % +1 as assuming first is always '0' (even for init)
        mimg{unids(jj)+1} = montage_list_w_text2L(allimgs, alllabs, 2);
        mlab{unids(jj)+1} = num2str(numel(A));
        %imwrite(mimg{unids(jj)+1}, savename);
     %end
end
myprintfn;

%%%%%%%%%%%%%%%%
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

%%%%%%%%%%%%%%%%
function [im, box, x1, y1] = croppos_nopad_nocrop(im, box)
% taken from croppos_nopad
% not doing the cropping in case it goes outside image limits as I want to
% retrain the zero paddinng that was 
padx = 0; pady = 0;
%x1 = max(1, round(box(1) - padx));
%y1 = max(1, round(box(2) - pady));
%x2 = min(size(im, 2), round(box(3) + padx));
%y2 = min(size(im, 1), round(box(4) + pady));
x1 = round(box(1) - padx);
y1 = round(box(2) - pady);
x2 = round(box(3) + padx);
y2 = round(box(4) + pady);

%im = im(y1:y2, x1:x2, :);
im = uint8(subarray(im, y1, y2, x1, x2, 0));   % pad with 0 as featpyramid also does so

box([1 3]) = box([1 3]) - x1 + 1;
box([2 4]) = box([2 4]) - y1 + 1;
