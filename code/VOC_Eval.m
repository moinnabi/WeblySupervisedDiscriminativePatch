%% Evaluation ON PASCAL VOC 2007
voc_dir = '/home/moin/datasets/PASCALVOC/';
[voc_test,ids] = loadVOC_test(voc_dir,'2007','test');
%UW% model_tmp = load('/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
model_tmp = load('data/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
model_santosh = model_tmp.models{component};
santosh_thresh = model_santosh.thresh;
moin_thresh = 80;

model_santosh_hyp = model_santosh;
model_santosh_hyp.thresh = -1.5;

%w_sel_moin = w_sel(1:25);
w_sel_moin = ones(26,1);

setting_suffix = '';

%% New
%[ds_m] = pascal_test_santosh(voc_test,model_selected{24},'moin_t');
%[ds_santosh] = pascal_test_santosh(voc_test,model_santosh,'santosh');
[ds_santosh_hyp] = pascal_test_santosh(voc_test,model_santosh_hyp,'santosh_hype-1.5');
%[ds_moinONsantosh,scores_all_moinONsantosh] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santosh,w_sel,'moinONsantosh_newModel_2');
[ds_moinONsantosh,scores_all_moinONsantosh] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santosh_hyp,w_sel,'moinONsantosh_newModel_hyp_2');
figure;
%ap_moinONsantosh = pascal_eval(voc_dir,cls, ds_moinONsantosh,testset, testyear, 'moinONsantosh_newModel_2');
ap_moinONsantosh = pascal_eval(voc_dir,cls, ds_moinONsantosh,testset, testyear, 'moinONsantosh_newModel_hyp_2');


ap_moinONsantosh = pascal_eval(voc_dir,cls, ds_moinONsantosh,testset, testyear, 'moinONsantosh_newModel_hyp');

ap_m = pascal_eval(voc_dir,cls, ds_m,testset, testyear, 'moin_tt');



%%
%[ds_santosh] = pascal_test_santosh(voc_test,model_santosh,'santosh');
[ds_santosh_hyp] = pascal_test_santosh(voc_test,model_santosh_hyp,'santosh_hype-1.5');

%%
%[ds_moin_all] = pascal_test_moin(model_selected,voc_test,relpos_patch_normal_selected,detection_thre,'moin_all');
[ds_moin_median] = pascal_test_moin_median(model_selected,voc_test,relpos_patch_normal_selected,moin_thresh,'moin_median_newPatchs');
%[ds_moinONmoin,scores_all_moinONmoin] = moin_rescoring_moin(model_selected,relpos_patch_normal_selected,voc_test,ds_moin_median,w_sel_moin,'moinONmoin');

%%
%[ds_santoshONmoin] = santosh_rescoring_moin(ds_moin_median,voc_test,model_santosh,santosh_thresh);
%[ds_santoshANDmoin] = merge_ds_moin_santosh(ds_moin_median,ds_santosh_hyp,santosh_thresh); %removed zero santosh detection
[ds_santoshANDmoin] = merge_ds_moin_santosh(ds_santoshONmoin,ds_santosh_hyp,santosh_thresh); %removed zero santosh detection
[ds_moinONsantosh,scores_all_moinONsantosh] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santoshANDmoin,w_sel,'moinONsantosh_newPaches');

%tic; [ds_moinONsantosh_hyp,scores_all_moinONsantosh_hyp] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santosh_hyp,w_sel,'moinONsantosh_hyp'); toc;

ds_moinONsantosh_hyp_sub = ds_subset_selection(ds_moinONsantosh_hyp, -18);

ap_moinONsantosh_hyp = pascal_eval(voc_dir,cls, ds_moinONsantosh_hyp,testset, testyear, 'moinONsantosh_hyp');
ap_moinONsantosh_hyp_sub = pascal_eval(voc_dir,cls, ds_moinONsantosh_hyp_sub,testset, testyear, 'moinONsantosh_hyp_sub');

%%
cls = 'horse'; testset =  'test'; testyear = '2007';
%ap_santosh = pascal_eval(voc_dir,cls, ds_santosh,testset, testyear, 'santosh');
ap_santosh_hyp = pascal_eval(voc_dir,cls, ds_santosh_hyp,testset, testyear, 'santosh_hype-1.5');
%ap_moin = pascal_eval(voc_dir,cls, ds_moin_all,testset, testyear, 'moin_all');
ap_moin_median = pascal_eval(voc_dir,cls, ds_moin_median,testset, testyear, 'moin_median_newPatchs');
ap_santoshONmoin = pascal_eval(voc_dir,cls, ds_santoshONmoin,testset, testyear, 'santoshONmoin');
ap_santoshANDmoin = pascal_eval(voc_dir,cls, ds_santoshANDmoin,testset, testyear, 'santoshANDmoin_newPatchs');
ap_moinONsantosh = pascal_eval(voc_dir,cls, ds_moinONsantosh,testset, testyear, 'moinONsantosh_newPatchs');
ap_moinONsantosh_sub = pascal_eval(voc_dir,cls, ds_moinONsantosh_sub,testset, testyear, 'moinONsantosh_sub');

%
ap_moinONmoin = pascal_eval(voc_dir,cls, ds_moinONmoin,testset, testyear, 'moinONmoin');
