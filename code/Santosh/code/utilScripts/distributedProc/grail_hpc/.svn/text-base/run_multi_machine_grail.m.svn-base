function run_multi_machine_grail(cmd_str, machineInfo)

num_jobs = machineInfo.num_jobs;
num_cpu = machineInfo.num_cpu;
memgb = machineInfo.memgb;
logdir = machineInfo.logdir;
logstring = machineInfo.logstring;
ID_str = machineInfo.procname;
VERBOSE = machineInfo.VERBOSE;
qname = machineInfo.qname;
pe = [' -pe orte ' num2str(num_cpu) ' '];   %orte, ompi

if machineInfo.compiled
    cmd = cmd_str;
else
    cmd = sprintf('/projects/matlab/bin/matlab -nodesktop -nosplash -r \"%s\"', cmd_str);
end

commandFileName = [logdir '/' tempname]; mymkdir([logdir '/tmp/']);
fid = fopen(commandFileName, 'w');
fprintf(fid, '%s\n', cmd);    
fclose(fid);

[a b] = system('source /usr/share/gridengine/grail/common/settings.sh');    % frame:  ./usr/share/gridengine/grail/common/settings.sh
[a b] = system('source /usr/share/gridengine/mframe/common/settings.sh');   % mframe:  ./usr/share/gridengine/mframe/common/settings.sh
[a b] = system('source /opt/sge6/default/common/settings.sh');              % for aws

for i_job = 1:num_jobs
    if ~isempty(qname)        
        qsubcmd = ['qsub -S /bin/sh -N ' ID_str '  ' ' -q ' qname ' ' pe logstring ' ' commandFileName];
    else
        qsubcmd = ['qsub -S /bin/sh -N ' ID_str ' ' pe logstring ' ' commandFileName];
    end
    
    [blah1 blah2] = system(qsubcmd);
    if VERBOSE == 1 
        fprintf('%s ', blah2);
    elseif VERBOSE == 0
        myprintf(i_job);
    end
end
myprintfn;


%{
%pe = [' -pe ompi ' num2str(num_cpu) ' '];  
%pe = [' -l s_core=' num2str(num_cpu) ' '];  
% qconf -spl: list of pe

    %sshcmd = ['ssh frame ''' qsubcmd ''''];    
    %[blah1 blah2] = system(sshcmd);       

%}
