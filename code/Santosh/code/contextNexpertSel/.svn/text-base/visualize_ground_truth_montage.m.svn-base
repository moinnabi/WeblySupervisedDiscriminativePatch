function visualize_ground_truth_montage(cachedir, cls, datasettype, year)

try
    
conf = voc_config('pascal.year', year, 'paths.model_dir', cachedir);
VOCopts = conf.pascal.VOCopts;
gtsubdir  = 'p33tn';

[gtids,t]=textread(sprintf(VOCopts.imgsetpath,datasettype),'%s %d');
%load([cachedir cls '_gt_anno_' datasettype '_' year], 'gt');
[gt, npos] = get_ground_truth_unsup(cachedir, cls, datasettype, year, gtsubdir);

[imgIds, bboxes] = deal([]);
for i=1:numel(gt)
    if ~isempty(gt(i).boxes) && ~gt(i).diff
        imgIds = [imgIds; gtids(i)];
        bboxes = [bboxes; gt(i).boxes(:,1)'];
    end
end

disp(' displaying results');
detressavedir = [myStrtokEnd(conf.pascal.VOCopts.annopath,'/') '/../JPEGImages_annotated/' gtsubdir '/']; mymkdir(detressavedir);
nImgMont = 49;
totalNimg = 1000;
intensty = [0 255 0];
ftag = ['all'];

%resimg = cell(nImgMont,1); ressc = cell(nImgMont,1);
resimg = [];
ressc = [];
k = 1;
for j=1:min(totalNimg,length(imgIds))
    myprintf(j);
    %imgname = [imgannodir '/JPEGImages/' ids{imgIds(j)} '.jpg']; 
    imgname = [VOCopts.imgpath(1:end-6) '/' imgIds{j} '.jpg'];
    resimg{k,1} = draw_box_image(color(imread(imgname)), bboxes(j,:), intensty);    
    ressc{k,1} = strrep(imgIds{j}, '_', '-');
    if k == nImgMont
       mimg = montage_list_w_text2(resimg, ressc, 2, [], [1 1 1], [2000 2000 3]);
       imwrite(mimg, [detressavedir '/' ftag '_' num2str(j-nImgMont+1, '%03d') '-' num2str(j, '%03d') '.jpg']);
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
    