cls = 'horse'; testset =  'test'; testyear = '2007';
[voc_test,ids] = loadVOC_test(voc_dir,testyear,testset);


for sub_ind = 10:length(list_sub_selected)%length(list_sub)
    
    % 
    numPatches = 250;
    sub_index = list_sub_selected(sub_ind); %77; %dir_class = 'mountain_horse_super';
    dir_class = list_sub{sub_index}(1:end-2)
    component = str2num(list_sub{sub_index}(end-1:end));

    dir_data = [dir_main,dir_class,'/'];
    finalresdir = ['../data/result/',category,'/',dir_class,'/',num2str(component),'/']; %mkdir(finalresdir);

    datafname = [finalresdir 'imgdata_20oct14_' num2str(numPatches) '.mat'];

    load(datafname, 'ps','patch_per_comp','w_sel');

    % Santosh models
    %model_tmp = load(['../data/ngram_models/horse/kmeans_6/',dir_class,'/',dir_class,'_parts.mat'],'models');
    model_tmp = load(['/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/',dir_class,'/',dir_class,'_parts.mat'],'models');
    model_santosh = model_tmp.models{component};
    model_santosh_hyp = model_santosh;
    model_santosh_hyp.thresh = -1.5;

    santosh_thresh = model_santosh_hyp.thresh;
    moin_thresh = 120;%80;

    % Patch models
    model_selected = patch_per_comp.models_selected;
    relpos_patch_normal_selected = patch_per_comp.relpos_patch_normal_selected;

    % Detection on PASCAL VOC
    [ds_santosh] = pascal_test_santosh(voc_test,model_santosh,finalresdir,'santosh'); % the result by Santosh
    [ds_santosh_hyp] = pascal_test_santosh(voc_test,model_santosh_hyp,finalresdir,['santosh_hyp_th',num2str(santosh_thresh)]); % the result by Santosh with higher thershold to have more boxes
    
    %[ds_moin_median] = pascal_test_moin_IIT(model_selected,voc_test,relpos_patch_normal_selected,moin_thresh,'moin_median_IIT');  % the result by Moin
    [ds_moin_median] = pascal_test_moin(model_selected,voc_test,relpos_patch_normal_selected,moin_thresh,finalresdir,['moin_median_th',num2str(moin_thresh)]);  % the result by Moin
    
    [ds_santoshANDmoin] = merge_ds_moin_santosh(ds_moin_median,ds_santosh_hyp,moin_thresh,santosh_thresh); % Merge Moin & Santosh
    
    [ds_moinONsantosh] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santoshANDmoin,w_sel,finalresdir,'moinONsantosh');

    resultname = [finalresdir 'result_20oct14_' num2str(numPatches) '.mat'];
    save(resultname,'ds_santosh','ds_santosh_hype','ds_moin_median','ds_santoshANDmoin','ds_moinONsantosh');
    
end

% Compute AP and plot PR curve
ap_santosh = pascal_eval(voc_dir,cls, ds_santosh,testset, testyear, 'santosh');
ap_moin_median = pascal_eval(voc_dir,cls, ds_moin_median,testset, testyear, 'moin_median');
ap_santoshANDmoin = pascal_eval(voc_dir,cls, ds_santoshANDmoin,testset, testyear, 'moinANDsantosh');
ap_moinONsantosh = pascal_eval(voc_dir,cls, ds_moinONsantosh ,testset, testyear, 'moinONsantosh');
