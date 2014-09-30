function compileCode_v2_depfun(func, OVERWRITE, varargin)

try
    
if nargin < 2, OVERWRITE = 0; end
if OVERWRITE == 0, return; end

[files_tba, blah, cfiles_tba, precompdir] = myaddpath(0);
files_tbc = getFileDependencies(func);
%6Dec13: include all .sh,.py fiiles that are not found by depfun command
for i=1:length(varargin)
    files_tbc = [files_tbc; which(varargin{i})];
end

thisprecompdir = [precompdir '/code_' func '/'];

if exist(thisprecompdir, 'dir')
    % if the directory already exists, check if the code in the directory is fresh or not
    for i=1:numel(files_tbc)
        [~,fname,fext] = fileparts(files_tbc{i});
        [statuss, reslts] = system(['diff ' files_tbc{i} ' ' [thisprecompdir '/' fname fext]]);
        if statuss ~= 0, break; end     % found a change, so stop
    end
    if statuss ~= 0, 
        disp('files have changed, deleting old files and recompiling');
        rmdir(thisprecompdir, 's'); 
    else
        disp('files are similar, not recompiling');
        return;
    end
end
mymkdir(thisprecompdir);

disp(' copying files');
for k=1:length(files_tbc)
    system(['cp -rpL ' [files_tbc{k}] ' ' thisprecompdir]);
end

% 6Dec13: added code to attach .py,.sh files; however this does not seem to
% work for some reason (may be attach only works for .m files?); found no
% other solution but to manually copy .py,.sh files to the compile
% directory in results folder
disp(' compiling');
disp(' ** DID YOU INCLUDE ALL .PY,.SH,.CC, ETC FILES?!?! ** ');
currdir = cd(thisprecompdir);
if isempty(varargin)
    mcc('-m', func);
elseif length(varargin) == 1    
    mcc('-m', func, '-a', varargin{1});
elseif length(varargin) == 2    
    mcc('-m', func, '-a', varargin{1}, '-a', varargin{2});
elseif length(varargin) == 3    
    mcc('-m', func, '-a', varargin{1}, '-a', varargin{2}, '-a', varargin{3});
elseif length(varargin) > 3
    disp('more arguments found, some problem in compiling'); keyboard; 
end
cd(currdir);

disp('tarring');
[a b]=system(['tar -cvzf ' thisprecompdir '/../code_' func '.tgz'  ' ' thisprecompdir]);
  
catch
    disp(lasterr); keyboard;
end

%{
if nargin < 2, OVERWRITE = 0; end
if OVERWRITE == 0, return; end

[files_tba, blah, cfiles_tba, precompdir] = myaddpath(0);
files_tbc = getFileDependencies(func);

thisprecompdir = [precompdir '/code_' func '/'];

disp(' deleting old files');
if exist(thisprecompdir, 'dir')
    rmdir(thisprecompdir, 's'); 
end
mymkdir(thisprecompdir);

disp(' copying files');
for k=1:length(files_tbc)
    system(['cp -rpL ' [files_tbc{k}] ' ' thisprecompdir]);
end

disp(' compiling');
currdir = cd(thisprecompdir);
mcc('-m', func);
cd(currdir);

disp('tarring');
[a b]=system(['tar -cvzf ' thisprecompdir '/../code_' func '.tgz'  ' ' thisprecompdir]);
%}
