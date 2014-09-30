function calibrateNgramModels(cachedir, baseobjname, phrasenames, ngimgModeldir_obj, testset, valset, suffix, calibsuffix, nmsolap)

try
disp(['nmsolap is ' num2str(nmsolap)]);
    
%ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
boxes = load([ngimgModeldir_obj phrasenames{1} '/' phrasenames{1} '_boxes_' testset '_' suffix '.mat'], 'ds');
numids = numel(boxes.ds);

gtsubdir = 'p33tn';

disp('loading boxes and calibrating');
% merge all ngram dets
[ds, bs, ds_sum] = deal(cell(numids,1));
for f=1:numel(phrasenames)
    myprintf(f);
    boxes = load([ngimgModeldir_obj '/' phrasenames{f} '/' phrasenames{f} '_boxes_' testset '_' suffix '.mat'], 'ds', 'bs', 'ds_sum');
    %if 0
    %try load([ngimgModeldir_obj '/' phrasenames{f} '/' phrasenames{f} '_' calibsuffix '_' valset '.mat'], 'sigAB');
    %catch sigAB = [];end        %disp([num2str(f) ' loading failed of sigAB']); 
    %else
    try load([ngimgModeldir_obj '/' phrasenames{f} '/' phrasenames{f} '_' calibsuffix '_' gtsubdir valset '_' baseobjname '.mat'], 'sigAB');
    catch fprintf('no'); continue; end
    %end
    sigAB_all{f} = sigAB;
    for i=1:numids
        if ~isempty(boxes.ds{i})
            if ~isempty(sigAB)
                thiscomp = boxes.bs{i}(:,end-1);                
                boxes.ds{i}(:,end) = 1 ./ (1+exp(sigAB(thiscomp,1).*boxes.ds{i}(:,end)+sigAB(thiscomp,2))); 
            end
            ds{i} = [ds{i}; boxes.ds{i}(:,1:end-1) f*ones(size(boxes.ds{i},1), 1) boxes.ds{i}(:,end)];
            bs{i} = [bs{i}; boxes.bs{i}(:,1:end-1) f*ones(size(boxes.ds{i},1), 1) boxes.bs{i}(:,end)];
        end        
    end
end
myprintfn;

% sumpooling
%ds_sum = ds;

%nmsolap = 0.25;

% do nms
for i=1:numids
    myprintf(i, 10);
    %nmsinds = nms(ds{i}, nmsolap);
    [blah, blah, nmsinds] = bboxNonMaxSuppression(ds{i}(:,1:4), ds{i}(:,end), nmsolap);
    ds{i} = ds{i}(nmsinds,:);
    bs{i} = bs{i}(nmsinds,:);    
end
myprintfn;
save([cachedir '/' baseobjname '_boxes_' testset '_' valset '_' suffix '.mat'], 'ds', 'bs', 'sigAB_all', 'nmsolap');

%{
for i=1:numids
    myprintf(i, 10);    
    ds_sum{i} = decodeDets(ds_sum{i});
    nmsinds = nms(ds_sum{i}, nmsolap);
    ds_sum{i} = ds_sum{i}(nmsinds,:);
end
myprintfn;
save([cachedir '/' baseobjname '_boxes_' testset '_' suffix '.mat'], 'ds_sum', '-append');
%}

catch
    disp(lasterr); keyboard;
end
