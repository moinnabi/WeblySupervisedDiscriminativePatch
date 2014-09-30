function run_multi_machine_hpc(cmd_str, machineInfo, runMode, init_matlab_cmdstr)
%
%  Runs the string in 'cmd_str' on the machines listed in the cell array
%  machines. Each will be running within a
%  screen with the specified string 'ID_str' in the name (default is
%  'MultiMatlab').
%
% IMPORTANT:
%  Note that it is assumed that passwordless login is available when
%  ssh-ing to each of the provided machines.

% Create the call to matlab:
if exist('init_matlab_cmdstr', 'var') && ~isempty(init_matlab_cmdstr)
cmd = sprintf('%s; matlab -nodesktop -nosplash -r \"%s\"', init_matlab_cmdstr, cmd_str);
else
cmd = sprintf('matlab -nodesktop -nosplash -r \"%s\"', cmd_str);    % nice default is 10
end

if strcmp(runMode, 'newCl')
    num_jobs = machineInfo.num_jobs;
    num_cpu = machineInfo.num_cpu;
    memgb = machineInfo.memgb;
    clusterName = machineInfo.clusterName;
    logdir = machineInfo.logdir;
    %logstring = machineInfo.logstring;
    %lsscript = machineInfo.lsscript;
    ID_str = machineInfo.procname;
    
    for i_job = 1:num_jobs
        
       [blah pbsjobid] = system(['job submit /scheduler:' clusterName ' /jobname:ls /numcores:1 dir']);
        jobidnum = str2num(pbsjobid(end-3:end-1))+1;
        
        OUTPUT_FILER=[logdir '/' num2str(jobidnum) '.warp.output'];
        ERROR_FILER=[logdir '/' num2str(jobidnum) '.warp.error'];
        finalcmd = [cmd ' > ' OUTPUT_FILER];
                                                 
        system(['job submit /scheduler:' clusterName ' /jobname:' ID_str ' /stdout:' OUTPUT_FILER ' /stderr:' ERROR_FILER ...
            ' /numcores:' num2str(num_cpu) ' '  finalcmd]);
        
        pause(1);        
    end
elseif strcmp(runMode, 'oldCl')
    machines = machineInfo.machines;
    machines = cellstr(machines);       % handles case that a single string is passed in
    domain = machineInfo.domain;
    num_proc = machineInfo.num_procs;
    procname = machineInfo.procname;
    for i_machine = 1:length(machines)    
        ID_str{i_machine} = ['MultiMatlab-' machines{i_machine}];    % can replace 'MultiM' with procname        
    end

    for i_machine = 1:length(machines)
        % Create the ssh call for this machine
        ssh_cmd = sprintf(['ssh %s.%s ''%s'''], machines{i_machine}, domain, cmd);
        for i_proc = 1:num_proc
            fprintf('Starting process %d on %s\n', i_proc, machines{i_machine});
            try
                %screen_cmd = ['screen -m -d -S ' ID_str ' ' ssh_cmd];
                screen_cmd = ['screen -m -d -S ' ID_str{i_machine} ' ' ssh_cmd];
                system(screen_cmd);            % Actually do the ssh inside of a screen
            catch
                warning('Unable to start process %d on %s', i_proc, machines{i_machine});
            end
        end
    end
end
