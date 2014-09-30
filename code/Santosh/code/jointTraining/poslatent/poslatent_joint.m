function [num_entries, num_examples, fusage, component_usage, scores] ...
    = poslatent_joint(t, iter, model, pos, fg_overlap, num_fp)
% get positive examples using latent detections
% we create virtual examples by flipping each image left to right

conf = voc_config();
model.interval = conf.training.interval_fg;
numpos = length(pos);
pixels = model.minsize * model.sbin / 2;
minsize = prod(pixels);
fusage = zeros(model.numfilters, 1);
component_usage = zeros(length(model.rules{model.start}), 1);
scores = [];
num_entries = 0;
num_examples = 0;
batchsize = max(1, 2*try_get_matlabpool_size());

% collect positive examples in parallel batches
for i = 1:batchsize:numpos
    % do batches of detections in parallel
    thisbatchsize = batchsize - max(0, (i+batchsize-1) - numpos);
    % data for batch
    clear('data');
    empties = cell(1, thisbatchsize);
    data = struct('boxdata', empties, 'pyra', empties);
    parfor k = 1:thisbatchsize 
        j = i+k-1;
                        
        msg = sprintf('%s %s: iter %d/%d: latent positive: %d/%d', ...
            procid(), model.class, t, iter, j, numpos);
        % skip small examples
        if max(pos(j).sizes) < minsize
            data(k).boxdata = cell(length(pos(j).sizes), 1);
            fprintf('%s (all too small)\n', msg);
            continue;
        end

        if pos(j).thisPosModelId == 0
            data(k).boxdata = cell(length(pos(j).sizes), 1);
            fprintf('%s (box ignored in prev it)\n', msg);
            continue;
        end

        % do whole image operations
        im = color(imreadx(pos(j)));
        im2 = im;
        [im, boxes] = croppos(im, pos(j).boxes);
        if numel(im2) ~= numel(im) 
            % dsk 31Mar13: I am assuming for wsup, croppos would just
            % return the same image and box as the box is already large
            % enogh and nothing more to crop
            disp('bbox bleeding logic may not hold. will it?'); keyboard; 
        end
        
        % following lines added by DSK
        %%% artificially set bias to high value, so that it would prefer that component
        %[pyra, model_dp] = gdetect_pos_prepare(im, model, boxes, fg_overlap);
        model_tmp = model;
        blabel = model_tmp.rules{model_tmp.start}(pos(j).thisPosModelId).offset.blocklabel;
        model_tmp.blocks(blabel).w = 100;          
        [pyra, model_dp] = gdetect_pos_prepare(im, model_tmp, boxes, fg_overlap);
        
        data(k).pyra = pyra;
        borderoffset1 = round(0.035 * size(im,2)); borderoffset2 = round(0.035 * size(im,1));
        
        % process each box in the image
        num_boxes = size(boxes, 1);
        for b = 1:num_boxes
            % skip small examples
            if pos(j).sizes(b) < minsize
                data(k).boxdata{b} = [];
                fprintf('%s (%d: too small)\n', msg, b);
                continue;
            end
            fg_box = b;
            bg_boxes = 1:num_boxes;
            bg_boxes(b) = [];
            [ds, bs, trees] = gdetect_pos(data(k).pyra, model_dp, 1+num_fp, ...
                fg_box, fg_overlap, bg_boxes, 0.5);
                                    
            % if box coords bleed outside image boundaries, reject this box
            % (might not gel well with truncated instances but will avoid
            % detectors getting stuck to image boundaries)            
            %if ds(1,1) < 1 || ds(1,2) < 1 || ds(1,3) > size(im,2) || ds(1,4) > size(im,1)
            %if ds(1,1) < boxes(b,1) || ds(1,2) < boxes(b,2) || ds(1,3) > boxes(b,3) || ds(1,4) > boxes(b,4)
            if ds(1,1) < borderoffset1 || ds(1,2) < borderoffset2 || ds(1,3) > size(im,2)-borderoffset1 || ds(1,4) > size(im,1) - borderoffset2
                data(k).boxdata{b} = [];
                fprintf('%s (%d: box bleeds outside boundary)\n', msg, b);
                continue;
            end
                        
            if bs(1,end-1) ~= pos(j).thisPosModelId
                disp('isntance not assigned to correct comp in joint training without reclustering'); keyboard;
            end
            
            data(k).boxdata{b}.bs = bs;
            data(k).boxdata{b}.trees = trees;
            if ~isempty(bs)
                fprintf('%s (%d: comp %d  score %.3f)\n', msg, b, bs(1,end-1), bs(1,end));
            else
                fprintf('%s (%d: no overlap)\n', msg, b);
            end
        end
        model_dp = [];
    end
    % write feature vectors sequentially
    for k = 1:thisbatchsize
        j = i+k-1;
        % write feature vectors for each box
        for b = 1:length(pos(j).dataids)
            if isempty(data(k).boxdata{b})
                continue;
            end
            dataid = pos(j).dataids(b);
            bs = gdetect_write(data(k).pyra, model, data(k).boxdata{b}.bs, ...
                data(k).boxdata{b}.trees, true, dataid);
            if ~isempty(bs)
                fusage = fusage + getfusage(bs(1,:));
                component = bs(1,end-1);
                component_usage(component) = component_usage(component) + 1;
                num_entries = num_entries + size(bs, 1) + 1;
                num_examples = num_examples + 1;
                %loss = max([1; bs(:,end)]) - bs(1,end);
                %losses = [losses; loss];
                scores = [scores; bs(1,end)];
            end
        end
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
