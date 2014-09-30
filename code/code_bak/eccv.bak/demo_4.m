%Demo for horse category

clear all;
%addpath
addpath('bcp_release/');
addpath('Santosh/');
addpath('/projects/grail/moinnabi/eccv14/');
addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/vis/');
run bcp_release/setup.m
run bcp_release/startup;
addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/');
addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/utils/');


%matlabpool open;

%Parameters
category = 'horse';
dir_main = ['/projects/grail/santosh/objectNgrams/results/ngram_models/',category,'/kmeans_6/'];

%dir_sub = dir(fullfile(dir_main));
model_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat']);
list_sub = model_tmp.model.phrasenames;

[voc_ps_train, voc_ng_train] = loadVOC(category,'2007','train');

for sub_index = 1:length(list_sub)

    sub_index = 77;
    dir_class = list_sub{sub_index}(1:end-2);
    component = str2num(list_sub{sub_index}(end-1:end));
    %dir_class = 'mountain_horse_super';

    dir_data = [dir_main,dir_class,'/'];
    dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
    finalresdir = ['/projects/grail/moinnabi/eccv14/data/part_selected/',category,'/',dir_class,'/',num2str(component),'/']; mkdir(finalresdir);
    numPatches = 250;
    posscores_thresh = -1;

    datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
    try
        load(datafname, 'ps','patch_per_comp');
    catch  
        %Load Data of Santosh
        ps = load_component_data(dir_data,dir_class,posscores_thresh,component);
        %run subcategory part mining demo
        patch_per_comp = demo_subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train);
        %initial_patchs = subcategory_init(VOCopts, ps, numPatches,dir_class,dir_neg);
        %patch_per_comp = refine_subcategory(initial_patchs,voc_ng_train);
        %visualize_parts(patch_per_com)
        
        
        save(datafname, 'ps','patch_per_comp');
    end
end
        
%         %For ALL componenets in this subcategory do
%         if ~isempty(selected_comp)
%             mkdir(finalresdir);
%             for comp = 1:length(selected_comp)
%                 disp([num2str(comp),'/',num2str(length(selected_comp))]);
%                 ps = [];
%                 for sample_index = 1:num_sample_per_comp(comp)
%                     ps{1,sample_index} = ps_all{selected_comp(comp),sample_index};
%                 end
% 
%                 coverage_thershold = 0.1;
%                 %initial_patchs{comp} = subcategory_init(VOCopts, ps, numPatches,dir_class,dir_neg);
%                 %patch_per_comp{comp} = refine_subcategory(initial_patchs,voc_ng_train);
%                 patch_per_comp{comp} = demo_subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train);
%                 %visualize_parts(patch_per_comp{comp})
%             end
%             save(datafname, 'ps_all','patch_per_comp');            
%         end
%     end
% 
% end

% patch_per_comp{comp} = demo_subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train);
% save(datafname, 'ps_all','patch_per_comp');

%Test on Pascal 2007 horse class
part_selected = patch_per_comp{1}.part_selected;
models_all = patch_per_comp{1}.models_all;
relpos_patch_normal = patch_per_comp{1}.relpos_patch_normal;
ps_detect = patch_per_comp{1}.ps_detect;

part_selected_ind = find(part_selected);
model_selected = [];
relpos_patch_normal_selected = [];
for i = 1:length(part_selected_ind)
    model_selected{i} = models_all{part_selected_ind(i)};
    relpos_patch_normal_selected{i} = relpos_patch_normal{i};
end

[voc_test,ids] = loadVOC_test('2007','test');

% disp('doing part inference on PASCAL-VOC Positive/Negative');
 %[voc_test_detect] = run_detection_on(model_selected,voc_test);
 %[voc_test_detect_all] = run_detection_on(models_all,voc_test);
 %save([finalresdir 'imgdata_VOC_test.mat'], 'voc_test_detect','voc_test_detect_all');
 
%%%%%Detection && Evaluation%%%%%

% voc_detect = voc_test_detect;
% relpos_patch = relpos_patch_normal_selected;
voc_detect = voc_test_detect_all;
relpos_patch = relpos_patch_normal;

detrespath = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/results/VOC2007/Main/%s_det_val_%s.txt';
file_name = 'test-1';

%top_n = 2;
med_flg = 1;
%med_flg = 0;
%write_detect_infile_topn(voc_detect,ids,relpos_patch,detrespath,file_name,top_n,med_flg)
%[recall,prec,ap]=VOCevaldet(VOCopts,'test-1','horse',true);

detection_thre = 75;
write_detect_infile_thres(voc_detect,ids,relpos_patch,detrespath,file_name,detection_thre,med_flg)
[recall,prec,ap]=VOCevaldet(VOCopts,'test-1','horse',true);




