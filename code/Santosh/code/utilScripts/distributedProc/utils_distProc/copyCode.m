function copyCode(compiledir)

try
if exist(compiledir, 'dir')
    rmdir(compiledir, 's'); 
end
mymkdir(compiledir);

[paths_tba, myaddpath_fpath] = myaddpath(0);
system(['cp -rpL ' myaddpath_fpath ' ' compiledir]);
for k=1:length(paths_tba)
    %copyfile([paths_tba{k} filesep '*'], compiledir);  % copyfile uses cp -rp!!
    system(['cp -rpL ' [paths_tba{k} filesep '*'] ' ' compiledir]);
end
pause(5);
    
catch
    disp(lasterr); keyboard;
end
