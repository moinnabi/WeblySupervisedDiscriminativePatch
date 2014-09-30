function context_train_carlos_wsup_displayBoxes(cachedir, train_set, train_year, cls, phrasenames, CLSFR)

try
global VOC_CONFIG_OVERRIDE;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = train_year;
conf = voc_config('pascal.year', train_year);
cachedir = conf.paths.model_dir;
VOCopts = conf.pascal.VOCopts;

disp(['context_train_carlos_wsup_displayBoxes(''' cachedir ''',''' train_set ''',''' train_year ''',''' cls ''','' phrasenames '',''' num2str(CLSFR) ''')' ]);

disp('Get training data');
[XX, ds_imall] = context_data_carlos_wsup(cachedir, train_set, train_year, phrasenames);
ids = textread(sprintf(conf.pascal.VOCopts.imgsetpath, train_set), '%s');

if CLSFR == 1
    clsfrtype = 'KSVMnoSIG';
elseif CLSFR == 2
    clsfrtype = 'KRBFSVMnoSIG';
elseif CLSFR == 3
    clsfrtype = 'K5SVMnoSIG';
end

if strcmp(train_set, 'val2')
    savecode = 'context';
elseif strcmp(train_set, 'val1')
    savecode = 'val1context';
end

gtruthname = cls;

load([cachedir '/' cls '_' savecode '_' clsfrtype '.mat'], 'roc', 'model');

for i=1:numel(ds_imall)
    ds_imall{i}(:,end+1) = i;
end

disp([' Get labels for the training data for class ' cls]);
[YY, YYolap] = context_labels_wsup(cachedir, gtruthname, ds_imall, train_set, train_year);
        
disp(' Collect training feature vectors and labels into a single matrix and vector');
X = cell2mat(XX(:));
Y = cell2mat(YY(:));
boxes = cell2mat(ds_imall(:));
Yolap = cell2mat(YYolap(:));
       
disp(' Remove dont care examples');
I = find(Y == 0);
Y(I) = [];
Yolap(I) = [];
X(I,:) = [];
boxes(I,:) = [];

% compute average feature responses
% scores not passed through sigmoid
% no location info
% long descriptor size


if 0 % display
nImgMont = 49;
totalNimg = 300;
intensty = [255 0 0];

[~, ~, allScores] = svmpredict(ones(size(X,1), 1), X, model);
allScores = model.Label(1)*allScores;

imgIds = ids(boxes(:,end));
bboxes = boxes(:,1:4);
allComps = boxes(:,5);
allLabels = Y;
allOlap = Yolap;

[allScores, sInds] = sort(allScores, 'descend');
imgIds = imgIds(sInds, :);
bboxes = bboxes(sInds, :);
allComps = allComps(sInds, :);
allLabels = allLabels(sInds, :);
allOlap = allOlap(sInds, :);
detressavedir = [cachedir '/traindisplay/']; mymkdir(detressavedir);
ftag = ['all' '_' train_set];

resimg = [];
ressc = [];
k = 1;
for j=1:min(totalNimg,length(imgIds))
    myprintf(j);    
    imgname = [VOCopts.imgpath(1:end-6) '/' imgIds{j} '.jpg'];
    resimg{k,1} = draw_box_image(color(imread(imgname)), bboxes(j,:), intensty);
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
end

catch
    disp(lasterr); keyboard;
end
