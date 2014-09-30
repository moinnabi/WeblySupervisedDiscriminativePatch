function ds_top = get_dstop(cachedir, datatype, data_year, phrasenames, conf, modelname, objname)

if isempty(modelname)    
    fname = [cachedir '/ds_topInfo_' datatype '_' data_year '.mat'];
else    
    fname = [cachedir '/ds_topInfo_' datatype '_' data_year '_' modelname '.mat'];
end

try
    load(fname, 'ds_top');
    ds_top;
catch
    disp(' get all dets across all ngrams');
    % takes an hour to load for large files, alternate version is coded and commented
    [ds_all, bs_all] = getBoxes_helper(cachedir, datatype, data_year, phrasenames, modelname);
    ids = textread([conf.pascal.VOCopts.imgsetpath(1:end-6) '/baseobjectcategory_' objname '_' datatype '.txt'], '%s');
    numcls = numel(phrasenames);
    numids = length(ids);

    disp(' include image #id and comp info of every (trng) image');
    dinds = zeros(numids,1);
    dcinds = zeros(numids,1);
    opts = conf.pascal.VOCopts;
    for c=1:numcls 
        myprintf(c, 10);
        if strcmp(datatype, 'val1')         % val1 is composed of all "train" positives + voc2007val negatives
            [thisids, tgt] = textread(sprintf(opts.clsimgsetpath, phrasenames{c}, 'train'), '%s %d'); 
            % train is composed of train positives and voc2007train negs (ok here as only select train positives)
            thisids = thisids(tgt == 1);
        elseif strcmp(datatype, 'val2')     % val1 is composed of all "val" positives + voc2007val negatives
            [thisids, tgt] = textread(sprintf(opts.clsimgsetpath, phrasenames{c}, 'val'), '%s %d');
            thisids = thisids(tgt == 1);
        end
        iset = find(doStringMatch(ids, thisids));
        if any(dinds(iset)) 
            error('some image in this set was already assigned to an ngram');
        elseif isempty(iset)
            disp('how come no images for this ngram?'); keyboard;
        else
            dinds(iset) = c;
        end
        thisbs = bs_all{c};
        %[~, thisbs] = getIndBoxes_helper(cachedir, datatype, data_year, phrasenames{c}, modelname);
        for j=1:numel(iset)
            if ~isempty(thisbs) && ~isempty(thisbs{iset(j)})
                dcinds(iset(j)) = thisbs{iset(j)}(1,end-1);
            end
        end
    end
    myprintfn;
    
    disp(' just keep the top most box per image (assume boxes are sorted)');
    [ds_top, sind_top] = deal(cell(numcls,1));    
    %numdims = size(cat(1,ds_all{1}{:}),2)+4;    %+4 as you add 4 new dims
    parfor c=1:numcls
        myprintf(c,10);
        thisds = ds_all{c}; thisbs = bs_all{c};
        %[thisds, thisbs] = getIndBoxes_helper(cachedir, datatype, data_year, phrasenames{c}, modelname);
        if ~isempty(thisds)
            numdims = size(cat(1,thisds{:}),2)+4;    %+4 as you add 4 new dims (moved it here as ds_all{1} can be empty
            ds_top{c} = -10*ones(numids,numdims);       % one box per image (if not box, set to low value of -10)
            for i=1:numids
                if ~isempty(thisds{i})
                    % [x1 y1 x2 y2 imgid whichCompFired imgBelongsToWhichCompOfNgam imgBelongsToWhichNgram detScore]
                    ds_top{c}(i,:) = [thisds{i}(1,1:end-1) i thisbs{i}(1,end-1) dcinds(i) dinds(i) thisds{i}(1,end)];
                end
            end
            [~, sind_top{c}] = sort(ds_top{c}(:,end), 'descend');
            ds_top{c} = ds_top{c}(sind_top{c},:);
        end
    end
    myprintfn;
    
    save(fname, 'ds_top', 'sind_top', '-v7.3');    
end
