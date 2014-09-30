function [detection_loc , ap_scores , sp_scores] = part_inference_inbox(im_current, model_selected, bbox_current)
% [scores detection_loc] = inference(im_current, model_selected, bbox_current)
% **im_current: image to run detector on
% **model_selected: 
% Model should have at least the following fields
%        hg_size: [8 10 31]
%              w: [8x10x31 double]
%              b: 1.6677
% **bbox_current: a R x 4 matrix encoding locations of region proposals
%    each row should encode [xmin, ymin, xmax, ymax]
%
%
% Output:  Each variable is a cell array for each of the M parts
% scores: 1 score for each region gives the highest scoring location of part m in the region
% detection_loc:  Rx4 the highest scoring location of part m for each region
% flipped: R x 1, 1 indicates that part m has been flipped for each region


% This defines the overlap requirements:
%    Let P be Part area, R be region area and
%    let I be intersection of P and R, and U be their union
% const = [min I/R, max I/R, min I/P, max I/P, min I/U, max I/U]
const = [0 1 0.8 1 0.005 1]; % By default, this says that the part must be 80% within the region and shouldn't be too small by requiring I/U be at least 0.5%

%Nreg = size(bbox_current,1);

sbin = 8;
interval = 10;

padx = ceil(model_selected{1}.hg_size(2)/2+1);
pady = ceil(model_selected{1}.hg_size(1)/2+1);

if(~isstruct(im_current)) % it's an image!
   [feat, scales] = IEfeatpyramid(im_current, sbin, interval);

   if(nargout>=2) % return precomputed features
      [feat_data.feat feat_data.scales] = deal(feat, scales);
   end
else
   [feat, scales] = deal(im_current.feat, im_current.scales);
   if(nargout>=2)
      feat_data = im_current;
   end
end

for s = 1:length(feat) % pad it
   feat{s} = padarray(feat{s}, [pady padx 0], 0);
end

[xs0 ys0] = meshgrid(1:size(feat{1},2), 1:size(feat{1},1));

if(~iscell(model_selected))
   model_selected = {model_selected};
end

for m = 1:length(model_selected)
   best_scores = zeros(size(bbox_current{m},1), 1);%-inf(size(bbox_current{m},1), 1);
   best_loc = ones(size(bbox_current{m},1), 4); % [x y s f];
   for level = 1:length(feat)
      featr = feat{level};
      scale = sbin/scales(level);

      for trans_LR = 1:1%2 for check flip of the image as well?
         if(trans_LR==1) % Standard
            filter = {model_selected{m}.w};
         else
            filter = {flipfeat(model_selected{m}.w)};
         end

         % Compute scores
         rootmatch_cell = fconv(featr(:,:,1:31), filter, 1, 1);
         rootmatch = rootmatch_cell{1};
         Sx = size(rootmatch,2);
         Sy = size(rootmatch,1);
         xs = xs0(1:Sy, 1:Sx);
         ys = ys0(1:Sy, 1:Sx);
    
         % Prune candidates: 
         min_score = min(best_scores);
         ok_score = rootmatch>min_score; % No need to consider these...
         xsub = xs(ok_score);
         ysub = ys(ok_score);
         boxes = rootbox(xsub, ysub, scale, padx, pady, model_selected{m}.hg_size(1:2));
         scores_inbox = rootmatch(ok_score);
         
%          top_score_num = 5;
%          [sortedValues_score,sortIndex_score] = sort(scores_inbox,'descend');  %# Sort importance of the parts MAX
%          maxIndex_score = sortIndex_score(1:top_score_num);
%          
%          top_boxes = zeros(top_score_num,4);
%          for iii=1:top_score_num
%             top_boxes(iii,:) = boxes(maxIndex_score(iii),:);
%          end
%          showboxes(im_current,top_boxes)

         %[best_score pos] = get_best_part(bbox_current, boxes, scores_inbox, [], [], 0.8, [], 0.1);
         %[best_score pos] = get_best_part(bbox_current, boxes, scores_inbox, [], [], 0.0001, [], 0.001); % Everything is ok
         [best_score pos] = get_best_part(bbox_current{m}, boxes, scores_inbox, const(1), const(2), const(3), const(4), const(5), const(6)); %0, 1, 0.8, 1, 0.01, 1);

         [best_scores ind] = max([best_scores, best_score], [], 2);
         updated = ind==2;
         best_loc(updated, :) = [xsub(pos(updated)), ysub(pos(updated)), repmat([level trans_LR], sum(updated), 1)];
         %figure; showboxes(im_current,rootbox(best_loc(:, 1), best_loc(:,2), sbin./scales(best_loc(:,3)), padx, pady, model_selected{m}.hg_size(1:2)));
      end
   end
   ap_scores{m} = best_scores;
   detection_loc{m} = rootbox(best_loc(:, 1), best_loc(:,2), sbin./scales(best_loc(:,3)), padx, pady, model_selected{m}.hg_size(1:2));
   a = [detection_loc{m}(1) , detection_loc{m}(2) , detection_loc{m}(3)-detection_loc{m}(1) , detection_loc{m}(4)-detection_loc{m}(2)];
   b = [bbox_current{m}(1) , bbox_current{m}(2) , bbox_current{m}(3)-bbox_current{m}(1) , bbox_current{m}(4)-bbox_current{m}(2)];
   intersect = rectint(a,b);
   union = a(3)*a(4) + b(3)*b(4) - intersect;
   sp_scores{m} = intersect / union;%intersection over union
   %flipped{m} = best_loc(:, 4) == 2;
end


function boxes = rootbox(x, y, scale, padx, pady, rsize)
x1 = (x(:)-padx).*scale(:)+1;
y1 = (y(:)-pady).*scale(:)+1;
x2 = x1 + rsize(2).*scale(:) - 1;
y2 = y1 + rsize(1).*scale(:) - 1;

boxes = [x1 y1 x2 y2];

% function ok = check_overlap(boxes, bbox_current)
% 
% ok = bbox_overlap_mex(boxes, bbox_current, 0.25)>0.25;
