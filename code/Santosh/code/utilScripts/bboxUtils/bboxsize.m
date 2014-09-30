function bsiz = bboxsize(bbox)
% returns bbox size i.e., area

%for i=1:size(bbox,1)
%    bsiz(i) = (bbox(i,3)-bbox(i,1)) * (bbox(i,4)-bbox(i,2));
%end
if ~isempty(bbox)
    bsiz = (bbox(:,3)-bbox(:,1)) .* (bbox(:,4)-bbox(:,2));
else
    bsiz =[];
end
%bsiz = bsiz(:);
