function [xl yt xb yr] = getDiffBox(cbox_new, cbox)

[x1 y1 x2 y2] = getThisBoxCoords(cbox);
[X1 Y1 X2 Y2] = getThisBoxCoords(cbox_new);
xl = X1-x1;     %X1>x1
yt = Y1-y1;     %Y1>y1
xb = x2-X2;     %x2>X2
yr = y2-Y2;     %y2>Y2
