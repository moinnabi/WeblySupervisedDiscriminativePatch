function [mimg, mlab] = getMontagesForModel_latent(inds, inds_past, inds_fut, posscores,...
    possccalib, lbbox, pos, numToDisplay, numComps)

try
    
if isempty(numToDisplay)
    numToDisplay = 49;
end

if isempty(lbbox) % initialization 
    lbbox = zeros(numel(pos), 4);
    for j = 1:numel(pos)
        lbbox(j,:) = [pos(j).x1 pos(j).y1 pos(j).x2 pos(j).y2];
        [blah, fname, blah] = fileparts(pos(j).im);
        posscores(j,1) = j;                
        if ~isempty(strfind(fname, '_'))
            [balh fname] = myStrtokEnd(fname, '_');
        end        
        % note: works only for 2007 naming convention, doesn't work if it has '_'
        posscores(j,2) = str2num(fname);    
        possccalib(j,1) = str2num(fname);                    
        possccalib(j,2) = j;
    end
end

[mimg, mlab] = deal(cell(numComps+1,1));    % +1 to accomodate 0 index    
for jj=1:numel(mimg)                        % initialize to dummy
    mimg{jj} = ones(10,10,3);
    mlab{jj} = ' ';
end

numpos = numel(pos);

%unids = unique(inds(:,1));
unids = unique(inds(:)); %31May12
unids(unids == 0) = [];
for jj = 1:length(unids)    
        myprintf(jj);
        A = find(inds == unids(jj));
        thisNum = min(numToDisplay, numel(A));
        allimgs = cell(thisNum,1); 
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
            allimgs{j} = croppos_nopad_nocrop(im, thisbbox(j,:));   % 7Jan12
            
            printScore = num2str(thisscores(j), '%1.2f');
            if unids(jj) == 0, printScore = ['* ' printScore]; end
            %if size(inds,2) == 1, printScore = num2str(thisscores(j)); end
            
            printSccalib = num2str(thissccalib(j), '%1.2f');
            if unids(jj) == 0, printSccalib = ['* ' printSccalib]; end
            %if size(inds,2) == 1, printSccalib = num2str(thissccalib(j)); end
            
            %printScore2 = num2str(thisscores_nb(j), '%1.2f');
            %%if size(inds,2) == 1, printScore2 = num2str(thisscores_nb(j)); end
            %printSccalib2 = num2str(thissccalib_nb(j), '%1.2f');
            %%if size(inds,2) == 1, printSccalib2 = num2str(thissccalib_nb(j)); end
                        
            %if inds_past(A(selInds(j))) == unids(jj), alllabs{j} = ['0 ' printScore];
            %else
            %%%alllabs{j} = [num2str(inds_past(A(selInds(j)))) ' ' printScore];
            pastinds = thisinds_past(j,:);
            pastinds = pastinds(pastinds ~= 0);
            futinds = thisinds_fut(j,:);
            futinds = futinds(futinds~=0);
            othrinds = thisinds_nb(j,:);
            othrinds = othrinds(othrinds~=0);
            %alllabs{j,1} = [num2str(uint8(pastinds)) ' ' printScore ' ' ...
            %    num2str(uint8(futinds)) '*' num2str(uint8(othrinds))];
            %alllabs{j,2} = [num2str(uint8(pastinds)) ' ' printSccalib ' ' ...
            %    num2str(uint8(futinds)) '*' num2str(uint8(othrinds))];
            
            % changed 24Feb12
            if ~isempty(othrinds), othrinds = othrinds(1); end  
            alllabs{j,1} = [num2str(uint8(othrinds)) ' ' printScore ' ' printSccalib];
            alllabs{j,2} = [num2str(uint8(pastinds)) ' = ' num2str(uint8(futinds))];            
            %alllabs{j,2} = [num2str(uint8(inds_past(A(selInds(j)),1))) ' ' printSccalib ' ' ...
            %    num2str(uint8(inds_fut(A(selInds(j)),1))) ' ' ...
            %    num2str(uint8(thisinds_nb(j))) ' ' printSccalib2];
            %end
        end
        % +1 as assuming first is always '0' (even for init)
        mimg{unids(jj)+1} = single(montage_list_w_text2L(allimgs, alllabs, 2, '', [1 1 1], [750 750 3]));        
        mlab{unids(jj)+1} = num2str(numel(A));        
end
myprintfn;

catch
    disp(lasterr); keyboard;
end

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

