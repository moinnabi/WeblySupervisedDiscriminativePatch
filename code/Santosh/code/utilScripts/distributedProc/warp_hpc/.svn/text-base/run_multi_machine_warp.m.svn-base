function jobidnum = run_multi_machine_warp(cmd_str, machineInfo, runMode, init_matlab_cmdstr, resdir_prefix)
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
% (9sep10) removing nice as I don't it while running on warp and other
% users dont seem to use it
if exist('init_matlab_cmdstr', 'var') && ~isempty(init_matlab_cmdstr)
%cmd = sprintf('%s; nice /usr/local/bin/matlab -nodesktop -nosplash -r \"%s\"', init_matlab_cmdstr, cmd_str);
%/opt/matlab/amd64_f7/7.10/lib/matlab7/bin/matlab
cmd = sprintf('%s;/opt/matlab/7.13/bin/matlab  -nodesktop -nosplash -r \"%s\"', init_matlab_cmdstr, cmd_str);
%/usr/local/bin/matlab
else
%cmd = sprintf('nice /usr/local/bin/matlab -nodesktop -nosplash -r \"%s\"', cmd_str);    % nice default is 10
cmd = sprintf('/opt/matlab/7.13/bin/matlab -nodesktop -nosplash -r \"%s\"', cmd_str);    
%/opt/matlab/amd64_f7/7.10/lib/matlab7/bin/matlab 
end


if strcmp(runMode, 'newCl')
    num_jobs = machineInfo.num_jobs;
    num_cpu = machineInfo.num_cpu;
    memgb = machineInfo.memgb;
    logdir = machineInfo.logdir;
    logstring = machineInfo.logstring;
    lsscript = machineInfo.lsscript;
    ID_str = machineInfo.procname;
    %ID_str = 'MultiMatlab';
    %OUTPUT_FILER='/lustre/${USER}/outputs/${HOSTNAME}.$$.output';       %

    %{
    if num_jobs == 1 & num_cpu > 1
        cmd = sprintf('screen2 -m -d -S %s %s', ID_str, cmd);
        %1. screen2 bcoz the compute nodes don't have screen command installed
        %2. Have an option to do a screen only when doing long job stuff
        % (I probably commented it out as it was creating way too many screens
        %when I do object detection testing kind of stuff)
    end
    %}

    for i_job = 1:num_jobs
        myprintf(i_job, 10);
        tmpOutFName = tempname;
        fid = fopen(tmpOutFName, 'w');
        %fprintf(fid, '%s\n', cmd);

        %disp('here'); keyboard;
        %[blah pbsjobid] = system('qstat |tail -1|cut -f 1 -d " "');
        %pause(1);
        [blah pbsjobid] = system(['qsub ' logstring ' ' lsscript]);
        %jobidnum = str2num(pbsjobid(1:strfind(pbsjobid,'warp')-2))+1;        
        %if isempty(jobidnum), disp('why is jobidnum empty?'); keyboard; end
        pbsjobid = regexp(pbsjobid,'\n', 'split');
        pbsjobid = pbsjobid{end-1}; % -1 as last line is empty line
        jobidnum = str2num(pbsjobid(1:strfind(pbsjobid,'warp')-2))+1;
        while isempty(jobidnum)
            disp(system('hostname'));
            disp(['failed with pbsjobid as ' pbsjobid]);            
            disp('tring again'); pause(rand*10);
            
            [blah pbsjobid] = system(['qsub ' logstring ' ' lsscript]);
            pbsjobid = regexp(pbsjobid,'\n', 'split');
            pbsjobid = pbsjobid{end-1}; % -1 as last line is empty line            
            jobidnum = str2num(pbsjobid(1:strfind(pbsjobid,'warp')-2))+1;
        end
        
        if num_jobs == 1
            OUTPUT_FILER1=[logdir filesep num2str(jobidnum) '.warp.output'];
            OUTPUT_FILER2=[resdir_prefix '_' num2str(jobidnum) '.warp.output'];
            finalcmd = [cmd ' | tee ' OUTPUT_FILER1 ' ' OUTPUT_FILER2 ' > /dev/null'];            
        else
            OUTPUT_FILER=[logdir filesep num2str(jobidnum) '.warp.output'];
            finalcmd = [cmd ' > ' OUTPUT_FILER];            
        end        
        fprintf(fid, '%s\n', finalcmd);
        
        fclose(fid);        
        
%         % dump cmd into *.warp.output file for reference
%         fid2 = fopen(OUTPUT_FILER, 'w');
%         fprintf(fid2, '%s', cmd);
%         fclose(fid2);%                 
        
        if memgb == 0                   
        [blah1 blah2] = system(['qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_cpu) ' ' logstring ' ' tmpOutFName]);
        else 
        %system(['qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_cpu) ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);
        [blah1 blah2] = system(['qsub -N ' ID_str ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);
        end 
        pause(rand*5);
        delete(tmpOutFName);
    end
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

