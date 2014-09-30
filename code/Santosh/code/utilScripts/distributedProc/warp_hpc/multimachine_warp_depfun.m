function multimachine_warp_depfun(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME,...
    NUM_PROCS, NUM_GB, OVERWRITE, fexttype) 

[blah hname]=system('hostname');
if ~strcmp(hname(1:end-1), 'warp.hpc1.cs.cmu.edu')
    disp('Yo, not here dude!');
    return;
end
    
doneDirName = 'done';
init_matlab_cmdstr = '';

compiledir = fullfile(resdir, ['code_compiled_' strtok(singleMachFunc, '(')]);
if exist('OVERWRITE', 'var') & ~isempty(OVERWRITE) & OVERWRITE
    try, rmdir(compiledir, 's'); end
end

if ~exist(compiledir, 'dir')
    disp('copying code..');
    copyCode_depfun(compiledir, strtok(singleMachFunc, '('));
end

% change to compiledir and add all files to path!
cmd = sprintf(['cd %s; addpath(genpath(''.'')); %s; exit '], compiledir, singleMachFunc);

if exist('NUM_MACHS', 'var') && ~isempty(NUM_MACHS), NUMJOBS = NUM_MACHS;
else NUMJOBS = 1; end

if exist('PROC_NAME', 'var') && ~isempty(PROC_NAME), PROCNAME = [strtok(singleMachFunc, '(') '_' PROC_NAME];
else PROCNAME = 'MultiMatlab'; end

if exist('NUM_PROCS', 'var') && ~isempty(NUM_PROCS)
    NUMCPU = NUM_PROCS; NUMGB = NUM_GB;
else
    NUMCPU = 1; NUMGB = 0;
end

if 1
    logdir='/lustre/sdivvala/outputs/'; if ~exist(logdir, 'dir'), mkdir(logdir); end
    %logdir='/nfs/baikal/sdivvala/outputs/'; if ~exist(logdir, 'dir'), mkdir(logdir); end
    machineInfo.logdir = logdir;
    machineInfo.logstring = ['-e ' logdir ' -o ' logdir ' -j oe'];
    machineInfo.num_jobs = NUMJOBS;
    machineInfo.num_cpu = NUMCPU;
    machineInfo.memgb = NUMGB;    
    machineInfo.lsscript = '/lustre/sdivvala/lsscriptForWarpJoBID.txt';
    %machineInfo.lsscript = '/nfs/baikal/sdivvala/lsscriptForWarpJoBID.txt';
    runMode = 'newCl'; 
else
    machineInfo = getMachineInfo(NUMCPU);
    machineInfo.machines = {machineInfo.machines{(1:NUMJOBS)}};
    runMode = 'oldCl';
end
machineInfo.procname = PROCNAME;

num_expected_files = numClasses;
if exist('fexttype', 'var') && ~isempty(fexttype)    
    done_files = dir([resdir filesep '/*.' fexttype]);
else
    %fexttype = 'mat';
    done_files = dir([resdir filesep doneDirName '/*.done']);
end


if NUMJOBS == 1 || (length(done_files)<num_expected_files) % updated 20Aug10        
disp('starting jobs');
jobidnum = run_multi_machine_warp(cmd, machineInfo, runMode, init_matlab_cmdstr, [resdir '/' strtok(singleMachFunc, '(')]);
if ~isempty(resdir) && NUMJOBS ~= 1
    % Wait for everybody to finish
    all_done = false;
    while ~all_done
        done_files = dir([resdir filesep doneDirName '/*.done']);
        lock_files = dir([resdir filesep doneDirName '/*.lock']);
        err_files = mydir([resdir filesep doneDirName '/*.error']);
        if length(err_files) ~= 0, disp('An ERROR has occured!!!!!'); end
        fprintf('%d+%d/%d ', length(done_files), length(lock_files), num_expected_files);   % updatd 20Aug10        
        if (length(done_files)==num_expected_files)
            all_done = true;
        else
            pause(30);        
        end
    end    
    disp('saved stuff and returning');
    pause(30);
    [rmstatus, rmmessage] = rmdir([resdir filesep doneDirName], 's');   % delete it once everything was successful
    disp(rmmessage);
else
    disp([' check your session - ' num2str(jobidnum) ' if its running!!!']);
end

end
