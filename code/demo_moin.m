%% This script has been written by Moin for ECCV submission

%Addpath and Parameter settings
clear all;
addpath('Santosh/');
% addpath('/projects/grail/moinnabi/eccv14/'); %UW
addpath('/home/moin/Desktop/UW/all_UW/eccv14/');
run bcp_release/setup.m
run bcp_release/startup;

% % addpath(genpath('libsvm-3.17/')); 
%addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/')); %UW
addpath(genpath('/home/moin/Desktop/UW/all_UW/eccv14/Santosh/code/other_codes/voc-release5/'));
addpath(genpath('bcp_release/'));
% % addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/gdetect/');
% % addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/features/');
% % addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/model/');
% % addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/utils/');
% % addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/vis/');
% % run('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/startup.m');
% % run('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/compile.m');
% % addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));

%matlabpool open;

%Category Parameters
category = 'horse';
dir_main = ['/projects/grail/santosh/objectNgrams/results/ngram_models/',category,'/kmeans_6/'];

% %dir_sub = dir(fullfile(dir_main));
model_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat']);
list_sub = model_tmp.model.phrasenames;

[~, voc_ng_train] = loadVOC(category,'2007','train');

%For each Subcategory
for sub_index = 1:length(list_sub)
    
    sub_index
    list_sub{sub_index}
    %sub_index = 77;
    dir_class = list_sub{sub_index}(1:end-2);
    component = str2num(list_sub{sub_index}(end-1:end));
    %dir_class = 'mountain_horse_super';

    dir_data = [dir_main,dir_class,'/'];
    dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
    finalresdir = ['/projects/grail/moinnabi/eccv14/data/part_selected/',category,'/',dir_class,'/',num2str(component),'/']; mkdir(finalresdir);
    numPatches = 250;
    posscores_thresh = -1;

    %datafname = [finalresdir 'imgdata_moreparts_' num2str(numPatches) '.mat'];
    datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
    try
        load(datafname, 'ps','patch_per_comp');
    catch
        ps = load_component_data(dir_data,dir_class,posscores_thresh,component);
        %run subcategory part mining demo
        patch_per_comp = subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,category,component);
        %
        save(datafname, 'ps','patch_per_comp');
    end
end

%

part_selected = patch_per_comp.part_selected;
models_all = patch_per_comp.models_all;
relpos_patch_normal = patch_per_comp.relpos_patch_normal;
deform_param_patch = patch_per_comp.deform_param_patch;
ps_detect = patch_per_comp.ps_detect;

part_selected_ind = find(part_selected);
model_selected = [];
relpos_patch_normal_selected = [];
for i = 1:length(part_selected_ind)
    model_selected{i} = models_all{part_selected_ind(i)};
    relpos_patch_normal_selected{i} = relpos_patch_normal{i};
    deform_param_patch_selected{i} = deform_param_patch{i};
end

%Detector calibration
matfile = load('/projects/grail/santosh/objectNgrams/results/ngram_models_part1/horse/kmeans_6/mountain_horse_super/mountain_horse_super_boxes_val_9990_mix.mat','ds_top');
txtfile = '/projects/grail/santosh/objectNgrams/results/VOC9990/ImageSets/Main/mountain_horse_super_val.txt';
cellfile = Script_readfrom_valtxt(txtfile);

selected_ind = find(matfile.ds_top(:,5) == component);
selected_samples = matfile.ds_top(selected_ind,:);
selected_images = cellfile(selected_ind,1);
selected_label = selected_samples(:,6);
selected_score = selected_samples(:,7);

pos = length(find(selected_label==1));
neg = length(find(selected_label==-1));

BBox_all = selected_samples(:,1:4);
%

feature = [];
for img =1 : length(selected_images)
    img
    switch selected_label(img)
        case 1
            adrs = '/projects/grail/santosh/objectNgrams/results/VOC9990/JPEGImages/';
        case -1
            adrs = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/VOC2007/JPEGImages/';
        otherwise
            continue;
    end
    im_current = imread([adrs,selected_images{img},'.jpg']);
    gt_bbox = BBox_all(img,:);
    
    bbox_current = inverse_relative_position_all(gt_bbox,relpos_patch_normal_selected,1);

    [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, model_selected, bbox_current);
    
    %inference{img}.detection_loc = detection_loc;
    %inference{img}.ap_score = ap_score;
    %inference{img}.sp_score = sp_score;
    
    all_score = vertcat(ap_score{:}) .* vertcat(sp_score{:});
    feature(img,:) = all_score;
    
end

%Feature&Label for training SVM
f_all = [selected_score,feature];
f_all_normal = [selected_score,normalize_matrix(feature)]; %normalize along columns
l_all = selected_label;

for pos_ind = 1:pos
    if ~isempty(find(f_all(pos_ind,:)==0))
        pos_sel_ind(pos_ind) = 0;
    else
        pos_sel_ind(pos_ind) = 1;
    end
end
f_selected_pos = f_all(find(pos_sel_ind),:);
f_selected_pos_normal = f_all_normal(find(pos_sel_ind),:);
l_selected_pos = selected_label(find(pos_sel_ind),:);

f_selected = [f_selected_pos ; f_all(pos+1:end,:)];
f_selected_normal = [f_selected_pos_normal ; f_all_normal(pos+1:end,:)];
l_selected = [l_selected_pos ; selected_label(pos+1:end,:)];

TrainLabel = l_selected;
TrainVec = f_selected_normal;


%Full samples
addpath(genpath('libsvm-3.17/matlab/'));

% Cross validation
bestcv = 0;
for log2c = -6:10,
   cmd = ['-v 5 -c ', num2str(2^log2c)];
   cv = svmtrain(TrainLabel,TrainVec, cmd);
   if (cv >= bestcv),
     bestcv = cv; bestc = 2^log2c;
   end
   fprintf('(best c=%g, rate=%g)\n',bestc, bestcv);
end



model_scores_selected = svmtrain(l_selected, f_selected_normal,['-t 0 -c ',num2str(bestc)]);

%non-zero samples
%>>libsvmwrite('libsvm-3.17/data-2_partsize.txt', l_selected, sparse(f_selected_normal)) %run in matlab
%>>python grid.py ../data-2.txt % run in terminal in this directory libsvm-3.17/tools/
%2.0 0.5 96.7118
%model_scores_selected = svmtrain(l_selected, f_selected_normal,'-t 0 -c 32');

w_sel = model_scores_selected.SVs' * model_scores_selected.sv_coef;
b_sel = -model_scores_selected.rho;

if model_scores_selected.Label(1) == -1
    w_sel = -w_sel;
    b_sel = -b_sel;
end
%saveload('data/svm-model.mat','feature','w_sel','b_sel','model_scores_selected','f_selected_normal','l_selected');

%%Evaluation
[voc_test,ids] = loadVOC_test('2007','test');
model_tmp = load('/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
model_santosh = model_tmp.models{component};

addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/')); %addpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/bin/');
suffix = 'test-santosh'; %suffix = 'test-santosh-moreparts'; 
[ds_santosh] = pascal_test_santosh(voc_test,model_santosh,suffix);

addpath(genpath('bcp_release/'));
detection_thre = 80; %suffix_moin = 'test-moin';  w_sel_moin = ones(25,1);
[ds_moin] = pascal_test_moin(model_selected,voc_test,relpos_patch_normal_selected,detection_thre);
%[ds_moin] = pascal_test_moin_median(model_selected,voc_test,relpos_patch_normal_selected,detection_thre);

%[ds_moin_rescored,scores_all_rescored_moin] = moin_rescoring_moin(model_selected,relpos_patch_normal_selected,voc_test,ds_moin,w_sel_moin,suffix_moin);
%
addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));
thresh = model_santosh.thresh;
[ds_santoshONmoin] = santosh_rescoring_moin(ds_moin,voc_test,model_santosh,thresh);
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