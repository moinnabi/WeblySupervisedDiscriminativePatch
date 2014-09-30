function run_multi_machine_warpTasks(cmd_str, machineInfo, runMode, init_matlab_cmdstr)
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
cmd = sprintf('%s; /opt/matlab/amd64_f7/7.10/lib/matlab7/bin/matlab -nodesktop -nosplash -r \"%s\"', init_matlab_cmdstr, cmd_str);
else
cmd = sprintf('/opt/matlab/amd64_f7/7.10/lib/matlab7/bin/matlab -nodesktop -nosplash -r \"%s\"', cmd_str);    % nice default is 10
end

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

    tmpOutFName = tempname;
    fid = fopen(tmpOutFName, 'w');
    %fprintf(fid, '%s\n', cmd);
    %[blah pbsjobid] = system('qstat |tail -1|cut -f 1 -d " "');
    [blah pbsjobid] = system(['qsub ' logstring ' ' lsscript]);
    jobidnum = str2num(pbsjobid(1:end-22))+1;    
    %{
    for i_job = 1:num_jobs
        myprintf(i_job, 10);        
        OUTPUT_FILER=['/lustre/${USER}/outputs/' num2str(jobidnum) '_' num2str(i_job) '.warp.output'];
        finalcmd = [cmd ' > ' OUTPUT_FILER];
        fprintf(fid, '%s\n', finalcmd);        
    end    
    %}
    OUTPUT_FILER=['/lustre/${USER}/outputs/' num2str(jobidnum) '.' '$PBS_VNODENUM'];
    finalcmd = [cmd ' > ' OUTPUT_FILER];
    fprintf(fid, '%s\n', finalcmd);
    
    fclose(fid);    
    
    %numnodes = ceil((num_jobs*num_cpu)/8);    
    if memgb == 0
        disp('need to add id_str, ensure numnodes, num_cpu, logstring is correct'); keyboard;
        %[blah1 blah2] = system(['qsub -N ' ID_str ' -l nodes=' num2str(numnodes) ':ppn=' num2str(num_cpu) ' ' logstring ' ' tmpOutFName]);
        [blah1 blah2] = system(['qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_jobs) ' ' logstring ' ' tmpOutFName]);
        [blah1 blah2] = system(['qsub -N ' ID_str ' -l nodes=' num2str(ceil(num_jobs/(8/num_cpu))) ':ppn=' num2str(floor(8/num_cpu)) ' ' logstring ' ' tmpOutFName]);
        
    else
        %system(['qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_cpu) ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);        
        [blah1 blah2] = system(['qsub -N ' ID_str ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);        
    end
    delete(tmpOutFName);
    
    myprintfn;
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

