function multimachine_warp2(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME,...
    NUM_PROCS, NUM_GB) 

% this version does not copy/compile code -- use it for cases such as
% reserveFreeNode

[blah hname]=system('hostname');
if ~strcmp(hname(1:end-1), 'warp.hpc1.cs.cmu.edu')
    disp('Yo, not here dude!');
    return;
end
    
doneDirName = 'done';
%disp('exporting LD_LIBRARY_PATH to include cvlib_mex; DISABLE THIS IF YOU DONT NEED IT!!!!');
%init_matlab_cmdstr = 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/nfs/hn12/sdivvala/src/utilCodes/opencv/opencv_matlab_lib/:/nfs/hn12/sdivvala/src/utilCodes/opencv/OpenCV-2.0.0/release/lib/';
init_matlab_cmdstr = '';

%{
compiledir = fullfile(resdir, ['code_compiled_' strtok(singleMachFunc, '(')]);
if ~exist(compiledir, 'dir')
    disp('copying code..');
    copyCode(compiledir);
end
%}

% change to compiledir and add all files to path!
cmd = sprintf(['%s; exit '], singleMachFunc);

if exist('NUM_MACHS', 'var') && ~isempty(NUM_MACHS), NUMJOBS = NUM_MACHS;
else NUMJOBS = 1; end

if exist('PROC_NAME', 'var') && ~isempty(PROC_NAME), PROCNAME = PROC_NAME;
else PROCNAME = 'MultiMatlab'; end

if exist('NUM_PROCS', 'var') && ~isempty(NUM_PROCS)
    NUMCPU = NUM_PROCS; NUMGB = NUM_GB;
else
    NUMCPU = 1; NUMGB = 0;
end

if 1
    %logdir='/lustre/sdivvala/outputs/'; if ~exist(logdir, 'dir'), mkdir(logdir); end
    logdir='/nfs/baikal/sdivvala/outputs/'; if ~exist(logdir, 'dir'), mkdir(logdir); end
    machineInfo.logdir = logdir;
    machineInfo.logstring = ['-e ' logdir ' -o ' logdir ' -j oe'];
    machineInfo.num_jobs = NUMJOBS;
    machineInfo.num_cpu = NUMCPU;
    machineInfo.memgb = NUMGB;    
    machineInfo.lsscript = '/lustre/sdivvala/lsscriptForWarpJoBID.txt';
    runMode = 'newCl'; 
else
    machineInfo = getMachineInfo(NUMCPU);
    machineInfo.machines = {machineInfo.machines{(1:NUMJOBS)}};
    runMode = 'oldCl';
end
machineInfo.procname = PROCNAME;


num_expected_files = numClasses;
done_files = dir([resdir filesep doneDirName '/*.done']);
if (length(done_files)~=num_expected_files) % updated 20Aug10
disp('starting jobs');
%run_multi_machine_warp(cmd, machineInfo, runMode, init_matlab_cmdstr, 'interactive');
jobidnum = run_multi_machine_warp(cmd, machineInfo, runMode, init_matlab_cmdstr, 'interactive');
%run_multi_machine_warpTasks(cmd, machineInfo, runMode, init_matlab_cmdstr);
end

if ~isempty(resdir) & NUMJOBS ~= 1
    % Wait for everybody to finish
    all_done = false;
    while ~all_done
        done_files = dir([resdir filesep doneDirName '/*.done']);
        lock_files = dir([resdir filesep doneDirName '/*.lock']);
        err_files = mydir([resdir filesep doneDirName '/*.error']);
        if length(err_files) ~= 0, disp('An ERROR has occured!!!!!'); end
        %disp([num2str(length(done_files)) '/' num2str(num_expected_files) ' completed... (' num2str(length(lock_files)) ' in process..)' ]);
        fprintf('%d+%d/%d ', length(done_files), length(lock_files), num_expected_files);   % updatd 20Aug10
        if (length(done_files)==num_expected_files)
            all_done = true;
        else
            pause(30);        
        end
    end    
    disp('saved stuff and returning');
else
    disp(' check your session, if its running!!!');
end
