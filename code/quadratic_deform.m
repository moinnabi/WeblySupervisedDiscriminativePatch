function [dx,dy,dx2,dy2] = quadratic_deform(detected_bbox,anchor_bbox,root_bbox)

dx = detected_bbox(1) - root_bbox(1) - anchor_bbox(1);
dy = detected_bbox(2) - root_bbox(2) - anchor_bbox(2);
dx2 = dx.*dx;
dy2 = dy.*dy;