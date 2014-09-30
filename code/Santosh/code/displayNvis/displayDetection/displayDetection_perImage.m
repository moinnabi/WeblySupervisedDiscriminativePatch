function displayDetection_perImage(cls, testset, cachedir, year, suffix, modelname)
% from displayDetection_rankedMontages

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;

if nargin < 6
    modelname = '';
end

conf = voc_config('pascal.year', year, 'eval.test_set', testset);
VOCopts  = conf.pascal.VOCopts;

disp(['displayDetection_perImage(''' cls ''',''' testset ''',''' cachedir ''',''' year ''',''' suffix ''',''' modelname ''');']);

if exist('/home/ubuntu/JPEGImages/','dir')  % for aws
    VOCopts.imgpath = '/home/ubuntu/JPEGImages/%s.jpg';
end

detressavedir = [cachedir '/display_' testset '_' year '_' suffix '/']; mymkdir(detressavedir);
detressavedir = [cachedir '/display_' testset '_' year '_' suffix '/images/']; mymkdir(detressavedir);

numBBtoDisplay = 5;

if 1
ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');
else
testset = [testset(1:end-4) '_labels.txt'];
[ids, gt] = textread(sprintf(VOCopts.imgsetpath, testset), '%s %d');
ids = ids(gt == 1);
end

if isempty(modelname)
    disp('loading final (parts) boxes');
    load([cachedir cls '_boxes_' testset '_' suffix '.mat'], 'ds', 'bs');
    load([cachedir cls '_final' '.mat'], 'model');    
else
    disp('loading mix/joint (no parts) boxes');
    load([cachedir cls '_boxes_' testset '_' suffix '_' modelname '.mat'], 'ds', 'bs');
    load([cachedir cls '_' modelname '.mat'], 'model');    
end
if ~exist('bs', 'var'), bs = ds; end

ls='g';

mymatlabpoolopen;
parfor f=1:numel(ids)
%for f=1:numel(ids)
    myprintf(f);    
    if ~isempty(ds{f})             
        % read image
        I=imread([VOCopts.imgpath(1:end-6) '/' ids{f} '.jpg']);
        
        clf;
        imagesc(I);
        hold on;
        for j=1:min(size(ds{f},1), numBBtoDisplay)
            bb=ds{f}(j,1:4);  
            pname = model.phrasenames{bs{f}(j,end-1)};
            pname = strrep(pname, '_', ' ');  
            lbl = [num2str(j) ' ' pname];   % also show j to know ordering
            plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),ls,'linewidth',2);
            text(bb(1),bb(2),lbl,'color','k','backgroundcolor',ls(1),...
                'verticalalignment','top','horizontalalignment','left','fontsize',8);
        end
        hold off;
        axis image off;
                
        mysaveas([detressavedir '/' strtok(ids{f},'.') '.jpg']);                
    end    
end
myprintfn;

catch
    disp(lasterr); keyboard;
end
