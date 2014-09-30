function [compinds, scores, bboxes] = ...
    poslatent_joint_multi_reduce_getInds(resdir, t, iter, model, pos, fg_overlap, num_fp)

conf = voc_config();
model.interval = conf.training.interval_fg;
numpos = length(pos);
batchsize = max(1, 2*try_get_matlabpool_size());

num = 0;
compinds = zeros(numpos, 1);
scores = -5 * ones(numpos, 1);
bboxes = zeros(numpos, 4);

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
        num = num + 1;
        if num ~= j , disp('error'); keyboard; end
        
        clear boxdata;
        fname = [resdir '/output_' num2str(j) '.mat'];
        load(fname, 'boxdata');
        
        % write feature vectors for each box
        for b = 1:length(pos(j).dataids)
            if isempty(boxdata{b})
                continue;
            end
            %dataid = pos(j).dataids(b);            
            %bs = gdetect_write(data(k).pyra, model, boxdata{b}.bs, boxdata{b}.trees, true, dataid);            
            bs = boxdata{b}.bs;
            ds = boxdata{b}.dets;
            if ~isempty(bs)                
                compinds(num) = bs(1,end-1);
                scores(num) = bs(1,end);
                bboxes(num, :) = ds(:, 1:4);
            else
                bboxes(num, :) = [pos(j).x1 pos(j).y1 pos(j).x2 pos(j).y2];
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
