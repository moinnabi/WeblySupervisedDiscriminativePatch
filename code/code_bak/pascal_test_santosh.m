function [ds] = pascal_test_santosh(voc_test,model_santosh,suffix)

% VOC_root = ['/homes/grail/moinnabi/datasets/PASCALVOC/VOC',testyear,'/VOCdevkit'];
% addpath([VOC_root '/VOCcode']);
% VOCinit;

%cachedir = [VOC_root,'/results/VOC2007/Main/'];

%ids_2 = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% run detector in each image
try
  load(['data/boxes_',suffix,'.mat'],'ds');
catch
  % parfor gets confused if we use VOCopts
  %opts = VOCopts;
  %num_ids = length(ids);
  num_ids = length(voc_test);
  ds_out = cell(1, num_ids);
  bs_out = cell(1, num_ids);
  th = tic();
  parfor i = 1:num_ids;
    disp([num2str(i), ' / ' ,num2str(num_ids)]);
    im = imread(voc_test(i).im);
    [ds, bs] = imgdetect(im, model_santosh, model_santosh.thresh);
    if ~isempty(bs)
      unclipped_ds = ds(:,1:4);
      [ds, bs, rm] = clipboxes(im, ds, bs);
      unclipped_ds(rm,:) = [];

      % NMS
      I = nms(ds, 0.5);
      ds = ds(I,:);
      %bs = bs(I,:);
      %unclipped_ds = unclipped_ds(I,:);

      % Save detection windows in boxes
      ds_out{i} = ds(:,[1:4 end]);

    else
      ds_out{i} = [];
      %bs_out{i} = [];
    end
  end
  th = toc(th);
  ds = ds_out;
  %bs = bs_out;
  save(['data/boxes_',suffix,'.mat'],'ds');
  fprintf('Testing took %.4f seconds\n', th);
end