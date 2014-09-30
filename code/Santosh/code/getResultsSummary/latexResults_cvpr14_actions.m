function latexResults_cvpr14_actions

try
    
basedir = '/projects/grail/santosh/objectNgrams/';
resultsdir_nfs = fullfile(basedir, 'results');
numcomp = 6;

[myClasses, myClasses2] = VOCoptsClasses;
myClasses = myClasses(21:25);
myClasses2 = myClasses2(21:25);   
numclasses = numel(myClasses);  
vocyear = '2011';
testdatatype = 'val';

pff_v5  = [6.1 4.1 10.9 47.1 1.1];
%ridingbike: 41.6


% load results data
rocvals = zeros(numclasses,1);
rocvals25 = zeros(numclasses,1);
for objind = 1:numclasses
    
    objname = myClasses{objind};    
    ngramModeldir_obj = [resultsdir_nfs '/ngram_models/' objname '/' ['kmeans_' num2str(numcomp)] '/'];
    baseobjdir = [ngramModeldir_obj '/baseobjectcategory_' objname '_SNN_buildTree_Comp/']; mymkdir(baseobjdir);    
    
    resfname = [baseobjdir '/' 'baseobjectcategory_' objname '_pr_' testdatatype '_' vocyear '_joint_50.mat'];
    resfname25 = [baseobjdir '/' 'baseobjectcategory_' objname '_pr_' testdatatype '_' vocyear '_joint_25.mat'];
    if exist(resfname, 'file')  
        tmp = load(resfname, 'ap_base');
        rocvals(objind) = tmp.ap_base*100;  
        
        tmp = load(resfname25, 'ap_base');
        rocvals25(objind) = tmp.ap_base*100;
    end    
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

fprintf('VP~\\cite{deva_eccv12} & ');
for objind = 1:numclasses  
    if rocvals(objind) ~= 0       
        fprintf('%2.1f & ', pff_v5(objind));
    end
end   
fprintf('%1.1f \\\\ \\hline \n ', mean(pff_v5(rocvals~=0)));
fprintf('\n');

fprintf('Ours & ');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0        
        fprintf('%2.1f & ', rocvals(objind));
    end
end
fprintf('%1.1f \\\\ \\hline \n ', mean(rocvals(rocvals~=0)));

fprintf('Ours (25) & ');
for objind = 1:numclasses    
    if rocvals(objind) ~= 0        
        fprintf('%2.1f & ', rocvals25(objind));
    end
end
fprintf('%1.1f \\\\ \\hline \n ', mean(rocvals25(rocvals~=0)));
 
catch
    disp(lasterr); keyboard;
end