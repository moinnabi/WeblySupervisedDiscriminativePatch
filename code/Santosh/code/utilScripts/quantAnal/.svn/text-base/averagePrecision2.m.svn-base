function ap = averagePrecision2(roc, t)

% e.g., averagePrecision(roc, (0:0.1:1));

ap = zeros(size(roc));
for k = 1:numel(roc)
    for k2 = 1:numel(t)
        ind = (roc(k).r>=t(k2));
        if any(ind)
            ap(k) = ap(k) + max(roc(k).p(ind))/numel(t);
        else
            ap(k) = ap(k) + 0/numel(t); % is 0/numel(t) == 0 ??
        end
    end
end

%%%%
% PASCAL code to compute AP
% compute average precision
%
% ap=0;
% for t=0:0.1:1
%     p=max(prec(rec>=t));
%     if isempty(p)
%         p=0;
%     end
%     ap=ap+p/11;
% end