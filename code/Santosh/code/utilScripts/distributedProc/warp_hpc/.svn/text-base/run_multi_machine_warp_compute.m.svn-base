function jobidnum = run_multi_machine_warp_compute(cmd_str, machineInfo, runMode, init_matlab_cmdstr, resdir_prefix)
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
cmd = sprintf('%s; /opt/matlab/7.13/bin/matlab -nodesktop -nosplash -r \"%s\"', init_matlab_cmdstr, cmd_str);
%/opt/matlab/amd64_f7/7.10/lib/matlab7/bin/matlab
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
    %cmd = sprintf('screen2 -m -d -S %s %s', ID_str, cmd);    
    %OUTPUT_FILER='/lustre/${USER}/outputs/${HOSTNAME}.$$.output';       %

    for i_job = 1:num_jobs
        myprintf(i_job, 10);
        % NOTE: this has to be on baikal so that it is globall accessible
        tmpOutFName = ['/nfs/baikal/sdivvala/TEMP_FOR_WARP' tempname]; 
        %tmpOutFName = ['/nfs/hn38/users/sdivvala/TEMP_FOR_WARP' tempname];  % moved to hn38 as baikal is ful
        %tmpOutFName = tempname; 
        fid = fopen(tmpOutFName, 'w');
        %fprintf(fid, '%s\n', cmd);

        %[blah pbsjobid] = system('qstat |tail -1|cut -f 1 -d " "');
        
        % 16Sep11: changed from -Y to -X as -Y was giving error "Warning:
        % No xauth data; using fake authentication data for X11 forwarding."                
        
        %11Oct11: why do you need -Y or -X in the first place? you don't
        %seem to be using that below when you are starting the actual
        %process? why for the ls script?
        
        %{
        [blah pbsjobid] = system(['ssh -Y warp ' '''' '/opt/torque/bin/qsub ' logstring ' ' lsscript '''']);        
        pbsjobid = regexp(pbsjobid,'\n', 'split');
        pbsjobid = pbsjobid{end-1}; % -1 as last line is empty line
        jobidnum = str2num(pbsjobid(1:strfind(pbsjobid,'warp')-2))+1;
        if isempty(jobidnum)
            disp(system('hostname'));
            disp(['failed with pbsjobid as ' pbsjobid]);
        [blah pbsjobid] = system(['ssh -X warp ' '''' '/opt/torque/bin/qsub ' logstring ' ' lsscript '''']);        
        jobidnum = str2num(pbsjobid(1:strfind(pbsjobid,'warp')-2))+1;
        if isempty(jobidnum), disp('why is jobidnum empty?'); disp(['-X failed with pbsjobid as ' pbsjobid]); keyboard; end            
        end
        %}
        
        [blah pbsjobid] = system(['ssh warp ' '''' '/opt/torque/bin/qsub ' logstring ' ' lsscript '''']);        
        pbsjobid = regexp(pbsjobid,'\n', 'split');
        pbsjobid = pbsjobid{end-1}; % -1 as last line is empty line
        jobidnum = str2num(pbsjobid(1:strfind(pbsjobid,'warp')-2))+1;
        while isempty(jobidnum)
            disp(system('hostname'));
            disp(['failed with pbsjobid as ' pbsjobid]);            
            disp('tring again'); pause(rand*10);
            
            [blah pbsjobid] = system(['ssh warp ' '''' '/opt/torque/bin/qsub ' logstring ' ' lsscript '''']);
            pbsjobid = regexp(pbsjobid,'\n', 'split');
            pbsjobid = pbsjobid{end-1}; % -1 as last line is empty line            
            jobidnum = str2num(pbsjobid(1:strfind(pbsjobid,'warp')-2))+1;
            %if isempty(jobidnum), disp(['failed again with pbsjobid as ' pbsjobid]); end
        end
        
        %OUTPUT_FILER=['/lustre/${USER}/outputs/' num2str(jobidnum) '.warp.output'];
        %OUTPUT_FILER=[logdir filesep num2str(jobidnum) '.warp.output'];
        %finalcmd = [cmd ' > ' OUTPUT_FILER];
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
                
        if memgb == 0        
            cmdToExecute = ['/opt/torque/bin/qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_cpu) ' ' logstring ' ' tmpOutFName];
            [blah1 blah2] = system(['ssh warp ' '''' cmdToExecute '''']);
        else
            disp('nope, code missng here'); keyboard;
            %system(['qsub -N ' ID_str ' -l nodes=1:ppn=' num2str(num_cpu) ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);
            [blah1 blah2] = system(['/opt/torque/bin/qsub -N ' ID_str ' -l mem=' num2str(memgb) 'gb ' logstring ' ' tmpOutFName]);
        end
        pause(1);
        delete(tmpOutFName);
    end
    myprintfn;
end
