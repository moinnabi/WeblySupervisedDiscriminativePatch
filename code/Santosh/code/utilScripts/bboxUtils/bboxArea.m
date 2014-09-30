function ar = bboxArea(bbox)

ar = (bbox(:,4) - bbox(:,2)).*(bbox(:,3)-bbox(:,1));