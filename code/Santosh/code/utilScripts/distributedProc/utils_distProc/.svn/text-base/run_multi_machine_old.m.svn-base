function run_multi_machine(cmd_str, machines, domain, num_proc, nicingInfo, ID_str)
%
% run_multi_machine(cmd, machines, <domain>, <num_proc>)
%
%  Runs the string in 'cmd_str' on the machines listed in the cell array
%  machines.  'domain' defaults to 'ius.cs.cmu.edu' if unspecified.
%  'num_proc' processes will be started on each machine (default is 3).
%  All processes will be niced at +19.  Each will be running within a
%  screen with the specified string 'ID_str' in the name (default is
%  'MultiMatlab').
%  
% IMPORTANT:
%  Note that it is assumed that passwordless login is available when 
%  ssh-ing to each of the provided machines.
%

disp('Hope you have done KINIT!! If so, press return...'); %pause(10);
if nargin<4 || isempty(num_proc)
    num_proc = 3;
end

if nargin<3 || isempty(domain)
    domain = 'ius.cs.cmu.edu';
end

machines = cellstr(machines);  % handles case that a single string is passed in

if nargin<6 || isempty(ID_str) || ~ischar(ID_str)
    for i_machine = 1:length(machines)
        %ID_str = 'MultiMatlab';
        ID_str{i_machine} = ['MultiM-' machines{i_machine}];
    end
end

% Create the call to matlab:
cmd = sprintf('nice %s matlab -nodesktop -nosplash -r \"%s\"', nicingInfo, cmd_str);

for i_machine = 1:length(machines)
   
    % Create the ssh call for this machine
    ssh_cmd = sprintf(['ssh %s.%s ''%s'''], machines{i_machine}, domain, cmd);
    
    for i_proc = 1:num_proc
        fprintf('Starting process %d on %s\n', i_proc, machines{i_machine});        
        try
            % Actually do the ssh inside of a screen           
            screen_cmd = ['screen -m -d -S ' ID_str{i_machine} ' ' ssh_cmd];
            system(screen_cmd);            
            %system(['screen -m -d -S ' ID_str ssh_cmd]);
            
        catch
            warning('Unable to start process %d on %s', i_proc, machines{i_machine});
        end
    end
end

return;
