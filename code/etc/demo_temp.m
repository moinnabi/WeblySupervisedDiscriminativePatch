%%% This Demo is written for fast extraction of parts 
%
close all;
clear all;
%addpath
 addpath('bcp_release/');
 addpath('Santosh/');
 run bcp_release/setup.m
run bcp_release/startup;

subdirectory_list = {'jumping_horse','racing_horse_super','zebra_horse','ass_horse','legs_horse_super'};

for sub = 1:length(subdirectory_list)
    dir_class = subdirectory_list{sub};
    dir_main = '/projects/grail/santosh/objectNgrams/results/ngram_models_part1/horse/kmeans_6/';
    %dir_class = 'portrait_horse_super'; %'eating_horse';
    dir_data = [dir_main,dir_class,'/'];
    dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
    finalresdir = ['/homes/grail/moinnabi/Matlab/eccv14/data/bcp/tmp/horse/' dir_class '/']; mkdir(finalresdir);
    numPatches = 250;
    thresh = -1;

    datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
    try
        load(datafname, 'ps','I', 'bbox', 'models', 'models_all');
    catch  
        %Load Data of Santosh
        load([dir_data,dir_class,'_mix.mat'], 'lbbox_mix', 'posscores_mix');
        load([dir_data,dir_class,'_train_9990.mat'], 'impos');

        %Reform data
        ps = [];
        j=1;
        for i = 1:2:length(impos)
            if posscores_mix(i) > thresh
                ps{1,j}.I = impos(i).im;
                ps{1,j}.bbox = lbbox_mix(i,:);
                ps{1,j}.cls = dir_class;
                ps{1,j}.id = ps{1,j}.I(end-15:end);
                j=j+1;
            end
        end

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
            [img_res{i}.scores img_res{i}.parts] = part_inference(im_current, models_all, bbox_current);
        end

        save(detsfname, 'img_res');
    end

    % CBIR system based on scores of the parts    
        % Pre-processing 
        img_part = [];
        for iim = 1:length(ps)
            img_part = [img_part; img_res{iim}.scores{:}];
        end

    %Visualization for spatial consistancy
    deform_param = [0.2 0.2]; %deformation along w and h respectively

    close all;
    %figure;
    top_num_part = 250;
    %consistent_example_num = 0;
    %[sortedValues_part,sortIndex_part] = sort(sum(img_part,1),'descend'); %# Sort importance the parts
    [sortedValues_part,sortIndex_part] = sort(max(img_part),'descend');  %# Sort importance of the parts MAX
    maxIndex_part = sortIndex_part(1:top_num_part);

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
                %consistent_example_num = consistent_example_num+1;
            else
                img = imread(ps{1,maxIndex(imgind)}.I);
                subplot(figsize,figsize,imgind+figsize);
                showboxes(img,[part_bbox;gt_bbox]); rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','r','linewidth', 5);
            end

        end;
        %mkdir([finalresdir,'250/']);
        saveas(gcf, [finalresdir 'detectedPatches_part_fixedpos',num2str(part),'.png']);
    end

end