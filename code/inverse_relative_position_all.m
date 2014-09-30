function part_bbox = inverse_relative_position_all(root_bbox,relpos_patch,norm_fl)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%by Moin
part_bbox = cell(1,25);
for ptc = 1:length(relpos_patch)
    relpos = relpos_patch{ptc};
    part_bbox{ptc} = inverse_relative_position(root_bbox,relpos,norm_fl);
end
end

function part_bbox = inverse_relative_position(root_bbox,rel_position,norm_fl)

xb1 = root_bbox(1); yb1 = root_bbox(2); xb2 = root_bbox(3); yb2 = root_bbox(4); %GT bounding box

if norm_fl
    w = xb2-xb1; h = yb2-yb1;
else
    w =1; h=1;
end
l = w*rel_position(1); t = h*rel_position(2); r = w*rel_position(3); b = h*rel_position(4); %GT bounding box
xp1 = l+xb1; yp1 = t+yb1; xp2 = r+xb1; yp2 = b+yb1; %part
part_bbox(1)=xp1; part_bbox(2)=yp1; part_bbox(3)=xp2; part_bbox(4)=yp2;

end