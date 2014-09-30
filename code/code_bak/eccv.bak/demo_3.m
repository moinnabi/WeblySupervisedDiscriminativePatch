%Demo for horse category

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
dir_main = '/projects/grail/santosh/objectNgrams/results/ngram_models_part1/horse/kmeans_6/';
dir_sub = dir(fullfile(dir_main));

for sub_ = 3:1138

    dir_class = dir_sub(sub_).name; %dir_class = 'portrait_horse_super'; %'saddlebred_horse_super';

    dir_data = [dir_main,dir_class,'/'];
    dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
    finalresdir = ['/projects/grail/moinnabi/eccv14/data/bcp_init/horse/' dir_class '/']; mkdir(finalresdir);
    numPatches = 25;
    thresh = -1;

    datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
    try
        load(datafname, 'ps_all','comp_ind','component');
    catch  
        %Load Data of Santosh
        load([dir_data,dir_class,'_mix.mat'], 'lbbox_mix', 'posscores_mix','inds_mix');
        load([dir_data,dir_class,'_train_9990.mat'], 'impos');
        load([dir_data,dir_class,'_mix_goodInfo2.mat'], 'selcomps');

        %Reform data
        ps_all = [];
        comp_ind = ones(1,6); %number of components
        for i = 1:2:length(impos)
            if posscores_mix(i) > thresh
                comp = inds_mix(i);
                ps_all{comp,comp_ind(comp)}.I = impos(i).im;
                ps_all{comp,comp_ind(comp)}.component = inds_mix(i);
                ps_all{comp,comp_ind(comp)}.bbox = lbbox_mix(i,:);
                ps_all{comp,comp_ind(comp)}.cls = dir_class;
                ps_all{comp,comp_ind(comp)}.id = ps_all{comp,comp_ind(comp)}.I(end-15:end);
                comp_ind(comp) = comp_ind(comp) +1;            
            end
        end

        %selcomps is binary vector showing which componenets are active for subcategory
        selected_comp = find(selcomps);
        num_sample_comp = comp_ind(selcomps == 1) - 1;

        %For ALL componenets in this subcategory do
        for scomp = 1:length(selected_comp)
            disp([num2str(scomp),'/',num2str(length(selected_comp))]);
            component{scomp}.ps = [];
            for scomp_in = 1:num_sample_comp(scomp)
                component{scomp}.ps{1,scomp_in} = ps_all{selected_comp(scomp),scomp_in};
            end
            %For EACH componnet in this subcategory
            %Select random "patches" on each Positive image (belongs to this subcategory)
            disp('auto_get_part_fast');
            [component{scomp}.I component{scomp}.bbox component{scomp}.gtbox] = auto_get_part_fast(VOCopts, component{scomp}.ps, numPatches);

            %Find relative position and Deformation Parameter for each Query patch
            for i = 1:numPatches
                gt_bbox = component{scomp}.gtbox{i}; part_bbox = component{scomp}.bbox{i}(1:4);
                component{scomp}.relpos_patch{i} = relative_position(gt_bbox,part_bbox,1); %1 means normalized (regionlet)
            end

            %Compute Deformation Parameter for each Query patch
            for i = 1:numPatches
                component{scomp}.deform_param{i} = [0.2 0.2]; %MISSING: Now is fixed for all!!!
            end

            %Train Examplar-LDA for each patch (Query)
            disp('orig_train_elda');
            component{scomp}.models = orig_train_elda(VOCopts, component{scomp}.I, component{scomp}.bbox, dir_class, dir_neg , 0, 1);
            for mod = 1:length(component{scomp}.models)
                component{scomp}.models_all{mod} = component{scomp}.models{1,mod}.model;
            end
            %Run the fixed position detector on all Positive images and find Pos_score
            disp('doing part inference on positive');

            ps = component{scomp}.ps; models_all = component{scomp}.models_all;
            %component{scomp}.ps_detect = cell(1,20);

            parfor i = 1:length(component{scomp}.ps)
                disp([int2str(i),'/',int2str(length(ps))])
                im_current = imread(ps{1,i}.I);
                bbox_current = ps{1,i}.bbox;
                [ps_detect{i}.scores, ps_detect{i}.parts] = part_inference(im_current, models_all, bbox_current);
            end
            component{scomp}.ps_detect = ps_detect;
            %

            %
            disp('scoring parts based on spatial consistancy')
            component{scomp}.part_spconsistent_score = zeros(1,numPatches);
            component{scomp}.consistancy_flg = zeros(length(component{scomp}.ps),numPatches);
            for prt = 1:numPatches
                for img = 1:length(component{scomp}.ps)
                    big_bbox = component{scomp}.ps{1,img}.bbox(1:4);
                    small_bbox = component{scomp}.ps_detect{img}.parts{prt}(1:4); %make it component{scomp}.
                    relpos_candidate = relative_position(big_bbox,small_bbox,1);

                    component{scomp}.consistancy_flg(img,prt) = pos_consistency_check(component{scomp}.relpos_patch{prt},relpos_candidate,deform_param);    
                    if component{scomp}.consistancy_flg(img,prt)
                        component{scomp}.part_spconsistent_score(prt) = component{scomp}.part_spconsistent_score(prt) +1;
                    end
                end
            end
            part_spconsistent_score_norm = component{scomp}.part_spconsistent_score / length(component{scomp}.ps);
            %

            disp('scoring parts based on appearence consistancy (pos/neg)')
            img_part_ps = [];
            for iim = 1:length(component{scomp}.ps)
                img_part_ps = [img_part_ps; component{scomp}.ps_detect{iim}.scores{:}];
            end

            component{scomp}.img_part_ps = img_part_ps;
            img_part = component{scomp}.img_part_ps;

            %Visualization
            coverage_thershold = 0.1; % how many images are covered by each part?
            top_num_part = length(find(part_spconsistent_score_norm > coverage_thershold));%25;
            [sortedValues_part,sortIndex_part] = sort(component{scomp}.part_spconsistent_score,'descend');  %# Sort importance of the parts MAX
            maxIndex_part = sortIndex_part(1:top_num_part);
            close all;
            %showing selected parts based on being fixed position
            figure(1); clf;
            for part= 1:min(25,top_num_part)
                pa = maxIndex_part(part);
                subplot(sqrt(25),sqrt(25),part);
                showboxes(imread(component{scomp}.I{pa}), [component{scomp}.bbox{pa}(1:4); component{scomp}.gtbox{pa}]);
            end
            mkdir([finalresdir,int2str(scomp),'/']);
            saveas(gcf, [finalresdir,int2str(scomp),'/queryPatches.jpg']);

            %%%
            %ps = component{scomp}.ps;

            %ps = component{scomp}.ps;
            for part = 1:top_num_part
                close all;
                pa = maxIndex_part(part);
            % for pa = 1:numPatches
                figure;
                figsize = 5;
                top_num_img = min(figsize*(figsize-1),length(component{scomp}.ps));
                [sortedValues,sortIndex] = sort(img_part(1:length(component{scomp}.ps),pa),'descend');  %# Sort the values in
                maxIndex = sortIndex(1:top_num_img);


                subplot(figsize,figsize,1); showboxes(imread(component{scomp}.I{pa}), [component{scomp}.bbox{pa}(1:4); component{scomp}.gtbox{pa}]); %rectangle('Position',[1,1,size(imread(component{scomp}.I{pa}),2),size(imread(component{scomp}.I{pa}),1)],'EdgeColor','b','linewidth', 5);
                subplot(figsize,figsize,2); visualizeHOGpos(component{scomp}.models_all{pa}.w)
                subplot(figsize,figsize,3); visualizeHOGneg(component{scomp}.models_all{pa}.w)
    %             gt_bbox = component{scomp}.gtbox{pa}(1:4); part_bbox = component{scomp}.bbox{pa}(1:4);
    %             relpos_examplar = relative_position(gt_bbox,part_bbox,1); %compute relative position: 1 means regionlet

                for imgind = 1 : top_num_img
                    img = imread(component{scomp}.ps{1,maxIndex(imgind)}.I);
                    gt_bbox = component{scomp}.ps{1,maxIndex(imgind)}.bbox(1:4);
                    part_bbox = component{scomp}.ps_detect{maxIndex(imgind)}.parts{pa}(1:4);
                    if component{scomp}.consistancy_flg(maxIndex(imgind),pa)
                        subplot(figsize,figsize,imgind+figsize);
                        showboxes(img,[part_bbox;gt_bbox]); rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','g','linewidth', 3);
                    else
                        subplot(figsize,figsize,imgind+figsize);
                        showboxes(img,[part_bbox;gt_bbox]); rectangle('Position',[1,1,size(img,2),size(img,1)],'EdgeColor','r','linewidth', 3);
                    end
                end

                saveas(gcf, [finalresdir,int2str(scomp),'/detectedPatches_part_fixedpos',num2str(part),'.png']);
            end

        end

        save(datafname, 'ps_all','comp_ind','component');
    end

end
