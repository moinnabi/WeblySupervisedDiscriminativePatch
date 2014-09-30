%Demo for horse category

clear all;
%addpath
addpath(genpath('bcp_release/'));
addpath('Santosh/');
%addpath(genpath('libsvm-3.17/'));
addpath('/projects/grail/moinnabi/eccv14/');

run bcp_release/setup.m
run bcp_release/startup;
%addpath(genpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/'));
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/gdetect/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/features/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/model/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/utils/');
% addpath('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/vis/');
% run('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/startup.m');
% run('/projects/grail/moinnabi/eccv14/Santosh/code/other_codes/voc-release5/compile.m');
% addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));

%matlabpool open;

%Parameters
category = 'horse';
dir_main = ['/projects/grail/santosh/objectNgrams/results/ngram_models/',category,'/kmeans_6/'];

%dir_sub = dir(fullfile(dir_main));
model_tmp = load([dir_main,'baseobjectcategory_horse_SNN_buildTree_Comp/baseobjectcategory_horse_joint.mat']);
list_sub = model_tmp.model.phrasenames;

[~, voc_ng_train] = loadVOC(category,'2007','train');

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

    datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
    try
        load(datafname, 'ps','patch_per_comp');
    catch  
        %Load Data of Santosh
        ps = load_component_data(dir_data,dir_class,posscores_thresh,component);
        %run subcategory part mining demo
        patch_per_comp = demo_subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,category,component);
%         sp_ap_flag = 1; %just spatial consistancy
%         initial_patchs = subcategory_init(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,sp_ap_flag);
%         top_num_part = 5;
%         [part_selected, score_all, patch_precision] = select_patch(initial_patchs,top_num_part);
%         visualize_parts(patch_per_com);
        
        
        save(datafname, 'ps','patch_per_comp');
    end
end
        

%Test on Pascal 2007 horse class
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



for img =1 : length(selected_images)
    img;
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
    
%     color_list = ['y','m','c','r','g','b','w'];
%     sc_th = 40;
%     sp_th = 0.5;
% 
%     part_activated = zeros(length(part_selected_ind),1);
%     part_activated_sp = zeros(length(part_selected_ind),1); % ONLY spatial consistancy (intersect/union)
%     part_activated(find(all_score > sc_th)) = 1;
%     part_activated_sp(find(vertcat(sp_score{:}) > sp_th)) = 1; % ONLY spatial consistancy (intersect/union)
% 
%     all_detected = vertcat(detection_loc{:});
%     all_activated = all_detected(find(part_activated),:);
%     all_activated_sp = all_detected(find(part_activated_sp),:); % ONLY spatial consistancy (intersect/union)
%     
%     
%     for prt = 1:length(part_selected_ind)%25 
%         color{prt} = color_list(1+mod(prt,7));
%     end
%     colors =vertcat(color{find(part_activated)});
%     colors_sp =vertcat(color{find(part_activated_sp)}); % ONLY spatial consistancy (intersect/union)
%     
%     figure; showbox_color(im_current,gt_bbox,'b',2,'-',0)
%     showbox_color(im_current,all_activated,colors,1,'--',1)
%     %text
%     for prt = 1:25
%         str1 = ['Patch-',num2str(prt),' : '];
%         str2 = num2str(all_score(prt));
%         if part_activated(prt) == 1
%             text(500,15*prt,str1,'FontSize',8,'color',color{prt},'FontWeight','bold');
%             text(550,15*prt,str2,'FontSize',6,'color',color{prt},'FontWeight','bold');
%         else
%             text(500,15*prt,str1,'FontSize',8);
%             text(550,15*prt,str2,'FontSize',6);
%         end
%     end
%     %
%     savehere = ['/projects/grail/moinnabi/eccv14/data/visualization/context_rescoring/'];
%     saveas(gcf, [savehere,'/sp_app/','detectedPatches_img_',num2str(img),'.png']);
%     close all;
% 
%     figure; showbox_color(im_current,gt_bbox,'b',2,'-',0)
%     showbox_color(im_current,all_activated_sp,colors_sp,1,'--',1);
% %text
%     for prt = 1:25
%         str1 = ['Patch-',num2str(prt),' : '];
%         str2 = num2str(all_score(prt));
%         if part_activated_sp(prt) == 1
%             text(500,15*prt,str1,'FontSize',8,'color',color{prt},'FontWeight','bold');
%             text(550,15*prt,str2,'FontSize',6,'color',color{prt},'FontWeight','bold');
%         else
%             text(500,15*prt,str1,'FontSize',8);
%             text(550,15*prt,str2,'FontSize',6);
%         end
%     end
%     %
%     saveas(gcf, [savehere,'/sp/','detectedPatches_img_',num2str(img),'.png']);
%     close all;
    
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

%Full samples

%on-zero samples
%>>libsvmwrite('data-2_norm.txt', l_selected, sparse(f_selected_normal)) %run in matlab
%>>python grid.py ../data-2.txt % run in terminal in this directory libsvm-3.17/tools/
%2.0 0.5 96.7118
%addpath(genpath('libsvm-3.17/matlab/'));
%model_scores_selected = svmtrain(l_selected, f_selected_normal,'-t 0 -v 10');
%model_scores_selected = svmtrain(l_selected, f_selected_normal,'-c 2 -g 0.5');
model_scores_selected = svmtrain(l_selected, f_selected_normal,'-t 0 -c 512');

w_sel = model_scores_selected.SVs' * model_scores_selected.sv_coef;
b_sel = -model_scores_selected.rho;

if model_scores_selected.Label(1) == -1
    w_sel = -w_sel;
    b_sel = -b_sel;
end

%save('data/svm-model.mat','feature','w_sel','b_sel','model_scores_selected','f_selected_normal','l_selected');


%%%%%%%%%%%%%%%%%%%%%%

[voc_test,ids] = loadVOC_test('2007','test');

model_tmp = load('/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat','models');
%model_santosh = model_tmp.models{component};
%addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));
%suffix = 'test-santosh';
%[ds_santosh] = pascal_test_santosh(model_santosh, 'test', '2007', suffix,'horse');
%addpath(genpath('bcp_release/'));
%%w_sel = [0;ones(25,1)];
%[ds_santosh_rescored] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santosh,w_sel,suffix);
%ap_santosh_rescored = pascal_eval_santosh(cls, ds_santosh_rescored, testset, testyear, 'santosh-rescored');%suffix);

%%
model_santosh_th_1p5 = model_tmp.models{component};
model_santosh_th_1p5.thresh = -1.5;
addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));
suffix = 'test-santosh_th_1p5';
[ds_santosh_th_1p5] = pascal_test_santosh(model_santosh_th_1p5, 'test', '2007', suffix,'horse');
addpath(genpath('bcp_release/'));
[ds_santosh_rescored_th_1p5] = moin_rescoring_santosh(model_selected,relpos_patch_normal_selected,voc_test,ds_santosh_th_1p5,w_sel,suffix);
ap_santosh_rescored_th_1p5 = pascal_eval_santosh(cls, ds_santosh_rescored_th_1p5, testset, testyear,suffix);
%

[ds_moin] = run_moin_on_dataset(model_selected,voc_test);

%[voc_test_detect] = part_detection_inbox(model_selected,voc_test);



%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%
[voc_test,ids] = loadVOC_test('2007','test');

% disp('doing part inference on PASCAL-VOC Positive/Negative');
 %[voc_test_detect] = run_detection_on(model_selected,voc_test);
 %[voc_test_detect_all] = run_detection_on(models_all,voc_test);
 %saveload([finalresdir 'imgdata_VOC_test.mat'], 'voc_test_detect','voc_test_detect_all');
 
%%%%%Detection && Evaluation%%%%%
% 
voc_detect = voc_test_detect;
relpos_patch = relpos_patch_normal_selected;
% voc_detect = voc_test_detect_all;
% relpos_patch = relpos_patch_normal;


detrespath = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/results/VOC2007/Main/%s_det_val_%s.txt';
file_name = 'test-1';

%top_n = 2;
med_flg = 1;
%med_flg = 0;
%write_detect_infile_topn(voc_detect,ids,relpos_patch,detrespath,file_name,top_n,med_flg)
%[recall,prec,ap]=VOCevaldet(VOCopts,'test-1','horse',true);

detection_thre = 80;
write_detect_infile_thres(voc_detect,ids,relpos_patch,detrespath,file_name,detection_thre,med_flg)
[recall,prec,detected_moin]=VOCevaldet(VOCopts,file_name,'horse',true);

%%%%%Evaluation of Santosh%%%%%
model_tmp = load('/projects/grail/santosh/objectNgrams/results/ngram_models/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat');
model_santosh = model_tmp.models{1};
testset = 'test';
testyear = '2007';
cls = 'horse';
suffix = 'test-santosh';

ds_santosh = pascal_test_santosh(model_santosh, testset, testyear, suffix,cls);
ap_santosh = pascal_eval_santosh(cls, ds_santosh, testset, testyear, suffix);
