function [modnorms, modbiases] = computeModelComponentNorms(model)

[blocks, ~, rm, ~, cmps] = fv_model_args(model);

%%% see obj_func.cc >> gradient() >> max comp regularization code
modnorms = zeros(numel(cmps),1);
modbiases = zeros(numel(cmps),1);
for c=1:numel(cmps)         % for each of the N components
    norm_val = 0;    
    for i=1:numel(cmps{c})  % for each block (e.g., root, bias, part filters and biases) within this component
        b = cmps{c}(i)+1;   %+1 is added as it is 0-based index for c-program 
        reg_mult = rm(b);
        wb = blocks{b};
        norm_val = norm_val + (norm(wb)^2)*reg_mult;
    end 
    modnorms(c) = norm_val;
    modbiases(c) = blocks{cmps{c}(2)};      % this is a hack
end
