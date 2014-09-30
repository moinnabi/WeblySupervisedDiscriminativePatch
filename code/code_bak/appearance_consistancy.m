function [app_consist_score,app_consist_binary] = appearance_consistancy(ps,ps_detect,numPatches,app_param_patch)
%app_param_patch is a thershold which the score higher than this is valid
%for considering that detected bounding box as valid one

app_consist_score = zeros(length(ps),numPatches);
app_consist_binary = zeros(length(ps),numPatches);

for prt = 1:numPatches
    for img = 1:length(ps)
        app_consist_score(img,prt) = ps_detect{img}.scores{prt};
        if app_consist_score(img,prt) > app_param_patch
            app_consist_binary(img,prt) = 1;
        else
            app_consist_binary(img,prt) = 0;
        end
    end
end     
