function initial_patchs = subcategory_init(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,sp_ap_flag)
%sp_ap_flag => 1:just spatial 2:appreance 3:both
%by Moin
 
%Select random "patches" on each Positive image (belongs to this subcategory)
disp('auto_get_part_fast');
[I bbox gtbox] = auto_get_part_fast(VOCopts, ps, numPatches);

%%%%%%%%%%%%%%%%%%%%%%%
%Find relative position and Deformation Parameter for each Query patch
for i = 1:numPatches
    gt_bbox = gtbox{i}; part_bbox = bbox{i}(1:4);
    relpos_patch_normal{i} = relative_position(gt_bbox,part_bbox,1); %1 means normalized (regionlet)
end
%%%%%%%%%%%%%%%%%%%%%%%
%Train Examplar-LDA for each patch (Query)
disp('orig_train_elda');
models = orig_train_elda(VOCopts, I, bbox, dir_class, dir_neg , 0, 1);
for mod = 1:length(models)
    models_all{mod} = models{1,mod}.model;
end

for i = 1:numPatches
    mdl = models_all{i};
    im = imread(I{i});
     deform_param_patch{i} = deform_param(im,mdl,1); %MISSING: Now is fixed for all!!! [0.3 0.3]
end
%%%%%%%%%%%%%%%%%%%%%%%
disp('doing part inference on positive samples in Subcategory');
parfor i = 1:length(ps)
    disp([int2str(i),'/',int2str(length(ps))])
    im_current = imread(ps{1,i}.I);
    bbox_current = ps{1,i}.bbox;
    [ps_detect{i}.scores, ps_detect{i}.parts] = part_inference(im_current, models_all, bbox_current);
end
ps_score = zeros(length(ps),numPatches);
for prt = 1:numPatches
    for img = 1:length(ps)
        ps_score(img,prt) = ps_detect{img}.scores{prt};
    end
end
%%%%%%%%%%%%%%%%%%%%%%%
if sp_ap_flag == 2
    disp('doing part inference on PASCAL-VOC Negative');
    [ng_detect] = run_detection_on(models_all,voc_ng_train);
    ng_score = zeros(length(voc_ng_train),numPatches);
    %par
    for prt = 1:numPatches
        for img = 1:length(voc_ng_train)
            ng_score(img,prt) = ng_detect{img}.scores{prt};
        end
    end
end

% spatial consitancy check
[~,sp_consist_score,sp_consist_binary,sp_consistant_parts] = spatial_consistancy(ps,ps_detect,relpos_patch_normal,deform_param_patch,numPatches,1);

%%%%%%%%%%%%%%%%%%%%
initial_patchs.I = I;
initial_patchs.bbox = bbox;
initial_patchs.gtbox = gtbox;
initial_patchs.relpos_patch_normal = relpos_patch_normal;
%patch_per_comp.relpos_patch_fixed = relpos_patch_fixed;
initial_patchs.deform_param_patch = deform_param_patch;
initial_patchs.models = models;
initial_patchs.models_all = models_all;
%
initial_patchs.ps = ps;     
initial_patchs.ps_detect = ps_detect;
if sp_ap_flag == 2
    initial_patchs.ng_detect = ng_detect;
end
initial_patchs.sp_consistant_parts = sp_consistant_parts;
initial_patchs.sp_consist_binary = sp_consist_binary;
initial_patchs.sp_consist_score = sp_consist_score;