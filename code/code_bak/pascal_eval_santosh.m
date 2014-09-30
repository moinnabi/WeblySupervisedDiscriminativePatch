function [ap,tp] = pascal_eval_santosh(cls, ds, testset, testyear, suffix)

VOC_root = ['/homes/grail/moinnabi/datasets/PASCALVOC/VOC',testyear,'/VOCdevkit'];
addpath([VOC_root '/VOCcode']);
VOCinit;
year = '2007';

cachedir = '/homes/grail/moinnabi/datasets/PASCALVOC/VOC2007/VOCdevkit/results/VOC2007/Main/';

ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% write out detections in PASCAL format and score
fid = fopen(sprintf(VOCopts.detrespath, suffix, cls), 'w');
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
    [recall, prec, ap] = VOCpr(VOCopts, suffix, cls, true);
  else
    % Bug in VOCevaldet requires that tic has been called first
    tic;
    [recall, prec, tp] = VOCevaldet(VOCopts, suffix, cls, true);
  end

  % force plot limits
  ylim([0 1]);
  xlim([0 1]);

  print(gcf, '-djpeg', '-r0', [cachedir cls '_pr_' testset '_' suffix '.jpg']);
end

% save results
save([cachedir cls '_pr_' testset '_' suffix], 'recall', 'prec', 'ap');