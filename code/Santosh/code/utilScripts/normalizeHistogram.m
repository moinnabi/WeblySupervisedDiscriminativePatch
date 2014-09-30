function hist2 = normalizeHistogram(hist)
% hist2 = normalizeHistogram(hist)
% Normalizes histogram across 2nd dimension
%
% hist2 = hist ./ repmat(sum(hist, 2), 1, size(hist, 2));

hist2 = hist ./ repmat(sum(hist, 2), 1, size(hist, 2));
