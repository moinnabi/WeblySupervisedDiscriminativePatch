%Load data and models
dir = '/projects/grail/santosh/objectNgrams/results/ngram_models_part1/horse/kmeans_6/zebra_horse/';
load([dir,'zebra_horse_train_9990.mat']);
load([dir,'zebra_horse_mix.mat']);

i = 100;
img = uint8(imread(impos(i).im));
imshow(img);
bb_object = [impos(i).boxes(1) , impos(i).boxes(2) , impos(i).boxes(3)-impos(i).boxes(1) , impos(i).boxes(4)-impos(i).boxes(2)];

rectangle('Position',bb_object,'Edgecolor','b'); 
hold;

% Random BB
[im_y,im_x,im_c] = size(img);
bbw = [15 im_x]; %Error might occur!
bbh = [15 im_y];

n_1 = 20 ;
rand_rec_1 = randombb(im_x,im_y,bbw,bbh,n_1);
rand_rec_2 = bbintersect( bb_object, rand_rec_1);
rand_rec = rand_rec_2((rand_rec_2(:,3)./rand_rec_2(:,4) > 0.3 ),:);
[n , four] = size(rand_rec);
for ind = 1:n rectangle('Position',rand_rec(ind,:),'Edgecolor','r'); end %BB visulization
hold off;

% Train E-SVM
%esvmmodfile = '/projects/grail/santosh/objectNgrams/results/tomasz_esvm/hog_covariance_pascal_voc2007_trainval.mat';   % move this path info to voc_config
%load(esvmmodfile, 'covstruct');

for ind = 1:n
%     img_crop = imcrop(img,rand_rec(ind,:));
%     imshow(img_crop);
    rand_window(1) = rand_rec(ind,1);
    rand_window(2) = rand_rec(ind,2);
    rand_window(3) = rand_rec(ind,1) + rand_rec(ind,3);
    rand_window(4) = rand_rec(ind,2) + rand_rec(ind,4);
    
    positive(ind).im = [pos(i).im];
    positive(ind).x1 = rand_window(1); positive(ind).y1 = rand_window(2); positive(ind).x2 = rand_window(3); positive(ind).y2 = rand_window(4);
    positive(ind).boxes = [positive(ind).x1,positive(ind).x2,positive(ind).y1,positive(ind).y2];
    positive(ind).flip = 0; positive(ind).trunc = 0; positive(ind).dataids = ind; positive(ind).size = 123456;
    pos_examplar = positive(ind);
    ind
    rectangle('Position',rand_rec(ind,:),'Edgecolor','g');
    [ esvmw , featMat ] = fastesvm( pos_examplar , covstruct);    %pos_examplar_old = pos(i);

end

rectangle('Position',rand_rec(ind,:),'Edgecolor','r');
[ esvmw , feats ] = fastesvm( pos_examplar , covstruct);

% Patch Detection
PatchDet

% Re-train ESVM

% Patch Detection
