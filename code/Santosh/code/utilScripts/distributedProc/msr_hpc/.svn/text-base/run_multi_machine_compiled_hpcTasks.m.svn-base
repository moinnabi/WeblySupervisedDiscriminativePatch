function run_multi_machine_compiled_hpcTasks(cmd_str, machineInfo, runMode)

cmd = cmd_str;
if strcmp(runMode, 'newCl')
    num_jobs = machineInfo.num_jobs;
    num_cpu = machineInfo.num_cpu;
    memgb = machineInfo.memgb;
    clusterName = machineInfo.clusterName;
    logdir = machineInfo.logdir;
    %logstring = machineInfo.logstring;
    %lsscript = machineInfo.lsscript;
    ID_str = machineInfo.procname;
    
    %disp(['job submit /scheduler:' clusterName ' /jobname:ls /numcores:1 dir']); keyboard;
    
    %disp(['job submit /scheduler:' clusterName ' /jobname:ls /numcores:1 dir']); keyboard;
    [sstat, jobidnum]= system(['job new /scheduler:' clusterName ' /jobname:' ID_str]);
    jobidnum = jobidnum(18:end-1);    
    for i_job = 1:num_jobs
        myprintf(i_job, 10);
        OUTPUT_FILER=[logdir filesep clusterName '_' num2str(jobidnum) '_' num2str(i_job) '.warp.output'];
        ERROR_FILER=[logdir filesep clusterName '_' num2str(jobidnum) '_' num2str(i_job) '.warp.error'];
        finalcmd = [cmd ' > ' OUTPUT_FILER];
        system(['job add ' jobidnum ' /scheduler:' clusterName ' /name:' ID_str ' /stdout:' OUTPUT_FILER ...
            ' /stderr:' ERROR_FILER ' /numcores:' num2str(num_cpu) ' '  finalcmd]);
        %pause(1);
    end        
    myprintfn;
    if num_jobs ~= 0
        system(['job submit /scheduler:' clusterName ' /id:' jobidnum]);
        disp(['Started job ' num2str(jobidnum)]);    
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
