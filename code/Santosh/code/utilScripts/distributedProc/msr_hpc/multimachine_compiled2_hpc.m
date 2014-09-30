function multimachine_compiled2(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME, NUM_PROCS, NUM_GB) 
%singleMachFunc = 'addPath_CAOB; CAOBOpts = CAOBinit; objectDetection_CAOB(CAOBOpts);';

%disp('compiling code..');
%compileCode(fullfile(resdir, 'code_compiled'), singleMachFunc);

disp('starting jobs');
clusterName = 'MSR-L25-DEV21';
%clusterName = 'MSR-K25-NODE01';
doneDirName = 'done';

%disp('exporting LD_LIBRARY_PATH to include cvlib_mex; DISABLE THIS IF YOU DONT NEED IT!!!!');
%init_matlab_cmdstr = 'export
%LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/nfs/hn12/sdivvala/src/utilCodes/opencv_matlab_lib/:/nfs/hn12/sdivvala/src/utilCodes/OpenCV-2.0.0/release/lib/';
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
    logdir='\\msr-arrays\SCRATCH\msr-pool\REDMOND\t-sdivva\results\log_outputs\'; if ~exist(logdir, 'dir'), mkdir(logdir); end
    %machineInfo.logstring = ['-e ' logdir ' -o ' logdir ' -j oe'];
    machineInfo.logdir = logdir; 
    machineInfo.num_jobs = NUMJOBS;
    machineInfo.num_cpu = NUMCPU;
    machineInfo.memgb = NUMGB;    
    machineInfo.clusterName = clusterName;    
    %machineInfo.lsscript = '/lustre/sdivvala/lsscriptForWarpJoBID.txt';
    runMode = 'newCl'; 
else
    machineInfo = getMachineInfo(NUMCPU);
    machineInfo.machines = {machineInfo.machines{(1:NUMJOBS)}};
    runMode = 'oldCl';
end
machineInfo.procname = PROCNAME;


%run_multi_machine(cmd, machineInfo, runMode, init_matlab_cmdstr);
run_multi_machine_compiled(cmd, machineInfo, runMode);

if ~isempty(resdir)
    % Wait for everybody to finish
    num_expected_files = numClasses;
    all_done = false;
    while ~all_done
        pause(10);
        done_files = dir([resdir filesep doneDirName '/*.done']);
        lock_files = dir([resdir filesep doneDirName '/*.lock']);
        err_files = mydir([resdir filesep doneDirName '/*.error']);
        if length(err_files) ~= 0, disp('An ERROR has occured!!!!!'); end
        disp([num2str(length(done_files)) '/' num2str(num_expected_files) ' completed... (' num2str(length(lock_files)) ' in process..)' ]);
        if (length(done_files)==num_expected_files)
            all_done = true;
        end
    end    
    disp('saved stuff and returning');
else
    disp(' check your session, if its running!!!');
end


function machineInfo = getMachineInfo(NUMCPU)

WEH = 0;    % WEH machine configs seem to have changed; they no longer can see /nfs!
VMR = 0;

machineInfo.nicingInfo = '-n15';

if WEH
machineInfo.machines = { 'weh5336-e.intro', 'weh5336-b.intro','weh5336-l.intro', ...
    'weh5336-t.intro', 'weh5336-u.intro', 'weh5336-j.intro', 'weh5336-i.intro', 'weh5336-m.intro', ...
    'weh5336-a.intro', 'weh5336-c.intro', 'weh5336-y.intro', 'weh5336-f.intro', 'weh5336-g.intro',  ...
    'weh5336-n.intro', 'weh5336-k.intro', 'weh5336-o.intro', 'weh5336-p.intro', 'weh5336-v.intro', ...
    'weh5336-q.intro', 'weh5336-r.intro', 'weh5336-h.intro', ...
    'weh5336-d.intro', 'weh5336-s.intro', 'weh5336-x.intro', 'weh5336-w.intro', 'gs8510.sp', 'balaton.graphics',...
    'anim1.graphics', 'anim2.graphics', 'anim3.graphics', 'anim4.graphics', ...
    'anim5.graphics', 'anim6.graphics', 'anim7.graphics', 'anim8.graphics',...
    'anim9.graphics', 'anim10.graphics', 'anim11.graphics', 'anim12.graphics', ...
    'anim13.graphics', 'anim14.graphics', 'anim15.graphics', };
machineInfo.domain = 'cs.cmu.edu';
machineInfo.num_procs = NUMCPU;
elseif VMR
machineInfo.machines = {  'muck', 'islay', 'lewis', 'harris','orkney'};    %'harris', 
machineInfo.domain = 'ius.cs.cmu.edu';
machineInfo.num_procs = NUMCPU;
else %lustre
machineInfo.machines = { 'compute-1-1', 'compute-1-2', 'compute-1-3', 'compute-1-4', 'compute-1-5', 'compute-1-6', ...
    'compute-1-7', 'compute-1-8', 'compute-1-9', 'compute-1-10', 'compute-1-11', 'compute-1-12', ...
    'compute-1-13', 'compute-1-14', 'compute-1-15', 'compute-1-16', 'compute-1-17', 'compute-1-18',... 
    'compute-2-1', 'compute-2-2', 'compute-2-3', 'compute-2-4', 'compute-2-5', 'compute-2-6'...
    'compute-2-7', 'compute-2-8', 'compute-2-9', 'compute-2-10', 'compute-2-11', 'compute-2-12', ...
    'compute-2-13', 'compute-2-14', 'compute-2-15', 'compute-2-16', 'compute-2-17', 'compute-2-18',... 
    'compute-2-19', 'compute-2-20', 'compute-2-21', 'compute-2-22', 'compute-2-23', 'compute-2-24',... 
    'compute-2-25', 'compute-2-26', 'compute-2-27', 'compute-2-28', 'compute-2-29', 'compute-2-30',... 
    'compute-2-31', 'compute-2-32',... 
    'compute-3-1', 'compute-3-2', 'compute-3-3', 'compute-3-4', 'compute-3-5', 'compute-3-6'...
    'compute-3-7', 'compute-3-8', 'compute-3-9', 'compute-3-10', 'compute-3-11', 'compute-3-12', ...
    'compute-3-13', 'compute-3-14', 'compute-3-15', 'compute-3-16', 'compute-3-17', 'compute-3-18',... 
    'compute-3-19', 'compute-3-20', 'compute-3-21', 'compute-3-22', 'compute-3-23', 'compute-3-24',... 
    'compute-3-25', 'compute-3-26', 'compute-3-27', 'compute-3-28', 'compute-3-29', 'compute-3-30',... 
    'compute-3-31', 'compute-3-32', 'compute-3-33', 'compute-3-34', 'compute-3-35', 'compute-3-36'...
    'compute-3-37', 'compute-3-38'};
machineInfo.domain = 'local';
machineInfo.num_procs = NUMCPU;    
end

%{
%%%% WEAN
machineInfo.machines = {'weh5336-g', 'weh5336-n', 'weh5336-h', 'weh5336-i', 'weh5336-j', 'weh5336-k',...
    'weh5336-l', 'weh5336-m', ...
    'weh5336-a', 'weh5336-b',  'weh5336-d', 'weh5336-e',  'weh5336-f',...
    'weh5336-c', 'weh5336-o', 'weh5336-p', 'weh5336-q', 'weh5336-r', 'weh5336-s', ...
    'weh5336-u', 'weh5336-v', 'weh5336-w', 'weh5336-x', 'weh5336-y'};%,'weh5336-t'};
machineInfo.domain = 'intro.cs.cmu.edu';
%machineInfo.machines = {machineInfo.machines{1:15}};
%machineInfo.pathdef = 'pathdef_graphics';
%machineInfo.nicingInfo = '+15';
%}

%{
%cmd = sprintf(['cd %s; try, %s; catch, '...
%    'system(''touch ' [resdir doneDirName '/file.error'] ''')'   '; disp(lasterr); disp(''error'') ; keyboard; end; exit'], pwd, singleMachFunc);
%cmd = sprintf(['cd %s; dbstop if error; dbstop if naninf; '...
%    '%s; exit'], pwd, singleMachFunc);
%}
