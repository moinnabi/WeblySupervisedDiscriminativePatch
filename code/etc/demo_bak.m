function demo
%%% This Demo is written for fast extraction of parts 

clear all;
%addpath
addpath('bcp_release/');
addpath('Santosh/');
run bcp_release/setup.m
run bcp_release/startup;

%matlabpool open;

%Parameters
dir_main = '/projects/grail/santosh/objectNgrams/results/ngram_models_part1/horse/kmeans_6/';
dir_class = 'portrait_horse_super'; %'eating_horse';
dir_data = [dir_main,dir_class,'/'];
dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
finalresdir = ['/homes/grail/moinnabi/Matlab/eccv14/data/bcp/tmp/' dir_class '/']; mkdir(finalresdir);
numPatches = 25;
thresh = -1;
% dir_img = '';
% dir_annot = '';
% dir_code = '';

datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
try
    load(datafname, 'ps','I', 'bbox', 'models', 'models_all');
catch  
    %Load Data of Santosh
    load([dir_data,dir_class,'_mix.mat'], 'lbbox_mix', 'posscores_mix');
    load([dir_data,dir_class,'_train_9990.mat'], 'impos');

    %Images & BB
    % i = 100;
    % img = uint8(imread(impos(i).im));
    % imshow(img); hold;
    % bb_object_gt = [impos(i).boxes(1) , impos(i).boxes(2) , impos(i).boxes(3)-impos(i).boxes(1) , impos(i).boxes(4)-impos(i).boxes(2)];
    % bb_object_est = [lbbox_mix(i,1) , lbbox_mix(i,2) , lbbox_mix(i,3)-lbbox_mix(i,1) , lbbox_mix(i,4)-lbbox_mix(i,2)];
    % rectangle('Position',bb_object_gt,'Edgecolor','g'); 
    % rectangle('Position',bb_object_est,'Edgecolor','r');

    %Reform data
    ps = [];
    j=1;
    for i = 1:2:length(impos)
        if posscores_mix(i) > thresh
            ps{1,j}.I = impos(i).im;
            %ps{1,i}.bbox = impos(i).boxes;     % it should be on output of Santosh code NOT grountruth e.g. %lbbox_mix(find(lbbox_mix(:,1) == 0),:)
            ps{1,j}.bbox = lbbox_mix(i,:);
            ps{1,j}.cls = dir_class;
            ps{1,j}.id = ps{1,j}.I(end-15:end);
            j=j+1;
        end
    end
    %Visulization
    %i = 165; imshow(imread(ps{1,i}.I)); hold; rectangle('Position',ps{1,i}.bbox,'Edgecolor','r'); hold off;


    %train_candidate_parts(ps,VOCopts,num)
    %part model
    disp('auto_get_part_fast');
    [I bbox gtbox] = auto_get_part_fast(VOCopts, ps, numPatches);
    %bbox = uint8(bbox);    
    figure(1); clf;
    for i=1:numPatches
        subplot(sqrt(numPatches),sqrt(numPatches),i);
        showboxes(imread(I{i}), [bbox{i}(1:4); gtbox{i}]);        
    end
    saveas(gcf, [finalresdir '/queryPatches.jpg']);
    
    %visulization
    % ind = 10; bbox_rec = [bbox{1,ind}(1) , bbox{1,ind}(2) , bbox{1,ind}(3)-bbox{1,ind}(1) , bbox{1,ind}(4)-bbox{1,ind}(2)];
    % imshow(imread(I{1,ind})); hold; rectangle('Position',uint8(bbox_rec),'Edgecolor','r'); hold off;
    disp('orig_train_elda');
    models = orig_train_elda(VOCopts, I, bbox, dir_class, dir_neg , 0, 1);
    %model = models{1,2}.model;

    % object model
    % [I bbox] = auto_get_obj_part(VOCopts, ps);
    % models = orig_train_elda(VOCopts, I, bbox, 'test', 'test', 0, 1);
    % % lower resolution filter:
    % for i = 1:length(bbox)
    %    bbox{i}(:,5) = 7;
    % end
    % models = orig_train_elda(VOCopts, I, bbox, 'TEST', 'test', 0, 1);

    % test_all_candidates(10, 10, cls, candidate_suffix, trainval);
    %models_all = zeros({1,length(models});
    for mod = 1:length(models)
        models_all{mod} = models{1,mod}.model;
    end
    
    save(datafname, 'ps','I', 'bbox', 'models', 'models_all');
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
        %visulization
    %     i = 1;
    %     figure; imshow(imread(ps{1,i}.I)); hold;
    %     top_num = 1;
    %     [sortedValues,sortIndex] = sort([img_res{1,i}.scores{1,:}],'descend');  %# Sort the values in
    %     maxIndex = sortIndex(1:top_num);
    %     for indx = 1:length(maxIndex)
    %         cl = indx/length(maxIndex);
    %         rectangle('Position',img_res{i}.parts{maxIndex(indx)},'Edgecolor',[0,0,cl*1]); hold off;
    %     end
    %     
    %     for i=21:2:30
    %         part = 1286;
    %         part_rec = [img_res{i}.parts{part}(1) , img_res{i}.parts{part}(2) , img_res{i}.parts{part}(3)-img_res{i}.parts{part}(1), img_res{i}.parts{part}(4)-img_res{i}.parts{part}(2)];
    %         figure; imshow(imread(ps{1,i}.I)); hold; rectangle('Position',part_rec,'Edgecolor','g'); hold off;
    %     end
    
    save(detsfname, 'img_res');
end

   
%disp('here1'); keyboard;

    
% CBIR system based on scores of the parts    
    % Pre-processing 
    img_part = [];
    for iim = 1:length(ps)
        img_part = [img_part; img_res{1,iim}.scores{:}];
    end
    % Main CBIR system
    close all;
    figure;
    top_num_part = 10;
    %[sortedValues_part,sortIndex_part] = sort(sum(img_part,1),'descend'); %# Sort importance the parts
    [sortedValues_part,sortIndex_part] = sort(max(img_part),'descend');  %# Sort importance of the parts MAX
    maxIndex_part = sortIndex_part(1:top_num_part);
    %
    for pa = 1:top_num_part
        part = maxIndex_part(pa);
        top_num_img = 10;
        [sortedValues,sortIndex] = sort(img_part(1:length(ps),part),'descend');  %# Sort the values in
        maxIndex = sortIndex(1:top_num_img);
        for imgind = 1 : length(maxIndex)
            part_rec = [img_res{maxIndex(imgind)}.parts{part}(1) , img_res{maxIndex(imgind)}.parts{part}(2) , img_res{maxIndex(imgind)}.parts{part}(3)-img_res{maxIndex(imgind)}.parts{part}(1), img_res{maxIndex(imgind)}.parts{part}(4)-img_res{maxIndex(imgind)}.parts{part}(2)];
            subplot(10,length(maxIndex),(pa-1)*top_num_img+imgind); imshow(imread(ps{1,maxIndex(imgind)}.I)); hold; rectangle('Position',part_rec,'Edgecolor','g'); hold off;
        end;
    end

% load_init_final(); %????
% 
% candidate_file = fullfile('data/bcp/tmp/candidates/candidates.mat');
% 
% D = 
% 
% Dtest = 
% cached_scores =
% cached_scores_test =
% model = init_model('Moin');

%Candidate training
%candidate_file = fullfile('data/tmp/candidates/', [cls '_candidates.mat']);



%[I, bbox] = auto_get_part(VOCopts, stream, amount, num_candidates)

%if(~exist(candidate_file, 'file'))
    %candidate_suffix = 'whog';

%     train_candidate_parts(cls, 2000, candidate_suffix, trainval);
%     test_all_candidates(10, 10, cls, candidate_suffix, trainval);
% 
%     candidate_suffix_full = [candidate_suffix '_' set_str];
%     candidate_models = load_candidate_models(cls, 0, 0, candidate_suffix_full); % Use auto selected ones for now
%     candidate_models = [candidate_models, load_candidate_models(cls, 0, 1, candidate_suffix_full)]; % Add object level 
%     
%     % Generate learning schedule.  This could be reordered based on current performance
%     [pos_prec chosen aps] = choose_candidate_amp(model, D, cached_scores, candidate_models);
%     save(candidate_file, 'pos_prec', 'chosen', 'aps', 'candidate_models');
%end
%Candidate test

%Candidate selection
saveas(gcf, [finalresdir '/detectedPatches.jpg']);
