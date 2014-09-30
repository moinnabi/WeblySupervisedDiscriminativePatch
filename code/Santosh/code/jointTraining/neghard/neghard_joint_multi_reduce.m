function [num_entries, num_examples, j, fusage, scores, complete] ...
    = neghard_joint_multi_reduce(resdir, t, negiter, model, neg, maxsize, negpos, max_num_examples)

conf = voc_config();
model.interval = conf.training.interval_bg;
fusage = zeros(model.numfilters, 1);
numneg = length(neg);
num_entries = 0;
num_examples = 0;
scores = [];
complete = 1;
batchsize = max(1, try_get_matlabpool_size());

inds = circshift(1:numneg, [0 -negpos]);
for i = 1:batchsize:numneg
    % do batches of detections in parallel
    thisbatchsize = batchsize - max(0, (i+batchsize-1) - numneg);
    %det_limit = ceil((max_num_examples - num_examples) / thisbatchsize);
    data = cell(thisbatchsize, 1);
    
    parfor k = 1:thisbatchsize         
        j = inds(i+k-1);
        im = color(imreadx(neg(j)));
        pyra = featpyramid(im, model);
        data{k}.pyra = pyra;
    end
    
    % write feature vectors sequentially    
    for k = 1:thisbatchsize
        j = inds(i+k-1);
        myprintf(j, 10);
         
        clear bs trees;
        fname = [resdir '/output_' num2str(j) '.mat'];
        load(fname, 'bs', 'trees');
        
        dataid = neg(j).dataid;        
        bs = gdetect_write(data{k}.pyra, model, bs, trees, false, dataid, maxsize, max_num_examples-num_examples);
        if ~isempty(bs)
            fusage = fusage + getfusage(bs);
            scores = [scores; bs(:,end)];
        end
        % added 2 entries for each example
        num_entries = num_entries + 2*size(bs, 1);
        num_examples = num_examples + size(bs, 1);
        
        byte_size = fv_cache('byte_size');
        if byte_size >= maxsize || num_examples >= max_num_examples
            fprintf('%s %s: iter %d/%d: hard negatives: %d/%d (%d)\n', ...
                procid(), model.class, t, negiter, i+k-1, numneg, j);
            if num_examples >= max_num_examples
                fprintf('reached example count limit\n');
            else
                fprintf('reached cache byte size limit\n');
            end
            complete = 0;
            break;
        end
    end
    if complete == 0
        break;
    end
end

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
