function ds = imgdetect2(im, models, model, thresh, goodcomps)
% running 6 comps together is same speed as running 1 comp (without parts);
% so I am not using this

% used by pascal_test_sumpool_selectedComps

im = color(im);
pyra = featpyramid(im, model);
numComps = numel(model.rules{model.start});
ds = [];
for kk=1:numComps
    if goodcomps(kk) == 1        
        ds_tmp = gdetect(pyra, models{kk}, thresh);
        if ~isempty(ds_tmp)
            ds = [ds; ds_tmp(:, 1:4) kk*ones(size(ds_tmp,1),1) ds_tmp(:,end)];
        end
    end
end

%%%%%%%
% below gives same result as above but is slower (since it cmputes pyramid
% per component)
function ds = imgdetect2_tmp(im, models, model, thresh, goodcomps)

numComps = numel(model.rules{model.start});
ds = [];
im = color(im);
for kk=1:numComps
    if goodcomps(kk) == 1
        pyra = featpyramid(im, models{kk});
        ds_tmp = gdetect(pyra, models{kk}, thresh);
        if ~isempty(ds_tmp)
            ds = [ds; ds_tmp(:, 1:4) kk*ones(size(ds_tmp,1),1) ds_tmp(:,end)];
        end
    end
end
