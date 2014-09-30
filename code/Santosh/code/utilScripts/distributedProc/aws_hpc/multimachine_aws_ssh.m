function multimachine_aws_ssh(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME,...
    NUM_PROCS, NUM_GB, OVERWRITE, initcmdstr, exitcmdstr) 
  
SSHKEYFILEPATH = '/nfs/hn12/sdivvala/aws/sshkeyec2.pem';
%init_matlab_cmdstr1 = 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/runtime/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/bin/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/sys/os/glnxa64:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/sys/java/jre/glnxa64/jre/lib/amd64/server:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/sys/java/jre/glnxa64/jre/lib/amd64/client:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/sys/java/jre/glnxa64/jre/lib/amd64';
%init_matlab_cmdstr2 = 'export XAPPLRESDIR=$XAPPLRESDIR:/usr/local/MATLAB/MATLAB_Compiler_Runtime/v716/X11/app-defaults';
%init_matlab_cmdstr = [init_matlab_cmdstr1 ' ; ' init_matlab_cmdstr2];
init_matlab_cmdstr = '';
initcmdstr = [initcmdstr ' ;  ' init_matlab_cmdstr];

funcdelim = ' ';
compiledir = fullfile(resdir, ['code_compiled_' strtok(singleMachFunc, funcdelim)]);
if exist('OVERWRITE', 'var') && ~isempty(OVERWRITE) && OVERWRITE
    try rmdir(compiledir, 's'); end
end
if ~exist(compiledir, 'dir')
    disp('compiling code..');
    compileCode(compiledir, strtok(singleMachFunc, funcdelim));
end

% change to compiledir and add all files to path!
cmd = sprintf(['%s; cd %s; ./%s; cd ~; %s'], initcmdstr, compiledir, singleMachFunc, exitcmdstr);

if exist('NUM_MACHS', 'var') && ~isempty(NUM_MACHS), NUMJOBS = NUM_MACHS;
else NUMJOBS = 1; end
if exist('PROC_NAME', 'var') && ~isempty(PROC_NAME), PROCNAME = [strtok(singleMachFunc, funcdelim) '_' PROC_NAME];
else PROCNAME = 'MultiMatlab'; end
if exist('NUM_PROCS', 'var') && ~isempty(NUM_PROCS), NUMCPU = NUM_PROCS; NUMGB = NUM_GB;
else NUMCPU = 1; NUMGB = 0; end

machineInfo.procname = PROCNAME;
machineInfo.num_procs = NUMJOBS;
machineInfo.sshkeyfile = SSHKEYFILEPATH;
machineInfo.machines = getMachineInfo_aws;


disp('starting jobs');
run_multi_machine_aws_ssh(cmd, machineInfo, [resdir '/' strtok(singleMachFunc, ' ')]);
%disp([' check your session - ' num2str(jobidnum) ' if its running!!!']);
