function count = countFiles(indir, filestr, recurse, varargin)
% [fn, fndir, fullfn] = listFiles(indir, filestr, recurse)
%
% Counts all files inside indir that match filestr.
%
% Input:
%   indir: directory to search
%   filestr: string to match (e.g., *.jpg to find all jpg files)
%   recurse: 1 if should recurse into subdirectories
% Output:
%   count: number of files that match

%% Initialize
if numel(varargin)>0
    count = varargin{1};
else
    count = 0;
end


%% List each file in current directory
files = dir(fullfile(indir, filestr));
count = count + numel(files);

%% Recursively call each subdirectory
if recurse
    files = dir(indir);
    subdirs = {files([files.isdir]).name};

    for f =1:numel(subdirs)
    
        if subdirs{f}(1)~='.' % ignore directories beginning with .
            nextdir = fullfile(indir, subdirs{f});
            count = countFiles(nextdir, filestr, recurse, count);                 
        end
    end
end