function [pos, neg, impos] = pascal_data_wsup(cls, year, borderoffset)
% Get training data from the PASCAL dataset.
%   [pos, neg, impos] = pascal_data(cls, year)
%
% Return values
%   pos     Each positive example on its own
%   neg     Each negative image on its own
%   impos   Each positive image with a list of foreground boxes
%
% Arguments
%   cls     Object class to get examples for
%   year    PASCAL dataset year

try
    
if nargin < 3
    borderoffset = 0;
end

conf       = voc_config('pascal.year', year);
dataset_fg = conf.training.train_set_fg;
dataset_bg = conf.training.train_set_bg;
cachedir   = conf.paths.model_dir;
VOCopts    = conf.pascal.VOCopts;

try
  load([cachedir cls '_' dataset_fg '_' year]);
catch
  % Positive examples from the foreground dataset
  [ids, gt]      = textread(sprintf(VOCopts.clsimgsetpath, cls, dataset_fg), '%s %d');
  ids = ids(gt == 1);
  pos      = [];
  impos    = [];
  numpos   = 0;
  numimpos = 0;
  dataid   = 0;
  for i = 1:length(ids);
    tic_toc_print('%s: parsing positives (%s %s): %d/%d\n', ...
                  cls, dataset_fg, year, i, length(ids));
    % Parse record and exclude difficult examples
    rec           = PASreadrecord(sprintf(VOCopts.annopath, ids{i}));
    %disp('replace clsinds =1 with clsinds = strmatch'); keyboard;
    clsinds       = strmatch(cls, {rec.objects(:).class}, 'exact');
    %clsinds       = 1;
    diff          = [rec.objects(clsinds).difficult];
    clsinds(diff) = [];
    count         = length(clsinds(:));
    % Skip if there are no objects in this image
    if count == 0
      continue;
    end

    borderoffset1 = round(borderoffset * rec.imgsize(1)); % width
    borderoffset2 = round(borderoffset * rec.imgsize(2)); % height
    
    % Create one entry per bounding box in the pos array
    for j = clsinds(:)'
      numpos = numpos + 1;
      dataid = dataid + 1;
      bbox   = rec.objects(j).bbox;
      bbox(1) = bbox(1) + borderoffset1;
      bbox(2) = bbox(2) + borderoffset2;
      bbox(3) = bbox(3) - borderoffset1;
      bbox(4) = bbox(4) - borderoffset2;
      
      pos(numpos).im      = sprintf(VOCopts.imgpath, ids{i});
      pos(numpos).x1      = bbox(1);
      pos(numpos).y1      = bbox(2);
      pos(numpos).x2      = bbox(3);
      pos(numpos).y2      = bbox(4);
      pos(numpos).boxes   = bbox;
      pos(numpos).flip    = false;
      pos(numpos).trunc   = rec.objects(j).truncated;
      pos(numpos).dataids = dataid;
      pos(numpos).sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);

      % Create flipped example
      numpos  = numpos + 1;
      dataid  = dataid + 1;
      oldx1   = bbox(1);
      oldx2   = bbox(3);
      bbox(1) = rec.imgsize(1) - oldx2 + 1;
      bbox(3) = rec.imgsize(1) - oldx1 + 1;

      pos(numpos).im      = sprintf(VOCopts.imgpath, ids{i});
      pos(numpos).x1      = bbox(1);
      pos(numpos).y1      = bbox(2);
      pos(numpos).x2      = bbox(3);
      pos(numpos).y2      = bbox(4);
      pos(numpos).boxes   = bbox;
      pos(numpos).flip    = true;
      pos(numpos).trunc   = rec.objects(j).truncated;
      pos(numpos).dataids = dataid;
      pos(numpos).sizes   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end

    % Create one entry per foreground image in the impos array
    numimpos                = numimpos + 1;
    impos(numimpos).im      = sprintf(VOCopts.imgpath, ids{i});
    impos(numimpos).boxes   = zeros(count, 4);
    impos(numimpos).dataids = zeros(count, 1);
    impos(numimpos).sizes   = zeros(count, 1);
    impos(numimpos).flip    = false;

    for j = 1:count
      dataid = dataid + 1;
      bbox   = rec.objects(clsinds(j)).bbox;
      bbox(1) = bbox(1) + borderoffset1;
      bbox(2) = bbox(2) + borderoffset2;
      bbox(3) = bbox(3) - borderoffset1;
      bbox(4) = bbox(4) - borderoffset2;
      
      impos(numimpos).boxes(j,:) = bbox;
      impos(numimpos).dataids(j) = dataid;
      impos(numimpos).sizes(j)   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end

    % Create flipped example
    numimpos                = numimpos + 1;
    impos(numimpos).im      = sprintf(VOCopts.imgpath, ids{i});
    impos(numimpos).boxes   = zeros(count, 4);
    impos(numimpos).dataids = zeros(count, 1);
    impos(numimpos).sizes   = zeros(count, 1);
    impos(numimpos).flip    = true;
    unflipped_boxes         = impos(numimpos-1).boxes;
    
    for j = 1:count
      dataid  = dataid + 1;
      bbox    = unflipped_boxes(j,:);
      oldx1   = bbox(1);
      oldx2   = bbox(3);
      bbox(1) = rec.imgsize(1) - oldx2 + 1;
      bbox(3) = rec.imgsize(1) - oldx1 + 1;

      impos(numimpos).boxes(j,:) = bbox;
      impos(numimpos).dataids(j) = dataid;
      impos(numimpos).sizes(j)   = (bbox(3)-bbox(1)+1)*(bbox(4)-bbox(2)+1);
    end
  end

  % Negative examples from the background dataset
  [ids, gt]    = textread(sprintf(VOCopts.clsimgsetpath, cls, dataset_bg), '%s %d');
  ids = ids(gt == -1);
  neg    = [];
  numneg = 0;
  for i = 1:length(ids);
    tic_toc_print('%s: parsing negatives (%s %s): %d/%d\n', ...
                  cls, dataset_bg, year, i, length(ids));
      dataid             = dataid + 1;
      numneg             = numneg+1;
      neg(numneg).im     = sprintf(VOCopts.imgpath, ids{i});
      neg(numneg).flip   = false;
      neg(numneg).dataid = dataid;    
  end
  
  save([cachedir cls '_' dataset_fg '_' year], 'pos', 'neg', 'impos');
end

catch
    disp(lasterr); keyboard;
end
