function consistancy_flg = pos_consistency_check(relpos_examplar,relpos_candidate,deform_param)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:4
    def(i) = abs(relpos_examplar(i) - relpos_candidate(i));% < deform_param;
end

%if ~isempty(find (def > deform_param, 1)) 
%if sum(def) > deform_param

%can be modeled later as a fuzzy 
% deform_param(1) = def(1)+def(3);
% deform_param(2) = def(2)+def(4);


if def(1)+def(3) > deform_param(1) || def(2)+def(4) > deform_param(2)%for normalized relative position
    consistancy_flg = 0;
else
    consistancy_flg = 1;

end