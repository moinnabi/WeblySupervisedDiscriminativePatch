function mymatlabpoolopen(numcpu)

if nargin<1
    numcpu = [];
end

if ~isToolBoxInstalled('Parallel Computing Toolbox')
    disp('no Parallel Computing Toolbox on this machine');
    return;
end

try matlabpool('close', 'force'); end

if exist('/home/ubuntu/JPEGImages/','dir')
    disp('setting number of workers to 8');
    % ec2 nodes have 4 cpus but 2 threads = 8 workers
    sched=findResource('scheduler','type','local');
    sched.ClusterSize=8;
end

while true
    try
        if ~isempty(numcpu), matlabpool('open', numcpu);
        else matlabpool('open'); end
        break;
    catch
        fprintf('Ugg! Something bad happened. Trying again in 10 seconds...\n');
        pause(10);
    end
end
%matlabpool('open');
