% Demo for a Category
clear all;
%addpath
% addpath('bcp_release/');
% addpath('Santosh/');
% addpath('/projects/grail/moinnabi/eccv14/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/vis/');
% run bcp_release/setup.m
run bcp_release/startup;

%Parameters
dir_main = '/projects/grail/santosh/objectNgrams/results/ngram_models_part1/horse/kmeans_6/';
dir_class = 'portrait_horse_super'; %'saddlebred_horse_super';
dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
dir_data = [dir_main,dir_class,'/'];
finalresdir = ['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/' dir_class '/']; mkdir(finalresdir);
numPatches = 25;
thresh = -1;
%
%

datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
try
    load(datafname, 'ps','I', 'bbox', 'models', 'models_all');
catch  
    %Load Data of Santosh
    pos1 = load([dir_data,dir_class,'_mix.mat'], 'lbbox_mix', 'posscores_mix');
    pos2 = load([dir_data,dir_class,'_train_9990.mat'], 'impos');
    neg1 = load(['/projects/grail/santosh3/ngram_models/pedestrian/kmeans_6/pedestrian/pedestrian','_mix.mat'], 'lbbox_mix', 'posscores_mix');
    neg2 = load(['/projects/grail/santosh3/ngram_models/pedestrian/kmeans_6/pedestrian/pedestrian','_train_9990.mat'], 'impos');

    %Reform positive data into ps
    ps = []; j=1;
    for i = 1:2:length(pos2.impos)
        if pos1.posscores_mix(i) > thresh
            ps{1,j}.I = pos2.impos(i).im;
            ps{1,j}.bbox = pos1.lbbox_mix(i,:);
            ps{1,j}.cls = dir_class;
            ps{1,j}.id = ps{1,j}.I(end-15:end);
            j=j+1;
        end
    end
    %Reform negative data into ng
    ng = []; j=1;
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
    
    %Select random "patches" on each Positive image (belongs to this subcategory)
    disp('auto_get_part_fast');
    [I bbox gtbox] = auto_get_part_fast(VOCopts, ps, numPatches);

    %Find relative position and Deformation Parameter for each Query patch
    for i = 1:numPatches
        gt_bbox = gtbox{i}; part_bbox = bbox{i}(1:4);
        relpos_patch{i} = relative_position(gt_bbox,part_bbox,1); %1 means normalized (regionlet)
    end
    deform_param = [0.2 0.2]; %MISSING: Compute deformation param!!!
    
    %Train Examplar-LDA for each patch (Query)
    disp('orig_train_elda');
    models = orig_train_elda(VOCopts, I, bbox, dir_class, dir_neg , 0, 1);
    for mod = 1:length(models)
        models_all{mod} = models{1,mod}.model;
    end
    
    %Run the fixed position detector on all Positive images and find Pos_score
    disp('doing part inference on positive');
    %
    parfor i = 1:length(ps)
        disp([int2str(i),'/',int2str(length(ps))]);
        im_current = imread(ps{1,i}.I);
        gt_bbox = ps{1,i}.bbox;
        
        bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch,1);

        [ps_detect{i}.scores ps_detect{i}.parts] = part_inference_moin(im_current, models_all, bbox_current);
        %[s p f] = part_inference(im_current, models_all, bbox_current);
    end
    
%Run the fixed position detector on all negative images and find Neg_score
%Select Patches using Pos_score and neg_score




% for sub = 1:
%     for com = 1:
%         demo_Subcategory(subcat,comp);
%     end
% end
