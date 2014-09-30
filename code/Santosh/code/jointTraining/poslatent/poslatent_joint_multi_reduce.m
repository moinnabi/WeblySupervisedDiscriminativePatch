function [num_entries, num_examples, fusage, component_usage, scores] = ...
    poslatent_joint_multi_reduce(resdir, t, iter, model, pos, fg_overlap, num_fp)

conf = voc_config();
model.interval = conf.training.interval_fg;
component_usage = zeros(length(model.rules{model.start}), 1);
scores = [];
fusage = zeros(model.numfilters, 1);
num_entries = 0;
num_examples = 0;
numpos = length(pos);
batchsize = max(1, 2*try_get_matlabpool_size());

% collect positive examples in parallel batches
%for i = 1:numpos    
for i = 1:batchsize:numpos
    % do batches of pyramid computations in parallel
    thisbatchsize = batchsize - max(0, (i+batchsize-1) - numpos);
    
    % data for batch
    clear('data');
    empties = cell(1, thisbatchsize);
    data = struct('pyra', empties);
    parfor k = 1:thisbatchsize
        j = i+k-1;
        im = color(imreadx(pos(j)));
        im = croppos(im, pos(j).boxes);
        pyra = featpyramid(im, model);
        data(k).pyra = pyra;
    end
    
    % write feature vectors sequentially
    for k = 1:thisbatchsize
        j = i+k-1;
        
        myprintf(j,10);        
        clear boxdata;
        fname = [resdir '/output_' num2str(j) '.mat'];
        load(fname, 'boxdata');
        
        % write feature vectors for each box
        for b = 1:length(pos(j).dataids)
            if isempty(boxdata{b})
                continue;
            end
            dataid = pos(j).dataids(b);
            bs = gdetect_write(data(k).pyra, model, boxdata{b}.bs, boxdata{b}.trees, true, dataid);
            if ~isempty(bs)
                fusage = fusage + getfusage(bs(1,:));
                component = bs(1,end-1);
                component_usage(component) = component_usage(component) + 1;
                num_entries = num_entries + size(bs, 1) + 1;
                num_examples = num_examples + 1;                
                scores = [scores; bs(1,end)];
            end
        end
    end    
end
myprintfn;

function s = try_get_matlabpool_size()
try
    s = matlabpool('size');
catch
    s = 0;
end

% collect filter usage statistics
function u = getfusage(bs)
numfilters = floor(size(bs, 2)/4);
u = zeros(numfilters, 1);
nbs = size(bs,1);
for i = 1:numfilters
    x1 = bs(:,1+(i-1)*4);
    y1 = bs(:,2+(i-1)*4);
    x2 = bs(:,3+(i-1)*4);
    y2 = bs(:,4+(i-1)*4);
    ndel = sum((x1 == 0) .* (x2 == 0) .* (y1 == 0) .* (y2 == 0));
    u(i) = nbs - ndel;
end
