function [ ds ] = DetPatch( img , model, thresh )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
im = color(img);
pyra = featpyramid(im, model);
%numComps = numel(model.rules{model.start});
ds = [];
ds_tmp = gdetect(pyra, model, thresh);
if ~isempty(ds_tmp)
   ds = [ds; ds_tmp(:, 1:4) ones(size(ds_tmp,1),1) ds_tmp(:,end)];
end

end

