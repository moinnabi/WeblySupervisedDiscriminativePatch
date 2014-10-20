% DEMO for CVPR-2015

%% Parameter Setting and system configuation
%addpath
clear all;
%IIT% addpath('/home/moin/Desktop/UW/all_UW/cvpr_2015/code/'); % CHANGE!!!
addpath('/homes/grail/moinnabi/cvpr_2015_git/cvpr_2015/code/');

addpath('Santosh/');
addpath(genpath('dpm-voc-release5/'));
addpath(genpath('bcp_release/'));
run bcp_release/setup.m
run bcp_release/startup;


%Category Parameters
category = 'horse';
%IIT% dir_main = ['../data/ngram_models/',category,'/kmeans_6/'];  % CHANGE!!!
dir_main = ['/projects/grail/santosh/objectNgrams/results/ngram_models/',category,'/kmeans_6/'];
model_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat'],'model');
poscell_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat'],'poscell');
posdata_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat'],'posdata');
list_sub = model_tmp.model.phrasenames;

%VOC setup
%IIT% voc_dir = '/home/moin/datasets/PASCALVOC/'; % CHANGE!!!
voc_dir = '/projects/grail/santosh/Datasets/Pascal_VOC/';

year = '2007'; set = 'train'; 
[voc_ps_train, voc_ng_train] = VOC_load(category,year,set,voc_dir);



%% Per Subcategory
subcat = {'tang_horse_super 2','eye_horse_super 2','saddlebred_horse_super 6','morgan_horse_super 2','jennet_horse_super 1','sled_horse_super 1', ...
 'racing_horse_super 5','reining_horse 1','gallop_horse_super 6','pleasure_horse_super 1','barrel_horse 1','hunter_horse_super 2', ... 
 'hunter_horse_super 3','portrait_horse_super 1','portrait_horse_super 3','endurance_horse_super 2','pull_horse_super 6','pacing_horse 2', ... 
 'three_horse_super 5','winkle_horse_super 1','ass_horse 4','face_horse_super 4','ears_horse_super 6','fight_horse_super 6'};

list_sub_selected = [2,9,14,27,31,29,33,34,38,44,46,50,51,54,55,59,78,85,109,121,136,142,165, 170];

for sub_ind = 1:length(list_sub_selected)%length(list_sub)
    
    % 
    sub_index = list_sub_selected(sub_ind); %77; %dir_class = 'mountain_horse_super';
    dir_class = list_sub{sub_index}(1:end-2);
    component = str2num(list_sub{sub_index}(end-1:end));

    dir_data = [dir_main,dir_class,'/'];
    dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
    finalresdir = ['../data/result/',category,'/',dir_class,'/',num2str(component),'/']; mkdir(finalresdir); 
    numPatches = 250;
    top_num_part = 25;
    posscores_thresh = -1;

    datafname = [finalresdir 'imgdata_17oct14_' num2str(numPatches) '.mat'];
%     try
%         load(datafname, 'ps','patch_per_comp','w_sel');
%     catch
        ps = load_component_data(dir_data,dir_class,posscores_thresh,component);
        
        %This line is just to run on IIT PC (updating address by the local directroy, NOT required for UW)
        %for i=1:length(ps) ps{i}.I = ['/home/moin/Desktop/UW/all_UW/cvpr_2015/data/images/',ps{i}.I(end-15:end)]; end;

        %Subcategory-based atch discovery (MAIN FUNCTION)
        patch_per_comp = subcategory_patch_discovery(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,category,component,top_num_part,[1,1]);

        % Patch Calibration
        [w_sel] = patch_calibration_subcategory(patch_per_comp,dir_data,component,voc_dir);

        save(datafname, 'ps','patch_per_comp','w_sel');
%    end
end

%% Percategory
% Nothing to do with this part yet

%% Evaluation
% Compare with thhe same subcategory model by Santosh et.al

cls = 'horse'; testset =  'test'; testyear = '2007';
[voc_test,ids] = loadVOC_test(voc_dir,testyear,testset);

% Santosh models
model_tmp = load('../data/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
%UW% model_tmp = load('/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
model_santosh = model_tmp.models{component};
model_santosh_hyp = model_santosh;
model_santosh_hyp.thresh = -1.5;

% Patch models
model_selected = patch_per_comp.models_selected;
relpos_patch_normal_selected = patch_per_comp.relpos_patch_normal_selected;
moin_thresh = 1;

% Detection on PASCAL VOC
[ds_santosh] = pascal_test_santosh(voc_test,model_santosh,'santosh'); % the result by Santosh
[ds_santosh_hype] = pascal_test_santosh(voc_test,model_santosh,'santosh_hype-1.5'); % the result by Santosh with higher thershold to have more boxes
[ds_moin_median] = pascal_test_moin_IIT(model_selected,voc_test,relpos_patch_normal_selected,moin_thresh,'moin_median_IIT');  % the result by Moin
[ds_santoshANDmoin] = merge_ds_moin_santosh(ds_moin_median,ds_santosh_hype,santosh_thresh); % Merge Moin & Santosh
[ds_moinONsantosh,scores_all_moinONsantosh] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santoshANDmoin,w_sel,'moinONsantosh_IIT');

% Compute AP and plot PR curve
ap_santosh = pascal_eval(voc_dir,cls, ds_santosh,testset, testyear, 'santosh');
ap_moin_median = pascal_eval(voc_dir,cls, ds_moin_median,testset, testyear, 'moin_median_IIT');
ap_santoshANDmoin = pascal_eval(voc_dir,cls, ds_santoshANDmoin,testset, testyear, 'moinANDsantosh_IIT');
ap_moinONsantosh = pascal_eval(voc_dir,cls, ds_moinONsantosh ,testset, testyear, 'moinONsantosh_IIT');
