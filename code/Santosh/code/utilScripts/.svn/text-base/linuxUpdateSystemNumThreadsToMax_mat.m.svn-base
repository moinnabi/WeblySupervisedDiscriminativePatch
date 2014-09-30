function linuxUpdateSystemNumThreadsToMax_mat

maxThreads=12*200*8;

%[c,d] = system('ulimit -a');
[~, b] = system('ulimit -Hu');
b=str2num(b);
if b < maxThreads
    disp('system max limit low'); keyboard;
end
[f,g]= system(['ulimit -u ' num2str(maxThreads)])
%[c2,d2] = system('ulimit -a');
