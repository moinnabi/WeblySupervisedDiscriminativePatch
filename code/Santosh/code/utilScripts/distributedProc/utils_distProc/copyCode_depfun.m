function copyCode_depfun(compiledir, singleMachFunc)

try
if exist(compiledir, 'dir')
    rmdir(compiledir, 's'); 
end
mymkdir(compiledir);

%cfiles_tba = [];
[blah, blah, cfiles_tba] = myaddpath(0);
files_tbc = getFileDependencies(singleMachFunc);
for k=1:length(files_tbc)
    %copyfile([paths_tba{k} filesep '*'], compiledir);  % copyfile uses cp -rp!!
    system(['cp -rpL ' files_tbc{k} ' ' compiledir]);
end
%for k=1:length(cfiles_tba)
    %copyfile([paths_tba{k} filesep '*'], compiledir);  % copyfile uses cp -rp!!
%    system(['cp -rpL ' cfiles_tba{k} ' ' compiledir]);
%end

catch
    disp(lasterr); keyboard;
end
