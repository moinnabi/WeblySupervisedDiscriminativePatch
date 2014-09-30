function compileCode_v2(func, OVERWRITE)

try
    
if nargin < 2, OVERWRITE = 0; end
if OVERWRITE == 0, return; end

[files_tba, blah, cfiles_tba, precompdir] = myaddpath(0);
thisprecompdir = [precompdir '/code_' func '/'];

disp(' deleting old files');
if exist(thisprecompdir, 'dir')
    rmdir(thisprecompdir, 's'); 
end
mymkdir(thisprecompdir);

disp(' copying files');
for k=1:length(files_tba)
    system(['cp -rpL ' [files_tba{k} filesep '*'] ' ' thisprecompdir]);
end

disp(' compiling');
currdir = cd(thisprecompdir);
mcc('-m', func);
cd(currdir);

catch
    disp(lasterr); keyboard;
end
