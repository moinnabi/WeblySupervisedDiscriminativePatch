function latexResults_cvpr14_25nms

try
    
basedir = '/projects/grail/santosh/objectNgrams/';
resultsdir_nfs = fullfile(basedir, 'results');
numcomp = 6;

[myClasses, myClasses2] = VOCoptsClasses;
numclasses = 20; %numel(myClasses);
vocyear = '2007';

%pff_v5 = [33.2 	60.3 	10.2 	16.1 	27.3 	54.3 	58.2 	23.0 	20.0 	24.1 	26.7 	12.7 	58.1 	48.2 	43.2 	12.0 	21.1 	36.1 	46.0 	43.5];
ferrari_cvpr12 = [17.4 0 9.3  9.2 0 0 35.7 9.4 0 9.7 0 3.3   16.2   27.3  0 0 0 0 15.0 0];
lana_iccv11 = [11.5 0 0  3.0  0 0 0 0 0 0 0 0     20.4     9.1 0 0 0 0  13.2 0];

% load results data
rocvals = zeros(numclasses,1);
rocvals25 = zeros(numclasses,1);
pff_v5  = zeros(numclasses,1);
pff_v5_25 = zeros(numclasses,1);
for objind = 1:numclasses
    
    objname = myClasses{objind};    
    ngramModeldir_obj = [resultsdir_nfs '/ngram_models/' objname '/' ['kmeans_' num2str(numcomp)] '/'];
    baseobjdir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(baseobjdir);    
    
    resfname = [baseobjdir '/' 'baseobjectcategory_' objname '_pr25nms_test_' vocyear '_joint_50.mat'];
    resfname25 = [baseobjdir '/' 'baseobjectcategory_' objname '_pr25nms_test_' vocyear '_joint_25.mat'];
    if exist(resfname, 'file')  
        tmp = load(resfname, 'ap_base');
        rocvals(objind) = tmp.ap_base*100;  
        
        tmp = load(resfname25, 'ap_base');
        rocvals25(objind) = tmp.ap_base*100;  
    end
    
    
    pffv5dir = [resultsdir_nfs '/pff_v5/' objname '/'];
    presfname = [pffv5dir '/' objname '_pr_test_' vocyear '.mat'];
    presfname25 = [pffv5dir '/' objname '_pr_test_' vocyear '_25.mat'];
    tmp = load(presfname, 'ap');
    pff_v5(objind) = tmp.ap*100; 
    tmp = load(presfname25, 'ap');
    pff_v5_25(objind) = tmp.ap*100; 
end

% print results
fprintf('%7s\t', 'App'); 
for objind = 1:numclasses
    if rocvals(objind) ~= 0
        objname = myClasses2{objind};
        fprintf('%7s\t', objname);
    end
end
fprintf('\n');

fprintf('%7s\t', 'Lana');
for objind = 1:numclasses  
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', lana_iccv11(objind));
    end
end
fprintf('\n');
fprintf('%7s\t', 'Ferrari');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', ferrari_cvpr12(objind));
    end
end
fprintf('\n');
fprintf('%7s\t', 'Ours');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', rocvals(objind));
    end
end
fprintf('\n'); 
fprintf('%7s\t', 'Ours_25');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', rocvals25(objind));
    end
end
fprintf('\n'); 


fprintf('\n');
fprintf('%7s\t', 'PFF'); 
for objind = 1:numclasses    
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', pff_v5(objind));
    end
end
fprintf('\n');
fprintf('%7s\t', 'PFF_25'); 
for objind = 1:numclasses    
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', pff_v5_25(objind)); 
    end
end
fprintf('\n');

catch
    disp(lasterr); keyboard;
end
