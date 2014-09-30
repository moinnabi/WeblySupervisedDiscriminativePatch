function N = getNumberOfCores()

N = [];

try
fid =fopen('/proc/cpuinfo');
N=length(strfind(char(fread(fid)'), ['processor' 9]));
fclose(fid);
end

if isempty(N)
    disp('issue in getNumberOfCores'); keyboard;
end
