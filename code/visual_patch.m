function visual_patch(img_ind,patch_ind);

figure; showboxes(imread(ps{img_ind}.I),ps_detect{img_ind}.patches{patch_ind});