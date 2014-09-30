function calibrateNgramModels_noNMSKeepTop(cachedir, baseobjname, phrasenames, ngimgModeldir_obj, testset, suffix, nmsolap)

try
    
%ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
boxes = load([ngimgModeldir_obj phrasenames{1} '/' phrasenames{1} '_boxes_' testset '_' suffix '.mat'], 'ds');
numids = numel(boxes.ds);

disp('loading boxes and calibrating');
% merge all ngram dets
[ds, bs, ds_sum] = deal(cell(numids,1));
for f=1:numel(phrasenames)
    myprintf(f);
    boxes = load([ngimgModeldir_obj '/' phrasenames{f} '/' phrasenames{f} '_boxes_' testset '_' suffix '.mat'], 'ds', 'bs', 'ds_sum');
    for i=1:numids
        if ~isempty(boxes.ds{i})
            ds{i} = [ds{i}; boxes.ds{i}(:,1:end-1) f*ones(size(boxes.ds{i},1), 1) boxes.ds{i}(:,end)];
            bs{i} = [bs{i}; boxes.bs{i}(:,1:end-1) f*ones(size(boxes.ds{i},1), 1) boxes.bs{i}(:,end)];
        end        
    end
end
myprintfn;

for i=1:numids
    myprintf(i, 10);
    %nmsinds = nms(ds{i}, nmsolap);
    [blah, blah, nmsinds] = bboxNonMaxSuppression(ds{i}(:,1:4), ds{i}(:,end), nmsolap);
    ds{i} = ds{i}(nmsinds,:);
    bs{i} = bs{i}(nmsinds,:);    
end
myprintfn;

%disp('here');keyboard;

%{
disp([' keep only ' num2str(NumToKeep) ' highest scoring detections']);
data = cell2mat(ds);
if size(data,1) > NumToKeep
    s = data(:,end);
    s = sort(s);
    v = s(end-NumToKeep+1);
    for i = 1:numids;
        if ~isempty(ds{i})
            I = find(ds{i}(:,end) >= v);
            ds{c}{i} = ds{c}{i}(I,:);
            bs{c}{i} = bs{c}{i}(I,:);
        end
    end
end
myprintfn;
%}

save([cachedir '/' baseobjname '_topboxesnonms_' testset '_' suffix '.mat'], 'ds', 'bs', 'nmsolap');

catch
    disp(lasterr); keyboard;
end
