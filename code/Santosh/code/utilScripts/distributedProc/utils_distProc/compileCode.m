function compileCode(compiledir, func)
% first see compileCode_v2

try

if exist(compiledir, 'dir')
    rmdir(compiledir, 's'); 
end
mymkdir(compiledir);

[paths_tba, blah, cfiles_tba, precompdir] = myaddpath(0);
if 0    
    for k=1:length(paths_tba)
        %system(['cp -rpL ' files_tba{k} ' ' compiledir]);
        system(['cp -rpL ' [paths_tba{k} filesep '*'] ' ' compiledir]);
    end
    
    currdir=cd(compiledir);
    mcc('-m', func);
    cd(currdir);
else
    % after compiling code, just copy the executable
    thisprecompdir = [precompdir '/code_' func '/'];
    system(['cp -rpL ' thisprecompdir '/' func ' ' compiledir]);
    % and all the .py, .sh files
    system(['cp -rpL ' thisprecompdir '/*.py'  ' ' compiledir]);
    system(['cp -rpL ' thisprecompdir '/*.sh'  ' ' compiledir]);
    system(['cp -rpL ' thisprecompdir '/*.c'  ' ' compiledir]);
    system(['cp -rpL ' thisprecompdir '/*.cpp'  ' ' compiledir]);
    
    % and all the dependent files (for reference)
    %{
    files_tbc = getFileDependencies(func);
    for k=1:length(files_tbc)
        system(['cp -rpL ' files_tbc{k} ' ' compiledir]);
    end
    %}        
    system(['cp ' thisprecompdir '/../code_' func '.tgz'  ' ' compiledir '/']);
end

catch
    disp(lasterr); keyboard;
end

% files_tbc = getFileDependencies(func);
% for k=1:length(files_tbc)    
%     system(['cp -rpL ' files_tbc{k} ' ' compiledir]);
% end

