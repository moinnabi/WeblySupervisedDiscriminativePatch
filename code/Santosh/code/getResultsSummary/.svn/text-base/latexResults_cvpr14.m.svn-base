function latexResults_cvpr14

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
siva_iccv11 = [.134 .440 .031 .031 .000 .312 .439 .071 .001 .093 .099 .015 .294 .383 .046 .001 .004 .038 .342 .000001]*100;
khan_11 = [11.8 39.6 0 3.4 0 36.7 34.2 0 0 0 0 0 7.0 34.5 0 0 0 0 11.9 0];

% load results data
rocvals = zeros(numclasses,1);
rocvals25 = zeros(numclasses,1);
pff_v5  = zeros(numclasses,1);
pff_v5_25 = zeros(numclasses,1);
for objind = 1:numclasses
    
    objname = myClasses{objind};    
    ngramModeldir_obj = [resultsdir_nfs '/ngram_models/' objname '/' ['kmeans_' num2str(numcomp)] '/'];
    baseobjdir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(baseobjdir);    
    
    resfname = [baseobjdir '/' 'baseobjectcategory_' objname '_pr_test_' vocyear '_joint_50.mat'];
    resfname25 = [baseobjdir '/' 'baseobjectcategory_' objname '_pr_test_' vocyear '_joint_25.mat'];
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
fprintf('%7s\t', 'MEAN');
fprintf('\n');

%{
fprintf('%7s\t', 'Lana');
for objind = 1:numclasses  
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', lana_iccv11(objind));
    end
end
fprintf('%7.1f\t', mean(lana_iccv11(rocvals~=0)));
fprintf('\n');
%}

fprintf('~\\cite{siva_iccv11} & ');
for objind = 1:numclasses  
    if rocvals(objind) ~= 0       
        if siva_iccv11(objind) > max(ferrari_cvpr12(objind), rocvals(objind))
            fprintf('{\\bf %2.1f} & ', siva_iccv11(objind));
        else
            fprintf('%2.1f & ', siva_iccv11(objind));
        end
    end
end   
fprintf('\\\\ \\hline \n ');
%fprintf('%1.1f \\\\ \\hline \n ', mean(siva_iccv11(rocvals~=0)));
%fprintf('\n');

fprintf('~\\cite{ferrari_cvpr12} & ');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0        
        if ferrari_cvpr12(objind) ~= 0
            if ferrari_cvpr12(objind) > max(siva_iccv11(objind), rocvals(objind))
                fprintf('{\\bf %2.1f} & ', ferrari_cvpr12(objind));
            else
                fprintf('%2.1f & ', ferrari_cvpr12(objind));
            end
        else
            fprintf('- & ');
        end
    end
end
fprintf('\\\\ \\hline \n ');
%fprintf('%1.1f \\\\ \\hline \n ', mean(ferrari_cvpr12(rocvals~=0)));

fprintf('Ours & ');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0
        if rocvals(objind) > max(siva_iccv11(objind), ferrari_cvpr12(objind))
            fprintf('{\\bf %2.1f} & ', rocvals(objind));
        else
            fprintf('%2.1f & ', rocvals(objind));
        end
    end
end
fprintf('\\\\ \\hline \n ');
%fprintf('%1.1f \\\\ \\hline \n ', mean(rocvals(rocvals~=0)));

fprintf('Ours (25) & ');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0        
        fprintf('%2.1f & ', rocvals25(objind));
    end
end
fprintf('\\\\ \\hline \n ');
fprintf('\\hline \n ');
%fprintf('%1.1f \\\\ \\hline \n ', mean(rocvals25(rocvals~=0)));

fprintf('~\\cite{Felzenszwalb10} & ');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0       
        fprintf('%2.1f & ', pff_v5(objind));
    end
end
fprintf('\\\\ \\hline \n ');
%fprintf('%1.1f \\\\ \\hline \n ', mean(pff_v5(rocvals~=0)));

fprintf('~\\cite{Felzenszwalb10} (25) & ');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0
        fprintf('%2.1f & ', pff_v5_25(objind));        
    end
end
fprintf('\\\\ \\hline \n ');
%fprintf('%1.1f \\\\ \\hline \n ', mean(pff_v5_25(rocvals~=0)));

catch
    disp(lasterr); keyboard;
end

%{
function latexResults_cvpr14

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
siva_iccv11 = [.134 .440 .031 .031 .000 .312 .439 .071 .001 .093 .099 .015 .294 .383 .046 .001 .004 .038 .342 .000]*100;
khan_11 = [11.8 39.6 0 3.4 0 36.7 34.2 0 0 0 0 0 7.0 34.5 0 0 0 0 11.9 0];

% load results data
rocvals = zeros(numclasses,1);
rocvals25 = zeros(numclasses,1);
pff_v5  = zeros(numclasses,1);
pff_v5_25 = zeros(numclasses,1);
for objind = 1:numclasses
    
    objname = myClasses{objind};    
    ngramModeldir_obj = [resultsdir_nfs '/ngram_models/' objname '/' ['kmeans_' num2str(numcomp)] '/'];
    baseobjdir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(baseobjdir);    
    
    resfname = [baseobjdir '/' 'baseobjectcategory_' objname '_pr_test_' vocyear '_joint_50.mat'];
    resfname25 = [baseobjdir '/' 'baseobjectcategory_' objname '_pr_test_' vocyear '_joint_25.mat'];
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
fprintf('%7s\t', 'Siva');
for objind = 1:numclasses  
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', siva_iccv11(objind));
    end
end   
fprintf('\n');
fprintf('%7s\t', 'Khan');
for objind = 1:numclasses  
    if rocvals(objind) ~= 0
        fprintf('%7.1f\t', khan_11(objind));
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
%}
