function [ds_santosh] = run_santosh_on_dataset(voc_test,model_tmp,component,testset, testyear, suffix,cls)

model_santosh = model_tmp.models{component};

[ds_santosh] = pascal_test_santosh(model_santosh, testset, testyear, suffix,cls);

% for img = 1:length(ds_santosh)
%     if ~isempty(ds_santosh{1,img})
%         bbox_san{img} = vertcat(ds_santosh{1,img}(:,1:4));
%         score_san{img} = vertcat(ds_santosh{1,img}(:,5));
%     end
% end