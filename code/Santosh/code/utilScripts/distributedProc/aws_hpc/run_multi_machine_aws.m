function run_multi_machine_aws(cmd_str, machineInfo, runMode)

cmd = cmd_str;
commandFileName = tempname;
fid = fopen(commandFileName, 'w');
fprintf(fid, '%s\n', cmd);
fclose(fid);

if strcmp(runMode, 'newCl')
    num_jobs = machineInfo.num_jobs;
    num_cpu = machineInfo.num_cpu;
    memgb = machineInfo.memgb;
    logdir = machineInfo.logdir;
    logstring = machineInfo.logstring;    
    ID_str = machineInfo.procname;
    masternode = machineInfo.masternode;
    keyfile = machineInfo.keyfile;
    
    for i_job = 1:num_jobs
        myprintf(i_job, 10);        
        qsubcmd = ['source /opt/sge6/default/common/settings.sh; mkdir -p ' logdir ' ; qsub -N ' ID_str ' -pe orte ' num2str(num_cpu) '  ' logstring ' ' commandFileName];                
        scpcmd = sprintf(['scp -i %s -oStrictHostKeyChecking=no %s ubuntu@%s:/tmp/'], keyfile, commandFileName, masternode);
        sshcmd = sprintf(['%s; ssh -i %s -oStrictHostKeyChecking=no ubuntu@%s ''%s'''], scpcmd, keyfile, masternode, qsubcmd);
        [blah1 blah2] = system(sshcmd);
    end
    pause(rand*5);
    delete(commandFileName);
    myprintfn;    
else    
    machines = cellstr(machineInfo.machines);       % handles case that a single string is passed in
    sshkeyfile = machineInfo.sshkeyfile;
    num_proc = machineInfo.num_procs;
    for i_machine = 1:length(machines)
        ID_str{i_machine} = ['Multi-' machines{i_machine}];    % can replace 'MultiM' with procname
    end
    
    for i_machine = 1:length(machines)
        % Create the ssh call for this machine
        ssh_cmd = sprintf(['sshaws ubuntu@%s ''%s'''], machines{i_machine}, machines{i_machine}, machines{i_machine}, cmd);
        for i_proc = 1:num_proc
            fprintf('Starting process %d on %s\n', i_proc, machines{i_machine});
            try
                screen_cmd = ['screen -m -d -S ' ID_str{i_machine} ssh_cmd];
                %system(screen_cmd);            % Actually do the ssh inside of a screen
                system(ssh_cmd);
            catch
                warning('Unable to start process %d on %s', i_proc, machines{i_machine});
            end
        end
        
    end
end
