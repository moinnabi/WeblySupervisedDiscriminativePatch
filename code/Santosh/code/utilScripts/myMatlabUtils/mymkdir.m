function mymkdir(dirname)

if ~exist(dirname, 'dir')
    mkdir(dirname);
end