function vr = rescale(v)
% from Svetlana

low = min(v(:));
high = max(v(:));

% rescale v between 0 and 1
vr = (v - low) ./ (high - low);
