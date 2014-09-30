%% generic script to run distributed stuff
%% Santosh Divvala 

mkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numel(fn));
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
    
    disp(['Processing image ' num2str(f)]);
    savename = [resdir '/' strtok(fn{f},'.') '.mat'];
    if ~exist(savename, 'file')
        
        %% do something
    end
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end


%%%%%%%%
function bool = mymkdir_dist(dirName)

[smesg, smess, smessid] = mkdir(dirName);
bool = ~strcmp(smessid,'MATLAB:MKDIR:DirectoryExists');

%%%%%%%%
function myRandomize

if  exist('RandStream', 'builtin')
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)))
else
    try
        rand('twister', sum(100*clock));
    catch
        rand('seed', sum(100*clock));
    end
end
