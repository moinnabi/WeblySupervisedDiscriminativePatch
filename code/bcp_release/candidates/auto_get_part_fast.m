function [I, bbox, gtbox] = auto_get_part(params, stream, amount,percent_min,percent_max,num_candidates)
% [I, bbox] = auto_get_part(params, stream, amount, num_candidates)
%
% Automatically get a part, given a cell array of images/bboxes.
%
% Input:
%   params: parameters for the dataset, including paths to data
%   stream: cell array of structs containing the fields I, bbox, and id
%   amount (optional): the amount of parts to get (1 by default)
%   num_candidates (optional): the amount of candidate bbox's to consider
%                              (10 by default);
%
% Output:
%   I: image path, or cell array of image paths
%   bbox: bounding box, or cell array of bounding boxes
%

if ~exist('amount', 'var')
    amount = 1;
end

if ~exist('num_candidates', 'var')
    num_candidates = 5;
end

try
    
    if amount == 1  % If only one part is requested, return the image and bbox directly.
        [I, bbox] = auto_get_single_part(params, stream,percent_min,percent_max);
    else  % Otherwise, return the images and bboxes in corresponding cell arrays.
        I = cell(1, amount);
        bbox = cell(1, amount);
        gtbox = cell(1, amount);
        for i = 1:amount
            [I1, bbox1, gt_bbox1] = auto_get_single_part(params, stream,percent_min,percent_max);
            I{i} = I1;
            bbox{i} = bbox1;
            gtbox{i} = gt_bbox1;
        end
    end
catch
    disp('check error'); keyboard;
end

%%%%%%%%%%%%%%%%%%
function [I, bbox, gt_bbox] = auto_get_single_part(params, stream,percent_min,percent_max)
% Choose a random image and bbox from stream. Since each bbox in rec.bbox
% is in a separate row, we choose a random row from rec.bbox.

try
rec = stream{randsample(length(stream), 1)};
I = rec.I;
%im = convert_to_I(I);
gt_bbox = rec.bbox(randsample(size(rec.bbox, 1), 1), :);
gt_height = gt_bbox(4)-gt_bbox(2);
gt_width = gt_bbox(3)-gt_bbox(1);

candidate_sizes = [7 10]; % Potential sizes of models (Removing 3... I think that's too small) %MOIN: add 10 instead

% Accumulate candidate parts and scores to weight them by.
% Get random width, height, and location for part within gt_bbox.
%part_width = gt_width*(rand*(1-1/4) + 1/4); %randsample(max(1, floor(gt_width/4)):gt_width, 1);
part_width = randsample(max(1, floor(gt_width*percent_min)):gt_width*percent_max, 1); % by Moin
%part_height = gt_height*(rand*(1-1/4) + 1/4); %randsample(max(1, floor(gt_height/4)):gt_height, 1);
part_height = randsample(max(1, floor(gt_height*percent_min)):gt_height*percent_max, 1); %by Moin
% randsample behaves differently based on the size of its input, so
% enforce the minimum values for part_x and part_y
part_x = max(gt_bbox(1), randsample(gt_bbox(1):(gt_bbox(3)-part_width), 1));
part_y = max(gt_bbox(2), randsample(gt_bbox(2):(gt_bbox(4)-part_height), 1));
part_bbox = [part_x part_y (part_x+part_width) (part_y+part_height)];

% Compute the energy of that part, with a random filter size.
%hg_size = [randsample(2:7, 1), randsample(2:7, 1)]; % This never gets used by e-svm
%hg_size = [8 8]; 
maxdim = randsample(candidate_sizes, 1);

% Store the bbox and its energy score
bbox = [part_bbox maxdim];

catch
    disp('check error2'); keyboard;
end


%%%%%%%%%%%%%%%%
function bbox = weighted_rand_select_bbox(bboxes, scores)
% Returns one row of bboxes, randomly selected with more weight given to
% higher scoring bboxes.

% Create weighted ranges from scores, normalized to go from 0 to 1.
ranges = cumsum(scores);
ranges = ranges ./ ranges(end);

% Return the bbox corresponding to the range the random number falls into.
rand_n = rand();
for i = 1:length(ranges)
    if rand_n < ranges(i)
        bbox = bboxes(i, :);
        return;
    end
end

%%%%%%%%%%%%%
function feat = get_feature(im, bbox, maxdim)
% Get the HOG features encased in bbox best fitting the filter size.
init_params.sbin = 8;
%init_params.hg_size = hg_size;
init_params.MAXDIM = maxdim;
m = initialize_goalsize_model(im, bbox, init_params);
feat = m.x;

