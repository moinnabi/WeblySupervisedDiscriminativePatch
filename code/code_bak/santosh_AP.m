model_tmp = load('/projects/grail/santosh/objectNgrams/results/ngram_models_part1/horse/kmeans_6/mountain_horse_super/mountain_horse_super_parts.mat');
model = model_tmp.models{1};
testset = 'test';
testyear = '2007';
cls = 'horse';
suffix = 'test-santosh'

%%
%ds = pascal_test(model, testset, testyear, suffix);
VOC_root = ['/homes/grail/moinnabi/datasets/PASCALVOC/VOC',testyear,'/VOCdevkit'];
addpath([VOC_root '/VOCcode']);
VOCinit;

cachedir = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/results/VOC2007/Main/';

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% run detector in each image
try
  load([cachedir cls '_boxes_' testset '_' suffix]);
catch
  % parfor gets confused if we use VOCopts
  opts = VOCopts;
  num_ids = length(ids);
  ds_out = cell(1, num_ids);
  bs_out = cell(1, num_ids);
  th = tic();
  parfor i = 1:num_ids;
    fprintf('%s: testing: %s %s, %d/%d\n', cls, testset, testyear, ...
            i, num_ids);
    if strcmp('inriaperson', cls)
      % INRIA uses a mixutre of PNGs and JPGs, so we need to use the annotation
      % to locate the image.  The annotation is not generally available for PASCAL
      % test data (e.g., 2009 test), so this method can fail for PASCAL.
      rec = PASreadrecord(sprintf(opts.annopath, ids{i}));
      im = imread([opts.datadir rec.imgname]);
    else
      im = imread(sprintf(opts.imgpath, ids{i}));  
    end
    [ds, bs] = imgdetect(im, model, model.thresh);
    if ~isempty(bs)
      unclipped_ds = ds(:,1:4);
      [ds, bs, rm] = clipboxes(im, ds, bs);
      unclipped_ds(rm,:) = [];

      % NMS
      I = nms(ds, 0.5);
      ds = ds(I,:);
      bs = bs(I,:);
      unclipped_ds = unclipped_ds(I,:);

      % Save detection windows in boxes
      ds_out{i} = ds(:,[1:4 end]);

      % Save filter boxes in parts
      if model.type == model_types.MixStar
        % Use the structure of a mixture of star models 
        % (with a fixed number of parts) to reduce the 
        % size of the bounding box matrix
        bs = reduceboxes(model, bs);
        bs_out{i} = bs;
      else
        % We cannot apply reduceboxes to a general grammar model
        % Record unclipped detection window and all filter boxes
        bs_out{i} = cat(2, unclipped_ds, bs);
      end
    else
      ds_out{i} = [];
      bs_out{i} = [];
    end
  end
  th = toc(th);
  ds = ds_out;
  bs = bs_out;
  save([cachedir cls '_boxes_' testset '_' suffix], ...
       'ds', 'bs', 'th');
  fprintf('Testing took %.4f seconds\n', th);
end

%%
%ap1 = pascal_eval(cls, ds, testset, testyear, suffix);

VOC_root = ['/homes/grail/moinnabi/datasets/PASCALVOC/VOC',testyear,'/VOCdevkit'];
addpath([VOC_root '/VOCcode']);
VOCinit;
year = '2007'

cachedir = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/results/VOC2007/Main/';

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, 'comp3', cls), 'w');
for i = 1:length(ids);
  bbox = ds{i};
  for j = 1:size(bbox,1)
    fprintf(fid, '%s %f %d %d %d %d\n', ids{i}, bbox(j,end), bbox(j,1:4));
  end
end
fclose(fid);

recall = [];
prec = [];
ap = 0;

do_eval = (str2num(year) <= 2007) | ~strcmp(testset, 'test');
if do_eval
  if str2num(year) == 2006
    [recall, prec, ap] = VOCpr(VOCopts, 'comp3', cls, true);
  else
    % Bug in VOCevaldet requires that tic has been called first
    tic;
    [recall, prec, ap] = VOCevaldet(VOCopts, 'comp3', cls, true);
  end

  % force plot limits
  ylim([0 1]);
  xlim([0 1]);

  print(gcf, '-djpeg', '-r0', [cachedir cls '_pr_' testset '_' suffix '.jpg']);
end

% save results
save([cachedir cls '_pr_' testset '_' suffix], 'recall', 'prec', 'ap');
