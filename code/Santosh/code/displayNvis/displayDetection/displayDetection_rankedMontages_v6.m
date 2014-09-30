function displayDetection_rankedMontages_v6(cls, testset, cachedir, year, suffix, phrasenames)
% from displayDetection_rankedMontages

try

global VOC_CONFIG_OVERRIDE;
%VOC_CONFIG_OVERRIDE = @my_voc_config_override;
VOC_CONFIG_OVERRIDE.paths.model_dir = cachedir;
VOC_CONFIG_OVERRIDE.pascal.year = year;
conf = voc_config('pascal.year', year, 'eval.test_set', testset);
VOCopts  = conf.pascal.VOCopts;

detressavedir = [cachedir '/display/']; mymkdir(detressavedir);

nImgMont = 100;
totalNimg = 1000;
intensty = [255 0 0];
ftag = ['all2' '_' testset];

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

load([cachedir cls '_boxes_' testset '_' suffix '.mat'], 'ds', 'bs', 'ds_sum');
if ~exist('bs', 'var'), bs = ds; end

fname = [tempname '.jpg'];

scs = zeros(numel(ds),1);
for i=1:numel(ds)    
    scs(i) = ds{i}(1,end);
end
[~, sind] = sort(scs, 'descend');

ds = ds(sind);
ids = ids(sind);

resimg = [];
ressc = [];
k = 1;

for i=1:min(totalNimg,length(ds))
    myprintf(i,10);

    %{
    I = imread([VOCopts.imgpath(1:end-6) '/' ids{i} '.jpg']);    
    clf;
    imagesc(I);
    hold on;
    for j=1:size(ds{i},1)
        bb=ds{i}(j,1:4); 
        ci=ds{i}(j,end-1);
        sc=ds{i}(j,end);
        lbl = [phrasenames{ci} ' ' num2str(sc, '%0.2f')];
        
        plot(bb([1 3 3 1 1]),bb([2 2 4 4 2]),'g','linewidth',2);
        t_handle = text(bb(1),bb(2),lbl,'color','k','backgroundcolor','g',...
            'verticalalignment','top','horizontalalignment','left');              
        set(t_handle, 'FontSize', 20);
    end
    hold off;
    axis image off;
    mysaveas(fname);    
    %savefig(gcf, fname);
        
    resimg{k,1} = imread(fname);
    ressc{k,1} = strrep(ids{i}, '_', '-');
    %}
    
    imgname = [VOCopts.imgpath(1:end-6) '/' ids{i} '.jpg']; 
    resimg{k,1} = draw_boxes_image(color(imread(imgname)), ds{i}, intensty);    
    ressc{k,1} = strrep(ids{i}, '_', '-');
    
    if k == nImgMont
        mimg = montage_list_w_text2(resimg, ressc, 2, [], [1 1 1], [3000 3000 3]);        
        imwrite(mimg, [detressavedir '/' ftag '_' num2str(i-nImgMont+1, '%03d') '-' num2str(i, '%03d') '.jpg']);
        k=1;
        clear resimg ressc;        
        continue;
    else
        k = k+1;
    end        
end
myprintfn;

catch
    disp(lasterr); keyboard;
end

