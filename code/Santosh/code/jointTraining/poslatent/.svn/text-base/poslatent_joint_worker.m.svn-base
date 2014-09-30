function poslatent_joint_worker(resdir)
% get positive examples using latent detections
% we create virtual examples by flipping each image left to right

try
    
load([resdir '/data.mat'], 'conf', 't', 'iter', 'model', 'pos', 'fg_overlap', 'num_fp');

model.interval = conf.training.interval_fg;
numpos = length(pos);
pixels = model.minsize * model.sbin / 2;
minsize = prod(pixels);

% collect positive examples in parallel batches
%for f = 1:numpos
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numpos); 
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
    
    %disp(['Doing ' num2str(f)]);
    fname = [resdir '/output_' num2str(f) '.mat'];
    try
        load(fname, 'boxdata', 'pyra');
        boxdata;
    catch
        msg = sprintf('%s %s: iter %d/%d: latent positive: %d/%d', ...
            procid(), model.class, t, iter, f, numpos);
                
        boxdata = [];
        if max(pos(f).sizes) > minsize      % skip small examples            
            if pos(f).thisPosModelId ~= 0   % box not skipped in prev iteration
                % do whole image operations
                im = color(imreadx(pos(f)));
                im2 = im;
                [im, boxes] = croppos(im, pos(f).boxes);
                if numel(im2) ~= numel(im), disp('bbox bleeding logic may not hold. will it?'); keyboard; end
                
                % following lines added by DSK
                %%% artificially set bias to high value, so that it would prefer that component
                %[pyra, model_dp] = gdetect_pos_prepare(im, model, boxes, fg_overlap);
                model_tmp = model;
                blabel = model_tmp.rules{model_tmp.start}(pos(f).thisPosModelId).offset.blocklabel;
                model_tmp.blocks(blabel).w = 100;
                [pyra, model_dp] = gdetect_pos_prepare(im, model_tmp, boxes, fg_overlap);
                
                borderoffset1 = round(0.035 * size(im,2)); borderoffset2 = round(0.035 * size(im,1));
                
                % process each box in the image
                num_boxes = size(boxes, 1);
                for b = 1:num_boxes
                    % skip small examples
                    if pos(f).sizes(b) < minsize
                        boxdata{b} = [];
                        fprintf('%s (%d: too small)\n', msg, b);
                        continue;
                    end
                    fg_box = b;
                    bg_boxes = 1:num_boxes;
                    bg_boxes(b) = [];
                    [ds, bs, trees] = gdetect_pos(pyra, model_dp, 1+num_fp, ...
                        fg_box, fg_overlap, bg_boxes, 0.5);
                    
                    if ds(1,1) < borderoffset1 || ds(1,2) < borderoffset2 || ds(1,3) > size(im,2)-borderoffset1 || ds(1,4) > size(im,1) - borderoffset2
                        boxdata{b} = [];
                        fprintf('%s (%d: box bleeds outside boundary)\n', msg, b);
                        continue;
                    end
                    if bs(1,end-1) ~= pos(f).thisPosModelId, disp('isntance not assigned to correct comp in joint training without reclustering'); keyboard; end
                    
                    boxdata{b}.ds = ds;
                    boxdata{b}.bs = bs;
                    boxdata{b}.trees = trees;
                    if ~isempty(bs)
                        fprintf('%s (%d: comp %d  score %.3f)\n', msg, b, bs(1,end-1), bs(1,end));
                    else
                        fprintf('%s (%d: no overlap)\n', msg, b);
                    end
                end
                model_dp = [];
            else
                boxdata = cell(length(pos(f).sizes), 1);
                fprintf('%s (box ignored in prev it)\n', msg);
            end
        else
            boxdata = cell(length(pos(f).sizes), 1);
            fprintf('%s (all too small)\n', msg);
        end
    
        % takes about 2 sec as pyra is ~30mb (when done in batch; should be higher in parallel as multiple jobs write to disk)
        save(fname, 'boxdata');
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch
    disp(lasterr); keyboard;
end
