function sampleMainScript_warp
%run this command on the warp command prompt: 
% multimachine_warp_depfun('sampleMainScript_warp', numImages, resdir, numJobs)

try
basedir = '/lustre/sdivvala/';    
datadir = fullfile(basedir, 'data');
resdir = fullfile(basedir, 'results'); mymkdir(resdir);

load([datadir '/data.mat'], 'arr');

mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numel(arr));
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
