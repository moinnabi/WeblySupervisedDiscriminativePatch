function displayDetection_rankedMontages_v5(cls, testset, cachedir, year, suffix, modelname, postag)
% from displayDetection_rankedMontages

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;

if nargin < 6
    modelname = '';
end

if nargin < 6
    postag = 'NOUN';
end

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
VOCopts  = conf.pascal.VOCopts;

disp(['displayDetection_rankedMontages_v5(''' cls ''',''' testset ''',''' cachedir ''',''' year ''',''' suffix ''',''' modelname ''',''' postag ''');']);

if exist('/home/ubuntu/JPEGImages/','dir')  % for aws
    VOCopts.imgpath = '/home/ubuntu/JPEGImages/%s.jpg';
end

detressavedir = [cachedir '/display_' testset '_' year '_' suffix '/']; mymkdir(detressavedir);

nImgMont = 100;
totalNimg = nImgMont*5;
intensty = [255 0 0];

%ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
if strcmp(postag, 'NOUN')
    ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
elseif strcmp(postag, 'VERB')
    ids = textread(sprintf(VOCopts.action.imgsetpath, testset), '%s');
end

if isempty(modelname)
    disp('loading final (parts) boxes');
    load([cachedir cls '_boxes_' testset '_' suffix '.mat'], 'ds', 'bs', 'ds_sum');
    ftag = ['all' '_' testset '_' suffix];
    prname = [cachedir cls '_pr_' testset '_' suffix '.mat'];
else
    disp('loading mix (no parts) boxes');
    load([cachedir cls '_boxes_' testset '_' suffix '_' modelname '.mat'], 'ds', 'bs', 'ds_sum');
    ftag = ['all' '_' testset '_' suffix '_' modelname];
    prname = [cachedir cls '_pr_' testset '_' suffix '_' modelname '.mat'];
end
if ~exist('bs', 'var'), bs = ds; end

if strcmp(suffix, '9990')
    try load(prname, 'labels', 'olap'); labels;
    catch disp('did not find labels'); labels = []; end
else
    try load(prname, 'labels_base', 'olap_base'); labels=labels_base; olap = olap_base;
    catch disp('did not find labels'); labels = []; olap = []; end
end

%{
disp('doing hoinds'); keyboard;
hoinds = textread(sprintf(VOCopts.imgsetpath, 'hoinds'), '%d');
ttinds = setdiff(1:numel(ids), hoinds);

disp('avoiding dups');
dupinds = textread(sprintf(VOCopts.imgsetpath, 'dupinfo'), '%d');
ttinds = setdiff(ttinds, dupinds);

disp('avoiding unlabeled pos images');
unlabinds = textread(sprintf(VOCopts.imgsetpath, 'test_unlabinds'), '%d');
ttinds = setdiff(ttinds, unlabinds);

ids = ids(ttinds);
ds = ds(ttinds);
bs = bs(ttinds);
%}
%load([cachedir cls '_prhoinds_' testset '_' suffix '.mat'], 'labels', 'olap');
%labels = labels_sum; olap = olap_sum;

%{
[bbox, scores, comps, allIds] = deal(cell(length(ids),1));
for i = 1:length(ids)
    if ~isempty(ds{i})
        bbox{i} = ds{i}(:,1:4);
        scores{i} = ds{i}(:,end);
        comps{i} = bs{i}(:,end-1);
        allIds{i} = repmat(ids{i}, [size(ds{i},1) 1]); %j*ones(length(result(j).scores),1)
    end
end
% get sorted inds
allScores = cat(1, scores{:});
allComps = cat(1, comps{:});
imgIds = cat(1,allIds{:});
bboxes = cat(1,bbox{:});
%}
%{
[imgIds, bboxes, allScores, allComps] = deal([]);
for i = 1:length(ids);
    bbox = ds{i};
    pbox = bs{i};
    for j = 1:size(bbox,1)
        %fprintf(fid, '%s %f %d %d %d %d\n', ids{i}, bbox(j,end), bbox(j,1:4));
       imgIds = [imgIds; ids{i}];
       bboxes = [bboxes; bbox(j,1:4)];
       allScores = [allScores; bbox(j,end)];
       allComps = [allComps; pbox(j,end-1)];
    end
end
%}

fid = fopen(sprintf(VOCopts.detrespath, 'comp3', cls), 'w');
for i = 1:length(ids);
    bbox = ds{i};
    pbox = bs{i};
    for j = 1:size(bbox,1)
        fprintf(fid, '%s %f %d %d %d %d %d\n', ids{i}, bbox(j,end), pbox(j,end-1), bbox(j,1:4));
    end
end
fclose(fid);
[imgIds,allScores,allComps,b1,b2,b3,b4]=textread(sprintf(VOCopts.detrespath,'comp3',cls),'%s %f %f %f %f %f %f');
bboxes=[b1 b2 b3 b4];

if ~isempty(labels)
    allLabels = labels;
    allOlap = olap;
else
    allLabels = zeros(size(bboxes,1),1);
    allOlap = -1*ones(size(bboxes,1),1);
end

disp(' displaying results');
[allScores, sInds] = sort(allScores, 'descend');
imgIds = imgIds(sInds, :);
bboxes = bboxes(sInds, :);
allComps = allComps(sInds, :);
allLabels = allLabels(sInds, :);
allOlap = allOlap(sInds, :);

%resimg = cell(nImgMont,1); ressc = cell(nImgMont,1);
resimg = [];
ressc = [];
k = 1;
for j=1:min(totalNimg,length(imgIds))
    myprintf(j);
    %imgname = [imgannodir '/JPEGImages/' ids{imgIds(j)} '.jpg']; 
    imgname = [VOCopts.imgpath(1:end-6) '/' imgIds{j} '.jpg'];
    resimg{k,1} = draw_box_image(color(imread(imgname)), bboxes(j,:), intensty);
    %resimg{k,1} = imresize(draw_box_image(color(imread(imgname)), bboxes(j,:), intensty), [256 NaN]);
    ressc{k,1} = [num2str(allScores(j), '%1.3f') ' ' num2str(allComps(j)) ' ' num2str(allOlap(j), '%0.1f') ' ' num2str(allLabels(j))];
    ressc{k,2} = strrep(imgIds{j}, '_', '-');
    if k == nImgMont
       mimg = montage_list_w_text2L(resimg, ressc, 2, [], [1 1 1], [2000 2000 3]);
       imwrite(mimg, [detressavedir '/' ftag '_' num2str(j-nImgMont+1, '%03d') '-' num2str(j, '%03d') '.jpg']);
       k=1;
       clear resimg ressc;
       continue;
    else
    k = k+1;
    end
end
myprintfn;

imlist = mydir([detressavedir '/' ftag '_*.jpg'],1);
for ll=1:numel(imlist)
    mimgj{ll} = imread(imlist{ll});
end
mimg = montage_list(mimgj, 2, [1 1 1], [numel(imlist)*2000 2000 3], [numel(imlist), 1]);
imwrite(mimg, [detressavedir '/jointMontage.jpg']);


% plotfname = [detressavedir '/roc_' ftag '.jpg']; 
% %if ~exist(plotfname,'file') 
%     disp('printing roc plot');
%     plotROC(roc);
%     saveas(gcf, plotfname);
% %end

catch
    disp(lasterr); keyboard;
end
