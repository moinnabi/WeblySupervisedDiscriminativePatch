function multimachine_grail(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME,...
    NUM_PROCS, NUM_GB, OVERWRITE) 
% NOTE: this script is not being used (as grail needs compiled matlab code on cluster)

doneDirName = 'done';
init_matlab_cmdstr = '';

funcdelim = '(';
logdir='/projects/grail/santosh/outputs/';

compiledir = fullfile(resdir, ['code_compiled_' strtok(singleMachFunc, funcdelim)]);
if exist('OVERWRITE', 'var') && ~isempty(OVERWRITE) && OVERWRITE    
    disp('deleting old code');
    try system(['rm -rf ' compiledir]); end
end
if ~exist(compiledir, 'dir')
    disp('copying code..');    
    copyCode_depfun(compiledir, strtok(singleMachFunc, funcdelim));
    %compileCode(compiledir, strtok(singleMachFunc, funcdelim));
end

% change to compiledir and add all files to path!
cmd = sprintf(['cd %s; addpath(genpath(''.'')); %s; exit '], compiledir, singleMachFunc);

if exist('NUM_MACHS', 'var') && ~isempty(NUM_MACHS), NUMJOBS = NUM_MACHS;
else NUMJOBS = 1; end
if exist('PROC_NAME', 'var') && ~isempty(PROC_NAME), PROCNAME = [strtok(singleMachFunc, funcdelim) '_' PROC_NAME];
else PROCNAME = 'MultiMatlab'; end
if exist('NUM_PROCS', 'var') && ~isempty(NUM_PROCS), NUMCPU = NUM_PROCS; NUMGB = NUM_GB;
else NUMCPU = 1; NUMGB = 0; end

machineInfo.procname = PROCNAME;
machineInfo.logdir = logdir;
machineInfo.logstring = ['-e ' logdir ' -o ' logdir ' -j y'];
machineInfo.num_jobs = NUMJOBS;
machineInfo.num_cpu = NUMCPU;
machineInfo.memgb = NUMGB;
machineInfo.compiled = 0;
%machineInfo.masternode = getMasterNodeInfo_aws; %'ec2-54-242-133-202.compute-1.amazonaws.com'; %;

disp('starting jobs');
run_multi_machine_grail(cmd, machineInfo);
