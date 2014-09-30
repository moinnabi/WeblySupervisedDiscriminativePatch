function [compinds, scores, bboxes]  = ...
    poslatent_joint_multi_getInds(cachedir, t, iter, model, pos, fg_overlap, num_fp)

try    

disp('DOINT POSLATENT - DISTRIBUTED');    
resdir = [cachedir '/poslatentFiles_getInds_' num2str(t) '/']; mymkdir(resdir);

numdone = length(mydir([resdir '/done/*.done'])); 
if numdone  ~= numel(pos)    
    
    disp('saving data');
    conf = voc_config();
    save([resdir '/data.mat'], 'conf', 't', 'iter', 'model', 'pos', 'fg_overlap', 'num_fp');

    disp('starting worker(s)');
    %poslatent_joint_worker(resdir);
    compileCode_v2_depfun('poslatent_joint_worker_getInds', 1);
    multimachine_grail_compiled(['poslatent_joint_worker_getInds ' resdir], numel(pos), resdir, 200, [], 'all.q', 2, 0, 1, 0);
    
    numdone = length(mydir([resdir '/done/*.done']));
    while numdone  < numel(pos)
        pause(60);
        numdone = length(mydir([resdir '/done/*.done']));
        fprintf('%s ', [num2str(numdone) '/' num2str(numel(pos))]);
    end
    myprintfn;
end

disp('reducer');
tic;
[compinds, scores, bboxes]  = ...
    poslatent_joint_multi_reduce_getinds(resdir, t, iter, model, pos, fg_overlap, num_fp);
toc;

catch
    disp(lasterr); keyboard
end
