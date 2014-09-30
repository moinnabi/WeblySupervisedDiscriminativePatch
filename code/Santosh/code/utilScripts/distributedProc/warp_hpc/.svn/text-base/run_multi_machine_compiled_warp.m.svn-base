function run_multi_machine_compiled_warp(cmd_str, machineInfo, runMode)
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
%nicingInfo = machineInfo.nicingInfo;
%cmd = sprintf('nice /usr/local/bin/matlab -nodesktop -nosplash -r \"%s\"', cmd_str);    % nice default is 10
%cmd = sprintf('nice %s matlab -nodesktop -nosplash -r \"%s\"', nicingInfo, cmd_str);
cmd = cmd_str;

if strcmp(runMode, 'newCl')
    num_jobs = machineInfo.num_jobs;
    num_cpu = machineInfo.num_cpu;
    memgb = machineInfo.memgb;
    logstring = machineInfo.logstring;
    lsscript = machineInfo.lsscript;
    ID_str = machineInfo.procname;
    %ID_str = 'MultiMatlab';
    %cmd = sprintf('screen2 -m -d -S %s %s', ID_str, cmd);    
    %OUTPUT_FILER='/lustre/${USER}/outputs/${HOSTNAME}.$$.output';       %
    
    for i_job = 1:num_jobs
        myprintf(i_job, 10);
        tmpOutFName = tempname;
        fid = fopen(tmpOutFName, 'w');
        %fprintf(fid, '%s\n', cmd);

        %[blah pbsjobid] = system('qstat |tail -1|cut -f 1 -d " "');
        [blah pbsjobid] = system(['qsub ' logstring ' ' lsscript]);
        jobidnum = str2num(pbsjobid(1:end-22))+1;
        OUTPUT_FILER=['/lustre/${USER}/outputs/' num2str(jobidnum) '.warp.output'];
        finalcmd = [cmd ' > ' OUTPUT_FILER];
        fprintf(fid, 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/matlab7/bin/glnxa64 \n');
        fprintf(fid, 'echo $LD_LIBRARY_PATH \n');
        fprintf(fid, '%s\n', finalcmd);
        
        fclose(fid);                
        
        if memgb == 0
        [blah1 blah2] = system(['qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_cpu) ' ' logstring ' ' tmpOutFName]);
        else 
        %system(['qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_cpu) ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);
        [blah1 blah2] = system(['qsub -N ' ID_str ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);
        end 
        pause(1);
        delete(tmpOutFName);
    end
    myprintfn;
elseif strcmp(runMode, 'oldCl')
    machines = machineInfo.machines;
    machines = cellstr(machines);       % handles case that a single string is passed in
    domain = machineInfo.domain;
    num_proc = machineInfo.num_procs;
    for i_machine = 1:length(machines)        
        ID_str{i_machine} = ['MultiM-' machines{i_machine}];
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

