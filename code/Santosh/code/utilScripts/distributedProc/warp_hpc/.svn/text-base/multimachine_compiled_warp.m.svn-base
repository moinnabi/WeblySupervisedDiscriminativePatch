function multimachine_compiled_warp(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME, NUM_PROCS, NUM_GB) 

compiledir = fullfile(resdir, 'code_compiled');
if ~exist(compiledir, 'dir')
    disp('compiling code..');
    compileCode(compiledir, singleMachFunc);
end

doneDirName = 'done';

init_matlab_cmdstr = '';
cmd = sprintf(['%s%s%s'], fullfile(resdir, 'code_compiled'), filesep, singleMachFunc);

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
    logdir='/lustre/sdivvala/outputs/'; if ~exist(logdir, 'dir'), mkdir(logdir); end
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
%run_multi_machine_warp(cmd, machineInfo, runMode, init_matlab_cmdstr);
run_multi_machine_compiled_warp(cmd, machineInfo, runMode);
end
   
if ~isempty(resdir)
    % Wait for everybody to finish
    all_done = false;
    while ~all_done
        pause(30);
        done_files = dir([resdir filesep doneDirName '/*.done']);
        lock_files = dir([resdir filesep doneDirName '/*.lock']);
        err_files = mydir([resdir filesep doneDirName '/*.error']);
        if length(err_files) ~= 0, disp('An ERROR has occured!!!!!'); end
        %disp([num2str(length(done_files)) '/' num2str(num_expected_files) ' completed... (' num2str(length(lock_files)) ' in process..)' ]);
        fprintf('%d+%d/%d ', length(done_files), length(lock_files), num_expected_files);   % updatd 20Aug10
        if (length(done_files)==num_expected_files)
            all_done = true;
        end
    end    
    disp('saved stuff and returning');
else
    disp(' check your session, if its running!!!');
end

