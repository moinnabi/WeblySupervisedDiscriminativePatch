function nonv = getBoxNonOverlap2(box, boxes)
% this version takes box,boxes as [x1 y1 x2 y2]
% ov = computeOverlap(box, boxes)

% first box is gtruth

box = box(:, [1 3 2 4]);
boxes = boxes(:, [1 3 2 4]); 

nboxes = size(boxes, 1);
%ov = zeros(nboxes, 1);
nov = zeros(nboxes, 1);

bi=[max(box(1),boxes(:, 1))  max(box(3),boxes(:, 3))  ...
    min(box(2),boxes(:, 2))  min(box(4),boxes(:, 4))];

iw=bi(:, 3)-bi(:, 1)+1;
ih=bi(:, 4)-bi(:, 2)+1;

ind = iw >0 & ih > 0; % others have no intersection
if any(ind)
    a1 = (boxes(ind, 2)-boxes(ind, 1)+1).*(boxes(ind, 4)-boxes(ind, 3)+1);
    a2 = (box(2)-box(1)+1)*(box(4)-box(3)+1);    

    intersectArea = iw(ind).*ih(ind);
    unionArea = a1 + a2 - intersectArea;
    %ov(ind) = intersectArea ./ unionArea;
    nonv(ind) = (a1 - intersectArea) ./ a2;
end
