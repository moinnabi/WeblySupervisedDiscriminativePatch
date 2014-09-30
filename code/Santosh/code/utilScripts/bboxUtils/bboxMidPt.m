function midpt = bboxMidPt(bbox)

midpt = [(bbox(:,1)+bbox(:,3))/2 (bbox(:,2)+bbox(:,4))/2];

