function [keep2, group, keep3] = bboxNonMaxSuppression_expertSel(bbox, score, maxoverlap)
% bbox([x1 y1 x2 y2])

% this script is not being used yet

% sort by confidence, lowest first
[tmp, si] = sort(score, 'descend');
bbox = bbox(si, :);

tmpind = (1:numel(score));
keep = true(numel(score), 1);

if nargout>1
    group = zeros(numel(score), 1, 'uint32');
end

ngrps = 0;
for i = 1:numel(score)
    ov = getBoxOverlap(bbox(i, [1 3 2 4]), bbox(keep(1:i-1), [1 3 2 4]));
    if any(ov>maxoverlap)
        keep(i) = false;
        if nargout>1
            [maxov, ind] = max(ov);
            ind2 = tmpind(keep(1:i-1));
            group(i) = group(ind2(ind));
        end
    elseif nargout>1
        ngrps = ngrps+1;
        group(i) = ngrps;
    end
end
keep2 = false(size(score));
keep2(si(keep)) = true;
keep3 = si(keep);

if nargout>1
    group2 = zeros(numel(score),1);
    group2(si) = group;
    group = group2;
end
