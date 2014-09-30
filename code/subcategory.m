%function [I bbox gtbox relpos_patch deform_param models models_all ps_detect sp_consist_mat sp_consis_score img_part] = demo_subcategory(VOCopts, ps, numPatches,coverage_thershold,dir_class,dir_neg,finalresdir,comp)
function [patch_per_comp] = subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,category,component,top_num_part)

%by Moin
 
%Select random "patches" on each Positive image (belongs to this subcategory)
disp('auto_get_part_fast');
[I bbox gtbox] = auto_get_part_fast(VOCopts, ps, numPatches,0.25,0.75);

%showboxesc(imread(I{1}),gtbox{1},'r'); hold;


%Find relative position and Deformation Parameter for each Query patch
for i = 1:numPatches
    root_bbox = gtbox{i}; part_bbox = bbox{i}(1:4);
    relpos_patch_normal{i} = relative_position(root_bbox,part_bbox,1); %1 means normalized (regionlet)
end

%Train Examplar-LDA for each patch (Query)
addpath(genpath('bcp_release/'));
VOCopts.localdir = '/home/moin/Desktop/UW/all_UW/eccv14/data/bcp_elda/';
disp('orig_train_elda');
models = orig_train_elda(VOCopts, I, bbox, dir_class, dir_neg , 0, 1);
for mod = 1:length(models)
    models_all{mod} = models{1,mod}.model;
end

%Compute Deformation Parameter for each Query patch
for i = 1:numPatches
    mdl = models_all{i};
    im = imread(I{i});
     deform_param_patch{i} = deform_param(im,mdl,1); %MISSING: Now is fixed for all!!! [0.3 0.3]
end


%Run the fixed position detector on all Positive images and find Pos_score
disp('doing part inference on positive samples in Subcategory');
parfor i = 1:length(ps)
    disp([int2str(i),'/',int2str(length(ps))])
    im_current = imread(ps{1,i}.I);
    root_bbox = ps{1,i}.bbox;

    bbox_current = inverse_relative_position_all(root_bbox,relpos_patch_normal,1);
    [detection_loc , ap_score , sp_score ] = part_inference_inbox(im_current, models_all, bbox_current);
%    [detection_loc , ap_score , sp_score] = part_inference_inbox_Qdeformation(im_current, models_all, bbox_current,root_bbox,deform_param_patch,1);    % FOR Spatial quadratice distance
     ps_detect{i}.sp_scores = sp_score;
     ps_detect{i}.ap_scores = ap_score;
    %ps_detect{i}.scores = num2cell(horzcat(ap_score{:}).*horzcat(sp_score{:}));
     ps_detect{i}.patches = detection_loc;
end

disp('Hard Negative mining');
model_tmp = load('data/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
model_santosh = model_tmp.models{component};
thresh = model_santosh.thresh;
[ng_detect] = run_patches_inside_santosh_on_negative(model_santosh,models_all,voc_ng_train,relpos_patch_normal,thresh);
%[ng_detect] = run_patches_inside_santosh_on_negative_Qdeformation(model_santosh,models_all,voc_ng_train,relpos_patch_normal,thresh,deform_param_patch);    % FOR Spatial quadratice distance
%[ng_detect] = run_patches_inside_wholeimage_on_negative(models_all,voc_ng_train);

disp('Computing Representation measure based on SP/AP consistancy');
% get detected patches and computer matrix of image by patch showing
% representation measure over the normalized valuse of SP and AP
[ps_sp_score_norm,ps_ap_score_norm,ps_score] = detect2repscore(ps_detect);
%also on the negative
[ng_sp_score_norm,ng_ap_score_norm,ng_score] = detect2repscore(ng_detect);

%good patch selection
%in IIT
%[part_selected, score_all, discriminantion_score ,representation_score] = select_patch_inbox(ps_ap_score_norm,ng_ap_score_norm,top_num_part);
[part_selected, score_all, discriminantion_score ,representation_score] = select_patch_inbox(ps_score,ng_score,top_num_part);

%
% VISUALIZATION
%
patch_per_comp.I = I;
patch_per_comp.bbox = bbox;
patch_per_comp.gtbox = gtbox;
patch_per_comp.relpos_patch_normal = relpos_patch_normal;
%patch_per_comp.relpos_patch_fixed = relpos_patch_fixed;
patch_per_comp.deform_param_patch = deform_param_patch;
patch_per_comp.models = models;
patch_per_comp.models_all =models_all;
%
patch_per_comp.ps = ps;            
patch_per_comp.ps_detect = ps_detect;
patch_per_comp.ng_detect = ng_detect;
% patch_per_comp.sp_consistant_parts = sp_consistant_parts;
% patch_per_comp.sp_consist_binary = sp_consist_binary;
% patch_per_comp.sp_consist_score = sp_consist_score;
% patch_per_comp.sp_consist_score_all = sp_consist_score_all;
% patch_per_comp.app_consist_score = app_consist_score;
% patch_per_comp.app_consist_binary = app_consist_binary;
% patch_per_comp.ng_score = ps_app_score;
patch_per_comp.ps_score = ps_score;
patch_per_comp.ng_score = ng_score;
patch_per_comp.discriminantion_score = discriminantion_score;
patch_per_comp.representation_score = representation_score;
patch_per_comp.part_selected = part_selected;
patch_per_comp.score_all = score_all;

