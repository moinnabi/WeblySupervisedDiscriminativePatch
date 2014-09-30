%% This script has been written by Moin for ECCV submission

%Addpath and Parameter settings
clear all;
addpath('Santosh/');
addpath('/home/moin/Desktop/UW/all_UW/eccv14/');

addpath(genpath('bcp_release/'));
run bcp_release/setup.m
run bcp_release/startup;

addpath(genpath('/home/moin/Desktop/UW/all_UW/eccv14/dpm-voc-release5/'));

%  run('/home/moin/Desktop/UW/all_UW/eccv14/dpm-voc-release5/compile.m');
%  run('/home/moin/Desktop/UW/all_UW/eccv14/dpm-voc-release5/startup.m');

%matlabpool open;

%Category Parameters
category = 'horse';
dir_main = '/home/moin/Desktop/UW/all_UW/eccv14/data/model/';

model_tmp = load([dir_main,category,'.mat'],'model');
poscell_tmp = load([dir_main,category,'.mat'],'poscell');

list_sub = model_tmp.model.phrasenames;

%pascal setup
voc_dir = '/home/moin/datasets/PASCALVOC/'; 
year = '2007'; set = 'train'; 
[voc_ps_train, voc_ng_train] = VOC_load(category,year,set,voc_dir);

%For each Subcategory
for sub_index = 1:length(list_sub)
    
%     sub_index
%     list_sub{sub_index}
    sub_index = 77;
    dir_class = list_sub{sub_index}(1:end-2);
    component = str2num(list_sub{sub_index}(end-1:end));
    %dir_class = 'mountain_horse_super';
    
    ps_tmp = poscell_tmp.poscell{sub_index,1};
    
    %dir_data = [dir_main,dir_class,'/'];
    dir_neg = 'negative'; %it's supposed to be included of set of negative images for that class
    finalresdir = ['/home/moin/Desktop/UW/all_UW/eccv14/data/result/',category,'/',dir_class,'/',num2str(component),'/']; mkdir(finalresdir);
    numPatches = 25;
    %posscores_thresh = -1;

    %datafname = [finalresdir 'imgdata_moreparts_' num2str(numPatches) '.mat'];
    datafname = [finalresdir 'imgdata_' num2str(numPatches) '.mat'];
    try
        load(datafname, 'ps','patch_per_comp');
    catch
        [ps_old] = load_data_comp(ps_tmp,component,dir_class);
        %run subcategory part mining demo
        [ps_new] = download_img_db(ps_old,finalresdir);
        ps = ps_new;
        
        patch_per_comp = subcategory(VOCopts, ps, numPatches,dir_class,dir_neg,voc_ng_train,category,component);
        %
        save(datafname, 'ps','patch_per_comp');
    end
end
