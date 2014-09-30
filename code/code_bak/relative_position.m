function rel_position = relative_position(gt_bbox,part_bbox,norm_fl)
%Finding relative postition of two bounding box, which are inside each other former is bigger one
%   by Moin Nabi
%
xb1 = gt_bbox(1); yb1 = gt_bbox(2); xb2 = gt_bbox(3); yb2 = gt_bbox(4); %GT bounding box
xp1 = part_bbox(1); yp1 = part_bbox(2); xp2 = part_bbox(3); yp2 = part_bbox(4); %part
w = xb2-xb1; h = yb2-yb1;
l = xp1-xb1 ; t = yp1-yb1;  r = xp2-xb1; b = yp2-yb1;
if norm_fl
    rel_position = [l/w , t/h , r/w , b/h]; % Regionlet 
else
rel_position = [l , t , r , b];

end