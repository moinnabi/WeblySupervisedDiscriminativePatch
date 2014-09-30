function demo
%%% This Demo is written for fast extraction of parts 

clear all;
%addpath
% addpath('bcp_release/');
% addpath('Santosh/');
% addpath('/projects/grail/moinnabi/eccv14/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/vis/');
% run bcp_release/setup.m
run bcp_release/startup;

%matlabpool open;

%Parameters
dir_main = '/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/';
dir_class = 'portrait_horse_super'; %'saddlebred_horse_super';
dir_data = [dir_main,dir_class,'/'];
dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
finalresdir = ['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/' dir_class '/']; mkdir(finalresdir);
numPatches = 25;
thresh = -1;

datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
try
    load(datafname, 'ps_all','I', 'bbox', 'models', 'models_all');
catch  
    %Load Data of Santosh
    load([dir_data,dir_class,'_mix.mat'], 'lbbox_mix', 'posscores_mix','inds_mix');
    load([dir_data,dir_class,'_train_9990.mat'], 'impos');
    load([dir_data,dir_class,'_mix_goodInfo2.mat'], 'selcomps');

    %Reform data
    ps_all = [];
    %comp_inf = [];
    comp_ind = ones(1,6); %number of components
    %j=1;
    for i = 1:2:length(impos)
        if posscores_mix(i) > thresh
            comp = inds_mix(i);
           
            %for comp = 1:6
                ps_all{comp,comp_ind(comp)}.I = impos(i).im;
                ps_all{comp,comp_ind(comp)}.component = inds_mix(i);
                %comp_inf(j) = inds_mix(i);
                ps_all{comp,comp_ind(comp)}.bbox = lbbox_mix(i,:);
                ps_all{comp,comp_ind(comp)}.cls = dir_class;
                ps_all{comp,comp_ind(comp)}.id = ps_all{comp,comp_ind(comp)}.I(end-15:end);
                %j=j+1;
            %end
            comp_ind(comp) = comp_ind(comp) +1;
            
        end
    end
    
    %binary vector showing which componenets are active for subcategory
    selected_comp = find(selcomps);
    num_sample_comp = comp_ind(selcomps == 1) - 1;
    
    for scomp = 1:length(selected_comp)
        ps = [];
        for scomp_in = 1:num_sample_comp(scomp)
            ps{1,scomp_in} = ps_all{selected_comp(scomp),scomp_in};
        end
        
        %run subcategory demo on ps_current
        
    
 
    %train_candidate_parts(ps,VOCopts,num)
    %part model
    disp('auto_get_part_fast');
    [I bbox gtbox] = auto_get_part_fast(VOCopts, ps, numPatches);
 
%     figure(1); clf;
%     for i=1:numPatches
%         subplot(sqrt(numPatches),sqrt(numPatches),i);
%         showboxes(imread(I{i}), [bbox{i}(1:4); gtbox{i}]);        
%     end
%     saveas(gcf, [finalresdir 'queryPatches.jpg']);
    
    disp('orig_train_elda');
    models = orig_train_elda(VOCopts, I, bbox, dir_class, dir_neg , 0, 1);
    for mod = 1:length(models)
        models_all{mod} = models{1,mod}.model;
    end
    
    %[s p f] = part_inference(imread(I{1}), models_all{1}, bbox{1}(1:4));
    
    save(datafname, 'ps','I', 'bbox', 'gtbox' ,'models', 'models_all');
end


detsfname = [finalresdir 'detsdata_' num2str(numPatches) '.mat'];
try
    load(detsfname, 'img_res');
catch
    disp('doing part inference');
    parfor i = 1:length(ps)
        disp([int2str(i),'/',int2str(length(ps))]);
        im_current = imread(ps{1,i}.I);
        bbox_current = ps{1,i}.bbox;
        [ps_detect{i}.scores ps_detect{i}.parts] = part_inference(im_current, models_all, bbox_current);
    end
%% defining Negative
    neg1 = load(['/projects/grail/santosh3/ngram_models/pedestrian/kmeans_6/pedestrian/pedestrian','_mix.mat'], 'lbbox_mix', 'posscores_mix');
    neg2 = load(['/projects/grail/santosh3/ngram_models/pedestrian/kmeans_6/pedestrian/pedestrian','_train_9990.mat'], 'impos');
    ng = [];
    j=1;
    for i = 1:2:length(neg2.impos)
        if neg1.posscores_mix(i) > thresh
            ng{1,j}.I = neg2.impos(i).im;
            %ps{1,i}.bbox = impos(i).boxes;     % it should be on output of Santosh code NOT grountruth e.g. %lbbox_mix(find(lbbox_mix(:,1) == 0),:)
            ng{1,j}.bbox = neg1.lbbox_mix(i,:);
            ng{1,j}.cls = 'negative';
            ng{1,j}.id = ng{1,j}.I(end-15:end);
            j=j+1;
        end
    end
    %%
    parfor i = 1:length(ng)
        disp([int2str(i),'/',int2str(length(ng))]);
        im_current = imread(ng{1,i}.I);
        bbox_current = ng{1,i}.bbox;
        [ng_detect{i}.scores ng_detect{i}.parts] = part_inference(im_current, models_all, bbox_current);
    end    
    
    save(detsfname, 'ps_detect','ng_detect');
end

% CBIR system based on scores of the parts    
    % Pre-processing 
    img_part_ps = [];
    for iim = 1:length(ps)
        img_part_ps = [img_part_ps; ps_detect{iim}.scores{:}];
    end
    
    img_part_ng = [];
    for iim = 1:length(ng)
        img_part_ng = [img_part_ng; ng_detect{iim}.scores{:}];
    end
    
    for patch = 1:numPatches
        part_score(1,patch) = sum(img_part_ps(:,patch)) - sum(img_part_ng(:,patch));
    end
    
[sortedValues_part,sortIndex_part] = sort(part_score,'descend');  %# Sort importance of the parts MAX
maxIndex_part = sortIndex_part(1:top_num_part);    
    
    
%Visualization for spatial consistancy
deform_param = [0.2 0.2]; % Automate it later deformation along w and h respectively

close all;
%figure;
top_num_part = 25;
consistent_example_num = 0;
%[sortedValues_part,sortIndex_part] = sort(sum(img_part,1),'descend'); %# Sort importance the parts
% [sortedValues_part,sortIndex_part] = sort(max(img_part),'descend');  %# Sort importance of the parts MAX
% maxIndex_part = sortIndex_part(1:top_num_part);

% Visualize parts
figure(1); clf;
for part= 1:25
    pa = maxIndex_part(part);
    subplot(sqrt(25),sqrt(25),part);
    showboxes(imread(I{pa}), [bbox{pa}(1:4); gtbox{pa}]);        
end
saveas(gcf, [finalresdir 'queryPatches.jpg']);
%
for part = 1:top_num_part
    close all;
    pa = maxIndex_part(part);
% for pa = 1:numPatches
    figure;
    figsize = 5;
    top_num_img = figsize * (figsize-1);
    [sortedValues,sortIndex] = sort(img_part(1:length(ps),pa),'descend');  %# Sort the values in
    maxIndex = sortIndex(1:top_num_img);
    
    subplot(figsize,figsize,1); showboxes(imread(I{pa}), [bbox{pa}(1:4); gtbox{pa}]); rectangle('Position',[1,1,size(imread(I{pa}),2),size(imread(I{pa}),1)],'EdgeColor','b','linewidth', 5);
    subplot(figsize,figsize,2); visualizeHOGpos(models_all{pa}.w)
    subplot(figsize,figsize,3); visualizeHOGneg(models_all{pa}.w)
    gt_bbox = gtbox{pa}(1:4); part_bbox = bbox{pa}(1:4);
    relpos_examplar = relative_position(gt_bbox,part_bbox,1); %compute relative position: 1 means regionlet
    
    for imgind = 1 : top_num_img
        gt_bbox = ps{1,maxIndex(imgind)}.bbox(1:4);
        part_bbox = img_res{maxIndex(imgind)}.parts{pa}(1:4);
        relpos_candidate = relative_position(gt_bbox,part_bbox,1);

        consistancy_flg = pos_consistency_check(relpos_examplar,relpos_candidate,deform_param);
        if consistancy_flg
            img = imread(ps{1,maxIndex(imgind)}.I);
            subplot(figsize,figsize,imgind+figsize);
            showboxes(img,[part_bbox;gt_bbox]); rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','g','linewidth', 5);
            consistent_example_num = consistent_example_num+1;
        else
            img = imread(ps{1,maxIndex(imgind)}.I);
            subplot(figsize,figsize,imgind+figsize);
            showboxes(img,[part_bbox;gt_bbox]); rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','r','linewidth', 5);
        end
            
    end;
    saveas(gcf, [finalresdir 'detectedPatches_part_fixedpos',num2str(part),'.png']);
end


%%Training normal SVM
% selecting Pedestrian as negative set
% neg1 = load(['/projects/grail/santosh3/ngram_models/pedestrian/kmeans_6/pedestrian/pedestrian','_mix.mat'], 'lbbox_mix', 'posscores_mix');
% neg2 = load(['/projects/grail/santosh3/ngram_models/pedestrian/kmeans_6/pedestrian/pedestrian','_train_9990.mat'], 'impos');
% ng = [];
% j=1;
% for i = 1:2:length(neg2.impos)
%     if neg1.posscores_mix(i) > thresh
%         ng{1,j}.I = neg2.impos(i).im;
%         %ps{1,i}.bbox = impos(i).boxes;     % it should be on output of Santosh code NOT grountruth e.g. %lbbox_mix(find(lbbox_mix(:,1) == 0),:)
%         ng{1,j}.bbox = neg1.lbbox_mix(i,:);
%         ng{1,j}.cls = 'negative';
%         ng{1,j}.id = ng{1,j}.I(end-15:end);
%         j=j+1;
%     end
% end
% 
%     for i = 1:length(ng)
%         disp([int2str(i),'/',int2str(length(ng))]);
%         im_current = imread(ng{1,i}.I);
%         bbox_current = ng{1,i}.bbox;
%         [img_res_neg{i}.scores img_res_neg{i}.parts] = part_inference(im_current, models_all, bbox_current);
%     end
% 
%     img_part_neg = [];
%     for iim = 1:length(ng)
%         img_part_neg = [img_part_neg; img_res_neg{iim}.scores{:}];
%     end
% Training FAST SVM  
%D_pos = ps2D(ps);
% D_neg = ps2D(ng);
% D = [D_pos,D_neg];
%
% model_current = models_all{1};
% for indx = 1:length(ps)
%     image = ps{indx}.I; bbox = [img_res{indx}.parts{1}(1) , img_res{indx}.parts{1}(2), img_res{indx}.parts{1}(3)-img_res{indx}.parts{1}(1), img_res{1}.parts{1}(4)-img_res{1}.parts{1}(2)];
%     I = imread(image); croped_image = imcrop(I,bbox);
%     [feat, scales] = IEfeatpyramid(croped_image, sbin, interval);
%     X_pos(:,indx) = reshape(feat{1},[],1);
% end
%
%     Y = [ones(length(ps),1) ; -1*ones(length(ng),1)];
%     [w b alpha]= fast_svm(Y, X, C, wpos)

%Parameter setting for PASCAL format
%run bcp_release/startup.m 
BDglobals;
BDpascal_init;
% Generate D
D_temp = pasc2D('train', VOCopts);
D = D_temp(1:2:end);

%Generate model
model = init_model(dir_class);
cached_scores = init_cached_scores(model, D); %MOIN: use Santosh's region proposals instead
% for i = 1:length(D)
%     i
%     [x,y] = size(imread(['/projects/grail/santosh/objectNgrams/results/VOC9990/JPEGImages/',D(i).annotation.filename]));
%     regions = [1,1,y,x]; %it should be changed to result of Santosh method
%     cached_scores{i}.regions = regions;
%       if D(i).annotation.object(2).name = dir_class
%           cached_scores{i}.labels = 1;
%       else
%           cached_scores{i}.labels = -1;
%     cached_scores{i}.scores = 0;
%     cached_scores{i}.part_scores = 0;zeros(1, model.num_parts);
%     cached_scores{i}.part_boxes = 0;%: [500x0 double]
%     cached_scores{i}.region_score = 0;
% end
model = train_region_model(D, cached_scores, model);
cached_scores = add_region_scores(model, D, cached_scores);


% Set up model flags
model.hard_local = 0;
model.score_feat = 0;
model.weighted = 0;
model.incremental_feat = 0;
model.do_transform = 1;
model.shift = [0];
model.rotation = [0]; %[-20 -10 0 10 20]; % No shift for now, but we want
model.cached_weight = 0;
% Consistency thresholds...
model.min_ov = 0.75;
model.min_prob = 0.3;

%
iter = 1; %part number
best_model = models_all{i};
%D_pos = ps2D(ps);  a = D_pos(iter).annotation.object.polygon.pt.x
% best_model.name = ['exemplar-lda-',D_pos.annotation.filname,'-[',a,' ',b,' ',c,' ',d,']-7-train.mat'];
best_model.spat_const = [0,1,0.8,1,0,1];
model = add_model(model, best_model); %, 1); % 1 indicates adding a spatial model
model.part(iter).bias = model.part(iter).bias + 0.5; % Make sure to pull in plenty of hard negatives in the first iteration
model.part(iter).spat_const = [0 1 0.8 1 0 1];
%chosen_names{iter} = best_model.name;

%refine parts
cached_gt = get_gt_pos_reg(D, cached_scores, dir_class);
%[model w_all] = train_consistency(model, D, cached_gt);
[cached_gt_tmp, reference_box, consistent_examples] = get_consistent_examples(model, D, cached_gt);
neg_feats = []; C = 15;
[model neg_feats w_all] = train_loo_cache(model, D, cached_gt_tmp, 10, 2, 1, C, neg_feats);
