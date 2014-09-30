function [sp_consist_score_all,sp_consist_score,sp_consist_binary,sp_consistant_parts] = spatial_consistancy(ps,ps_detect,relpos_patch,deform_param_patch,numPatches,normalize)
%sp_consist_score_all : sqrt(def(1)^2 + def(2)^2)
%sp_consist_score : is a cell including  : [def(1) , def(2)]
%sp_consist_binary: binary matrix image*part and is 0 if sp_consistancy_score(1) > def(1) || sp_consistancy_score(2) > def(2)
% sp_consistant_parts: in how many percent of images this spatial concistancy is valid?

sp_consist_score_all = zeros(length(ps),numPatches);
sp_consist_binary = zeros(length(ps),numPatches);
%sp_consistancy_score_all = zeros(length(ps),numPatches);
sp_consistant_parts = zeros(1,numPatches);

for prt = 1:numPatches
    for img = 1:length(ps)
        big_bbox = ps{1,img}.bbox(1:4);
        small_bbox = ps_detect{img}.parts{prt}(1:4); %make it 
        relpos_candidate = relative_position(big_bbox,small_bbox,1);

        [sp_consist_score_all(img,prt),sp_consist_score{img,prt},sp_consist_binary(img,prt)] = spatial_consistency_score(relpos_patch{prt},relpos_candidate,deform_param_patch{prt});
        
        if sp_consist_binary(img,prt)
            sp_consistant_parts(prt) = sp_consistant_parts(prt) +1;
        end
    end
end
if normalize
    sp_consistant_parts = sp_consistant_parts / length(ps);
else
    sp_consistant_parts = sp_consistant_parts;
end
    
