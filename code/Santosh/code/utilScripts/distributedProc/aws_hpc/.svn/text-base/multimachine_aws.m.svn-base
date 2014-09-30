function multimachine_aws(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME,...
    NUM_PROCS, NUM_GB, OVERWRITE, initcmdstr, exitcmdstr, globalinfo) 
 
funcdelim = ' ';
compiledir = fullfile(resdir, ['code_compiled_' strtok(singleMachFunc, funcdelim)]);
if exist('OVERWRITE', 'var') && ~isempty(OVERWRITE) && OVERWRITE    
    disp('deleting old code');
    try system(['rm -rf ' compiledir]); end
end
if ~exist(compiledir, 'dir')
    disp('compiling code..');    
    compileCode(compiledir, strtok(singleMachFunc, funcdelim));    
end

mcrdirname = ['/tmp/mcrCache_' getenv('USER') '/']; % getenv('USER') = "santosh"
initmcrcmd = ['mkdir ' mcrdirname ' ; export MCR_CACHE_ROOT=' mcrdirname];
%initmcrcmd = ['mkdir /tmp/mcrCache_santosh/ ; export MCR_CACHE_ROOT=/tmp/mcrCache_santosh/'];

cmd = sprintf(['%s cd %s; %s; ./%s; cd ~; %s'], initcmdstr, compiledir, initmcrcmd, singleMachFunc, exitcmdstr);    % change to compiledir and add all files to path!

if exist('NUM_MACHS', 'var') && ~isempty(NUM_MACHS), NUMJOBS = NUM_MACHS;
else NUMJOBS = 1; end
if exist('PROC_NAME', 'var') && ~isempty(PROC_NAME), PROCNAME = [strtok(singleMachFunc, funcdelim) '_' PROC_NAME];
else PROCNAME = 'MultiMatlab'; end
if exist('NUM_PROCS', 'var') && ~isempty(NUM_PROCS), NUMCPU = NUM_PROCS; NUMGB = NUM_GB;
else NUMCPU = 1; NUMGB = 0; end

machineInfo.procname = PROCNAME;
if 1
    logdir='/home/ubuntu/outputs/';
    machineInfo.logdir = logdir;
    machineInfo.logstring = ['-e ' logdir ' -o ' logdir ' -j y'];
    machineInfo.num_jobs = NUMJOBS;
    machineInfo.num_cpu = NUMCPU;
    machineInfo.memgb = NUMGB;        
    machineInfo.masternode = globalinfo.masternode;
    runMode = 'newCl'; 
    machineInfo.keyfile = globalinfo.keyfile;
else    
    machineInfo.num_procs = NUMJOBS;
    machineInfo.sshkeyfile = SSHKEYFILEPATH;
    machineInfo.machines = getMachineInfo_aws;    
    runMode = 'oldCl';
end

disp('starting jobs');
run_multi_machine_aws(cmd, machineInfo, runMode);
