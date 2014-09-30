numpos = 0;
for img_ind=1:30

img = ps{img_ind}.I;
bb = ps_detect{img_ind}.patches{patch_ind};

numpos = numpos +1;

     pos_new(numpos).im      = img;
      pos_new(numpos).x1      = bb(1);
      pos_new(numpos).y1      = bb(2);
      pos_new(numpos).x2      = bb(3);
      pos_new(numpos).y2      = bb(4);
      pos_new(numpos).boxes   = bb;
      pos_new(numpos).flip    = false;
      %pos(numpos).trunc   = rec.objects(j).truncated;
      pos_new(numpos).dataids = 'new';
      pos_new(numpos).sizes   = (bb(3)-bb(1)+1)*(bb(4)-bb(2)+1);
end
      pos = pos_new;
      neg = pos;
      
      
      spos = split(pos_new, 1);
      
          models{i} = root_model(cls, spos{i}, note);
    % Split the i-th aspect ratio group into two clusters: 
    % left vs. right facing instances
    inds = lrsplit(models{i}, spos{i});
    % Train asymmetric root filter on one of these groups
    models{i} = train(models{i}, spos{i}, neg_large, true, true, 1, 1, ...
                      max_num_examples, fg_overlap, 0, false, ...
                      ['MoinModel_' num2str(i)]);