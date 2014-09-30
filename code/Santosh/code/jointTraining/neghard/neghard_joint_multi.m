function [num_entries, num_examples, j, fusage, scores, complete] ...
    = neghard_joint_multi(cachedir, t, negiter, model, neg, maxsize, negpos, max_num_examples)

try    

disp('DOING NEGHARD - DISTRIBUTED');    
resdir = [cachedir '/neghardFiles_' num2str(t, '%02d') '/']; mymkdir(resdir);

numdone = length(mydir([resdir '/done/*.done']));
if numdone ~= numel(neg)

    disp('saving data');
    conf = voc_config();
    disp(['negative threshold is ' num2str(conf.threshs.joint_dmthresh)]); 
    save([resdir '/data.mat'], 'conf', 't', 'negiter', 'model', 'neg', 'maxsize', 'negpos', 'max_num_examples');

    disp('starting worker(s)');
    %neghard_joint_multi_worker(resdir);
    %compileCode_v2_depfun('neghard_joint_multi_worker', 1);
    multimachine_grail_compiled(['neghard_joint_multi_worker ' resdir], numel(neg), resdir, 200, [], 'all.q', 2, 0, 1, 0);
    
    numdone = length(mydir([resdir '/done/*.done']));
    while numdone  < numel(neg)
        pause(60);
        numdone = length(mydir([resdir '/done/*.done']));
        fprintf('%s ', [num2str(numdone) '/' num2str(numel(neg))]);
    end
    myprintfn;
end

disp('reducer');
tic;
[num_entries, num_examples, j, fusage, scores, complete] = ...
    neghard_joint_multi_reduce(resdir, t, negiter, model, neg, maxsize, negpos, max_num_examples);
toc;
 
catch
    disp(lasterr); keyboard
end
