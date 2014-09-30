function fn = mydir(imdir, addpathname)

if nargin < 2
    addpathname = 0;
end
    
fn = dir(imdir);
fn = {fn(:).name};

if addpathname % add pathname
    for i=1:numel(fn)
        fn{i} = [fileparts(imdir) '/' fn{i}];
    end
end
