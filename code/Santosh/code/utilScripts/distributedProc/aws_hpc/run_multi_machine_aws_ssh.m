function run_multi_machine_aws_ssh(cmd_str, machineInfo, resdir_prefix)

cmd = cmd_str;

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

%{
if num_jobs == 1
    OUTPUT_FILER1=[logdir filesep num2str(jobidnum) '.warp.output'];
    OUTPUT_FILER2=[resdir_prefix '_' num2str(jobidnum) '.warp.output'];
    finalcmd = [cmd ' | tee ' OUTPUT_FILER1 ' ' OUTPUT_FILER2 ' > /dev/null'];
else
    OUTPUT_FILER=[logdir filesep num2str(jobidnum) '.warp.output'];
    finalcmd = [cmd ' > ' OUTPUT_FILER];
end
fprintf(fid, '%s\n', finalcmd);
%}
%'scpaws ~/.ssh/id_awsconnect ubuntu@%s:~/.id_awsconnect; '...
    %    'scpaws ~/.bash_profile ubuntu@%s:~/; '...
    