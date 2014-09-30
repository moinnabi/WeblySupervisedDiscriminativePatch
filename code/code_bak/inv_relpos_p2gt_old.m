function gt_bbox = inv_relpos_p2gt(bbox,relpos_patch_normal)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
% This is just for normalized relative pos! (i.e. Regionlet)
%by Moin
gt_bbox = cell(1,length(bbox)); %number of all
for ptc = 1:length(relpos_patch_normal)
    gt_bbox{ptc} = inv_relpos_p2gt_in(bbox{ptc},relpos_patch_normal{ptc});
end
end

function gt_bbox = inv_relpos_p2gt_in(part_bbox,relpos)

p1=part_bbox(1); p2=part_bbox(2); p3=part_bbox(3); p4=part_bbox(4);

%w =1; h=1;
r1 = relpos(1); r2 = relpos(2); r3 = relpos(3); r4 = relpos(4); %Relpos

b3 = (p3-p1+p1*r3-r1*p3)/(r3-r1);
b1 = (p1-r1*b3)/(1-r1);
b4 = (p4-p2+p2*r4-r2*p4)/(r4-r2);
b2 = (p2-r2*b4)/(1-r2);

gt_bbox(1)=b1; gt_bbox(2)=b2; gt_bbox(3)=b3; gt_bbox(4)=b4; %GT bounding box

end