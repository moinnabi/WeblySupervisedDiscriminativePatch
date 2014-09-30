% cx, cy - scalars
% Q: 2x2 matrix, transformation from unit circle to ellipse

function draw_ellipse(cx,cy,Q, color, line_width)

if nargin < 5
    line_width = 2;
end
if nargin < 4
    color = 'y';
end

theta = 0:0.1:(2*pi+0.2);
X = cos(theta);
Y = sin(theta);
XYt = Q * [X; Y];
XYt(1,:) = XYt(1,:) + cx;
XYt(2,:) = XYt(2,:) + cy;
line(XYt(1,:), XYt(2,:), 'Color',color, 'LineWidth', line_width);
