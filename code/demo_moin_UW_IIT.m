%% This script has been written by Moin for ECCV submission

%Addpath and Parameter settings
clear all;
addpath('Santosh/');
addpath('/home/moin/Desktop/UW/all_UW/eccv14/');

addpath(genpath('bcp_release/'));
run bcp_release/setup.m
run bcp_release/startup;

addpath(genpath('/home/moin/Desktop/UW/all_UW/eccv14/dpm-voc-release5/'));

% addpath(genpath('libsvm-3.17/')); 
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/gdetect/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/features/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/model/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/utils/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/vis/');
% run('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/startup.m');
% run('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/compile.m');
% addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));

%matlabpool open;

%Category Parameters
category = 'horse';
dir_main = ['data/ngram_models/',category,'/kmeans_6/'];

%dir_sub = dir(fullfile(dir_main));
%model_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat']);

model_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat'],'model');
poscell_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat'],'poscell');
posdata_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat'],'posdata');

list_sub = model_tmp.model.phrasenames;

%pascal setup
%[~, voc_ng_train] = loadVOC(category,'2007','train');
voc_dir = '/home/moin/datasets/PASCALVOC/'; 
year = '2007'; set = 'train'; 
[voc_ps_train, voc_ng_train] = VOC_load(category,year,set,voc_dir);

%% For each Subcategory
for sub_index = 1:length(list_sub)
    
    sub_index = 77; %dir_class = 'mountain_horse_super';
    dir_class = list_sub{sub_index}(1:end-2);
    component = str2num(list_sub{sub_index}(end-1:end));

    dir_data = [dir_main,dir_class,'/'];
    dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
    %finalresdir = ['/projects/grail/moinnabi/eccv14/data/part_selected/',category,'/',dir_class,'/',num2str(component),'/']; mkdir(finalresdir);
    finalresdir = ['data/result/',category,'/',dir_class,'/',num2str(component),'/']; mkdir(finalresdir);
    numPatches = 250;
    top_num_part = 25;
    posscores_thresh = -1;

    %datafname = [finalresdir 'imgdata_moreparts_' num2str(numPatches) '.mat'];
    %datafname = [finalresdir 'imgdata_' num2str(numPatches) '_on_whole_nagative_image.mat'];
    datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
    try
        load(datafname, 'ps','patch_per_comp');
    catch
        ps = load_component_data(dir_data,dir_class,posscores_thresh,component);
        %
        for i=1:length(ps) ps{i}.I = ['/home/moin/Desktop/UW/all_UW/eccv14/data/images/',ps{i}.I(end-15:end)]; end;

        %run subcategory part mining demo
        patch_per_comp = subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,category,component,top_num_part);
        %
        save(datafname, 'ps','patch_per_comp');
    end
end

%Visualization
type = 2;
visualize_all(ps,patch_per_comp,voc_ng_train,type);

%% Patch Calibration

% Load validation set per each subcategory
matfile = load([dir_data,'/mountain_horse_super_boxes_val_9990_mix.mat'],'ds_top');
txtfile = '/home/moin/datasets/PASCALVOC/VOC9990/ImageSets/Main/mountain_horse_super_val.txt';
cellfile = Script_readfrom_valtxt(txtfile);

[ w_sel ] = patch_calibration(patch_per_comp,matfile,cellfile,component);

%saveload('data/svm-model.mat','feature','w_sel','b_sel','model_scores_selected','f_selected_normal','l_selected');

%% Evaluation
voc_dir = '/home/moin/datasets/PASCALVOC/';
[voc_test,ids] = loadVOC_test(voc_dir,'2007','test');

%UW% model_tmp = load('/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
model_tmp = load('data/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
model_santosh = model_tmp.models{component};

%UW% addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));
addpath(genpath('dpm-voc-release5/'));
suffix = 'test-santosh'; %suffix = 'test-santosh-moreparts'; 
[ds_santosh] = pascal_test_santosh(voc_test,model_santosh,suffix);
cls = 'horse'; testset =  'test'; testyear = '2007';
ap_santosh = pascal_eval_santosh(voc_dir,cls, ds_santosh,testset, testyear, suffix);

addpath(genpath('bcp_release/'));
detection_thre = 80; suffix = 'test-moin';  %w_sel_moin = ones(25,1);
[ds_moin] = pascal_test_moin(model_selected,voc_test,relpos_patch_normal_selected,detection_thre);
%[ds_moin_median] = pascal_test_moin_median(model_selected,voc_test,relpos_patch_normal_selected,detection_thre);
cls = 'horse'; testset =  'test'; testyear = '2007';
ap_moin = pascal_eval_santosh(voc_dir,cls, ds_moin,testset, testyear, suffix);

suffix = 'test-moin_rescored';
[ds_moin_rescored,scores_all_rescored_moin] = moin_rescoring_moin(model_selected,relpos_patch_normal_selected,voc_test,ds_moin,w_sel,suffix);
%save(['data/result/',suffix,'.mat'],'ds_santoshONmoin');
%
addpath(genpath('/home/moin/Desktop/UW/all_UW/eccv14/dpm-voc-release5/'));
thresh = model_santosh.thresh; suffix = 'test-santoshONmoin'; 
[ds_santoshONmoin] = santosh_rescoring_moin(ds_moin,voc_test,model_santosh,thresh);
%save(['data/result/',suffix,'.mat'],'ds_santoshONmoin');
ap_santoshONmoin = pascal_eval_santosh(voc_dir,cls, ds_santoshONmoin,testset, testyear, suffix);
%
[ds_santosh_moin] = merge_ds_moin_santosh(ds_santoshONmoin,ds_santosh,thresh); %removed zero santosh detection
%
%rescoring_both(ds_santosh_moin,scores_all_rescored_moin)
addpath(genpath('bcp_release/'));
suffix = 'test_moin_santosh_9';
[ds_santosh_rescored,scores_all_rescored_both] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santosh_moin,w_sel,suffix);
ds_santosh_rescored_sub = ds_subset_selection(ds_santosh_rescored, -18);

%EVALUATION
cls = 'horse'; testset =  'test'; testyear = '2007';
ap_santosh_rescored = pascal_eval_santosh(cls, ds_santosh_rescored_sub,testset, testyear, 'ds_santosh_rescored_9');%'santosh-rescored');%
%ap_santosh_rescored = pascal_eval_santosh(cls, ds_santosh_rescored,testset, testyear, suffix);%'santosh-rescored');%