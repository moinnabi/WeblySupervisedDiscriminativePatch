function sampleMainScript_hpc
%multimachine_compiled('sampleMainScript', 1000, resdir, 1)

try
basedir = '\\msr-arrays\scratch\msr-pool\REDMOND\t-sdivva';    
resdir = fullfile(basedir, 'results', 'voc2010', 'randomParts_NN_v6'); mymkdir(resdir);

mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(size(similarity_mat_img,1));
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
    disp(['Processing image ' num2str(f)]);
    
    savename = [resdir filesep num2str(f, '%03d') '.mat'];
    if ~exist(savename, 'file')
        %% DO STUFF HERE %%
        
        save(savename, '');
    else
        load(savename, '');
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch
    disp(lasterr); keyboard;
end
