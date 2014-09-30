function [fn, fndir, fullfn, count] = listFiles(indir, filestr, recurse, varargin)
% [fn, fndir, fullfn] = listFiles(indir, filestr, recurse)
%
% Lists the names and directories of all files indir that match filestr.
%
% Input:
%   indir: directory to search
%   filestr: string to match (e.g., *.jpg to find all jpg files)
%   recurse: 1 if should recurse into subdirectories
% Output:
%   fn{nfiles}: cell array of each file name
%   fndir{nfiles}: cell array of each directory
%   fullfn{nfiles}: cell array of full filenames

%% Initialize
if numel(varargin)>0
    count = varargin{1};
    fn = varargin{2};
    fndir = varargin{3};
    fullfn = {};
else
    count = countFiles(indir, filestr, recurse); 
    fn = cell(1, count);
    fndir = cell(1, count);
    count = 0;
end


%% List each file in current directory
files = dir(fullfile(indir, filestr));
nf = numel(files);
fn(count+1:count+nf) = {files.name};
fndir(count+1:count+nf) = {indir}; 
count = count + nf;

%% Recursively call each subdirectory
if recurse
    files = dir(indir);
    subdirs = {files([files.isdir]).name};

    for f =1:numel(subdirs)    
        if subdirs{f}(1)~='.' % ignore directories beginning with .
            nextdir = fullfile(indir, subdirs{f});
            [fn, fndir, fullfn, count] = listFiles(nextdir, filestr, recurse, count, fn, fndir);                
        end
    end
end

if nargout>2 && count == numel(fn)
    fullfn = cell(size(fn));
    for k = 1:numel(fullfn)
        fullfn{k} = fullfile(fndir{k}, fn{k});
    end
end
