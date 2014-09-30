function tmpboxes = decodeDets(tmpboxes, minscore)
% do this only if scores are calibrated; if scores are negative, then this
% doesnt make sense


% 
if nargin < 2
    minscore = 0.1;     % assuming scores are all calibrated to [0 1]
end

overlapratio = 0.7;

[blah, boxgroups] = bboxNonMaxSuppression(tmpboxes(:,1:4), tmpboxes(:,6), overlapratio);
%[blah, boxgroups] = bboxNonMaxSuppression_pedroNMS(tmpboxes(:,1:4), tmpboxes(:,6), overlapratio);

ungrps = unique(boxgroups);
for j=ungrps(:)'
    tinds = find(boxgroups == j);
    % do the decoding/rescoring only if the max score in the grouop is
    % above a threshold (idea is to not reinforce really bad detections)    
    [maxval maxind] = max(tmpboxes(tinds,end));
    %if maxval > minscore        
        tmpboxes(tinds(maxind), end) = sum(tmpboxes(tinds,end));
        %tmpboxes(tinds, end) = prod(tmpboxes(tinds,end));
    %end    
end
