function multimachine_grail_compiled(singleMachFunc, numClasses, resdir, NUM_MACHS, PROC_NAME,...
    Q_NAME, NUM_PROCS, NUM_GB, OVERWRITE, VERBOSE) 
  
funcdelim = ' ';
expcmd = ['export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/projects/grail/matlab2011b/sys/os/glnxa64:/projects/grail/matlab2011b/bin/glnxa64:/projects/grail/matlab2011b/extern/lib/glnxa64:/projects/grail/matlab2011b/runtime/glnxa64:/projects/grail/matlab2011b/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/projects/grail/matlab2011b/sys/java/jre/glnxa64/jre/lib/amd64/server:/projects/grail/matlab2011b/sys/java/jre/glnxa64/jre/lib/amd64'];
% this is needed here as qsub does not load bash_profile contents

compiledir = fullfile(resdir, ['code_compiled_' strtok(singleMachFunc, funcdelim)]);
if exist('OVERWRITE', 'var') && ~isempty(OVERWRITE) && OVERWRITE    
    disp('deleting old code');
    try system(['rm -rf ' compiledir]); end
end
if ~exist(compiledir, 'dir')
    disp('compiling code..');    
    compileCode(compiledir, strtok(singleMachFunc, funcdelim));         %was earlier copyCode_depfun(compiledir, strtok(singleMachFunc, funcdelim));
end

logdir = ['/projects/grail/' getenv('USER') '/outputs/'];

mcrtdir = tempname;
mcrtpardirname = ['/tmp/mcrCache_' getenv('USER') '/'];
initmcrcmd = ['mkdir ' mcrtpardirname ' ; '...
    'mkdir ' mcrtpardirname  mcrtdir(6:end) '/ ; '...
    'export MCR_CACHE_ROOT=' mcrtpardirname mcrtdir(6:end) '/'];
exitmcrcmd = ['rm -rf  ' mcrtpardirname  mcrtdir(6:end) '/'];

cmd = sprintf(['cd %s; %s; ./%s; %s; exit '], compiledir, initmcrcmd, singleMachFunc, exitmcrcmd);  
cmd = [expcmd ' ; ' cmd];

if exist('NUM_MACHS', 'var') && ~isempty(NUM_MACHS), NUMJOBS = NUM_MACHS;
else NUMJOBS = 1; end
if exist('PROC_NAME', 'var') && ~isempty(PROC_NAME), PROCNAME = [strtok(singleMachFunc, funcdelim) '_' PROC_NAME];
else PROCNAME = 'MultiMatlab'; end
if exist('Q_NAME', 'var') && ~isempty(Q_NAME), QNAME = Q_NAME;
else QNAME = ''; end
if exist('NUM_PROCS', 'var') && ~isempty(NUM_PROCS), NUMCPU = NUM_PROCS; NUMGB = NUM_GB;
else NUMCPU = 1; NUMGB = 0; end
if exist('VERBOSE', 'var') && ~isempty(VERBOSE), VERBOSE = VERBOSE;
else VERBOSE = 1; end

machineInfo.procname = PROCNAME;
machineInfo.qname = QNAME;
machineInfo.logdir = logdir;
machineInfo.logstring = ['-e ' logdir ' -o ' logdir ' -j y'];
machineInfo.num_jobs = NUMJOBS;
machineInfo.num_cpu = NUMCPU;
machineInfo.memgb = NUMGB;
machineInfo.VERBOSE = VERBOSE;
machineInfo.compiled = 1;

disp('starting jobs');
run_multi_machine_grail(cmd, machineInfo);

%{
%expcmd = ['export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/projects/matlab/sys/os/glnxa64:/projects/matlab/bin/glnxa64:/projects/matlab/extern/lib/glnxa64:/projects/matlab/runtime/glnxa64:/projects/matlab/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/projects/matlab/sys/java/jre/glnxa64/jre/lib/amd64/server:/projects/matlab/sys/java/jre/glnxa64/jre/lib/amd64'];
%expcmd = ['export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/projects/matlab2011b/sys/os/glnxa64:/projects/matlab2011b/bin/glnxa64:/projects/matlab2011b/extern/lib/glnxa64:/projects/matlab2011b/runtime/glnxa64:/projects/matlab2011b/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/projects/matlab2011b/sys/java/jre/glnxa64/jre/lib/amd64/server:/projects/matlab2011b/sys/java/jre/glnxa64/jre/lib/amd64'];
%}