function wd = bboxwd(bbox)

%wd = bbox(:,3) - bbox(:,1);
wd = bbox(:,3) - bbox(:,1) + 1; %added 1Aug10

