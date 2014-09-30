function [deform_param_patch] = deform_param(im,mdl,fixed_deform_flag)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
if fixed_deform_flag
    deform_param_patch = [0.3 0.3];
else
    %compute deformation parameter for each patch based on running it
    %detector on the examplar image and find how defomable it is by
    %ignoring nms step on detection
    %deform_param_patch = [0.2 0.2];
    thresh = -0.5;
    
    mdl.maxsize = [10 10];
    mdl.sbin = 8;
    mdl.interval = 10;
        
    mdl.features.sbin = 8;
    mdl.features.dim = 32;
    mdl.features.bias = 10;
    mdl.features.extra_octave = 0;
    mdl.features.truncation_dim = 32;
    
    boxes = imgdetect(im, mdl,thresh);

end

