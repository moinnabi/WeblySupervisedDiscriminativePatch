% cx, cy, rad can be column vectors of values

function draw_circle(cx, cy, rad, color, ln_wid)

if nargin < 5
   ln_wid = 1.5;
end

if nargin < 4
    color = 'y';
end

theta = 0:0.1:(2*pi+0.1);
cx1 = cx(:,ones(size(theta)));
cy1 = cy(:,ones(size(theta)));
rad1 = rad(:,ones(size(theta)));
theta = theta(ones(size(cx1,1),1),:);
X = cx1+cos(theta).*rad1;
Y = cy1+sin(theta).*rad1;
line(X', Y', 'Color', color, 'LineWidth', ln_wid);
