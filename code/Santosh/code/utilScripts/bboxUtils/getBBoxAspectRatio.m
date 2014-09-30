function aspects = getBBoxAspectRatio(bbox)

h = bbox(:,4) - bbox(:,2) + 1;
w = bbox(:,3) - bbox(:,1) + 1;
aspects = h ./ w;
