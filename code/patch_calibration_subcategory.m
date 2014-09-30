function [w_sel] = patch_calibration_subcategory(patch_per_comp,dir_data,component,voc_dir)

% Load validation set per each subcategory
matfile = load([dir_data,'/mountain_horse_super_boxes_val_9990_mix.mat'],'ds_top');
txtfile = [voc_dir,'VOC9990/ImageSets/Main/mountain_horse_super_val.txt'];
cellfile = Script_readfrom_valtxt(txtfile);

[ w_sel ] = patch_calibration(patch_per_comp,matfile,cellfile,component,voc_dir);
        
        