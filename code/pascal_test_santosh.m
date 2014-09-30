function [ds_santosh] = pascal_test_santosh(voc_test,model_santosh,suffix)

%UW% addpath(genpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/'));
addpath(genpath('dpm-voc-release5/'));

% VOC_root = ['/homes/grail/moinnabi/datasets/PASCALVOC/VOC',testyear,'/VOCdevkit']; addpath([VOC_root '/VOCcode']); VOCinit; cachedir = [VOC_root,'/results/VOC2007/Main/']; ids_2 = textread(sprintf(VOCopts.imgsetpath, testset), '%s');


% run detector in each image
try
  load(['../data/result/ds_',suffix,'.mat'],'ds_santosh');
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
    [ds_santosh, bs] = imgdetect(im, model_santosh, model_santosh.thresh);
    if ~isempty(bs)
      unclipped_ds = ds_santosh(:,1:4);
      [ds_santosh, bs, rm] = clipboxes(im, ds_santosh, bs);
      unclipped_ds(rm,:) = [];

      % NMS
      I = nms(ds_santosh, 0.5);
      ds_santosh = ds_santosh(I,:);
      %bs = bs(I,:);
      %unclipped_ds = unclipped_ds(I,:);

      % Save detection windows in boxes
      ds_out{i} = ds_santosh(:,[1:4 end]);

    else
      ds_out{i} = [];
      %bs_out{i} = [];
    end
  end
  th = toc(th);
  ds_santosh = ds_out;
  %bs = bs_out;
  save(['../data/result/ds_',suffix,'.mat'],'ds_santosh');
  %fprintf('Testing took %.4f seconds\n', th);
end