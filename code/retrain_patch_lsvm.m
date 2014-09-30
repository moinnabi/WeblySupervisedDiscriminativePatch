function model_retrained = retrain_patch_lsvm(ps,voc_ng_train,ps_detect,ng_detect,patch_ind,ps_th,ng_th)


[ps_score,ng_score,~] = compute_disc_score(ps_detect,ng_detect,1,1,0.25);

% ps_th = 70;
% ng_th = 20;

ps_ind = find(ps_score(:,patch_ind)>ps_th);
ng_ind = find(ng_score(:,patch_ind)>ng_th);

ps_num = length(ps_ind);
ng_num = length(ng_ind);

%creat positive samples
clear pos;
numpos = 0;
dataid = 0;
for i = 1:ps_num
    img_ind = ps_ind(i);

    img = ps{img_ind}.I;
    bb = ps_detect{img_ind}.patches{patch_ind};

    numpos = numpos +1;
    dataid = dataid +1;
    pos(numpos).im      = img;
    pos(numpos).x1      = bb(1);
    pos(numpos).y1      = bb(2);
    pos(numpos).x2      = bb(3);
    pos(numpos).y2      = bb(4);
    pos(numpos).boxes   = bb;
    pos(numpos).flip    = false;
    %pos(numpos).trunc   = rec.objects(j).truncated;
    pos(numpos).dataids = dataid;
    pos(numpos).sizes   = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1);

    % Flip
    numpos = numpos+1;
    dataid  = dataid + 1;
    oldx1   = bb(1);
    oldx2   = bb(3);
    [~,w,~] = size(imread(img));
    bb(1) = w - oldx2 + 1;
    bb(3) = w - oldx1 + 1;
    pos(numpos).im      = img;
    pos(numpos).x1      = bb(1);
    pos(numpos).y1      = bb(2);
    pos(numpos).x2      = bb(3);
    pos(numpos).y2      = bb(4);
    pos(numpos).boxes   = bb;
    pos(numpos).flip    = true;
    %pos(numpos).trunc   = rec.objects(j).truncated;
    pos(numpos).dataids = dataid;
    pos(numpos).sizes   = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1);
    
end

%creat negative samples
clear neg;
numneg = 0;
%dataid = 0;
for i = 1:ng_num
    img_ind = ng_ind(i);
    img = voc_ng_train(img_ind).im;
    bb = ng_detect{img_ind}.patches{patch_ind};

    numneg = numneg +1;
    dataid = dataid +1;
    neg(numneg).im      = img;
    neg(numneg).x1      = bb(1);
    neg(numneg).y1      = bb(2);
    neg(numneg).x2      = bb(3);
    neg(numneg).y2      = bb(4);
    neg(numneg).boxes   = bb;
    neg(numneg).flip    = false;
    %neg(numneg).trunc   = rec.objects(j).truncated;
    neg(numneg).dataid = dataid;
    neg(numneg).sizes   = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1);

end

% %visualize
% for i=1:length(pos)
%     patch_ind = 7;
%     figure; showboxes(imread(pos(i).im),pos(i).boxes);
% end
% 
% 
% for i=1:length(ng_ind)
%     img_ind = ng_ind(i);
%     %patch_ind = 7;
%     figure; showboxes(imread(voc_ng_train(img_ind).im),ng_detect{img_ind}.patches{patch_ind});
% end

% Training DPM
addpath(genpath('dpm-voc-release5/'));

%max_num_examples = 100000;
% fg_overlap = 0.7;
% num_negatives_small = 200;
% num_fp = 0;
% 
% neg_perm  = neg(randperm(ng_num));
% neg_small = neg_perm(1:min(ng_num, num_negatives_small));
% neg_large = neg;

model_root = root_model_santosh('subcategory', pos);

[inds_lr,inds_rl] = lrsplit(model_root, pos);

models{1} = dpm_moin(model_root, pos(inds_lr), neg, 'lr_Moin');
%models{2} = dpm_moin(model_root, pos(inds_rl), neg_large, 'rl_Moin');

%model_mix = model_merge(models);
model_mix = models{1};
model_parts = model_mix;
%
  for i = 1:1%2
    % Top-level rule for this component
    ruleind = i;
    % Top-level rule for this component's mirror image
    %partner = i+1;
    partner = [];
    % Filter to interoplate parts from
    filterind = i;
    model_parts = model_add_parts(model_parts, model_parts.start, ruleind, ...
                            partner, filterind, 8, [6 6], 1);
    % Enable learning location/scale prior
    bl = model_parts.rules{model_parts.start}(i).loc.blocklabel;
    model_parts.blocks(bl).w(:)     = 0;
    model_parts.blocks(bl).learn    = 1;
    model_parts.blocks(bl).reg_mult = 1;
  end
  % Train using several rounds of positive latent relabeling
  % and data mining on the small set of negative images

model_retrained = model_parts;