function [sp_consist_score_all,sp_consistancy_score,sp_consist_binary] = spatial_consistency_score(relpos_examplar,relpos_candidate,deform_param_patch)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

%sp_consistancy_score = [0 0];
for i = 1:4
    def(i) = abs(relpos_examplar(i) - relpos_candidate(i));% < deform_param;
end

sp_consistancy_score(1) = def(1)+def(3);
sp_consistancy_score(2) = def(2)+def(4);
sp_consist_score_all = sqrt((sp_consistancy_score(1)*sp_consistancy_score(1)) + (sp_consistancy_score(2)*sp_consistancy_score(2))); %norm of the deformation along w and h
%sp_consist_score_all = sp_consistancy_score(1) + sp_consistancy_score(2);

if sp_consistancy_score(1) > deform_param_patch(1) || sp_consistancy_score(2) > deform_param_patch(2)%for normalized relative position
    sp_consist_binary = 0;
else
    sp_consist_binary = 1;

end