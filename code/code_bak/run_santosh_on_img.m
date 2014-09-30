function ds = run_santosh_on_img(model_santosh,im_current,thresh)
    addpath('/homes/grail/moinnabi/Matlab/dpm-voc-release5/bin/');
    [ds, bs] = imgdetect(im_current, model_santosh, thresh);
    if ~isempty(bs)
      %unclipped_ds = ds(:,1:4);
      [ds, ~, ~] = clipboxes(im_current, ds, bs);
      %unclipped_ds(rm,:) = [];

      % NMS
      ds = nms_tomasz(ds, 0.5);
      %ds = ds(I,:);
    end