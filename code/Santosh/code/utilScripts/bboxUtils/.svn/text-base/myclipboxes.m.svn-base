function [boxes, inds] = myclipboxes(im, boxes)
% from Pedro's codebase

% boxes = clipboxes(im, boxes)
% Clips boxes to image boundary.

boxes_orig = boxes;
if ~isempty(boxes)
  boxes(:,1) = max(boxes(:,1), 1);
  boxes(:,2) = max(boxes(:,2), 1);
  boxes(:,3) = min(boxes(:,3), size(im, 2));
  boxes(:,4) = min(boxes(:,4), size(im, 1));
end
inds = find(sum(boxes(:,1:4) == boxes_orig(:,1:4), 2) == 4);
            
