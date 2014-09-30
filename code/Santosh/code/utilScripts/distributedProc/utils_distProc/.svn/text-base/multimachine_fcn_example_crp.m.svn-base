function [] = multimachine_fcn_example(input1,input2,save_dir)

machines = {'islay', 'orkney', 'harris', 'lewis', 'muck'};
num_procs = 3;

% Save the inputs needed by each call to a single machine
save inputs.mat input1 input2 save_dir
system('chmod ugo+rwx inputs.mat');

% Run on a set of machines
cmd = sprintf(['cd %s; dbstop if error; load inputs.mat; ' ...
    'singlemachine_fcn(input1,input2,save_dir); exit'], pwd);

run_multi_machine(cmd, machines, [], num_procs);

% Wait for everybody to finish
num_expected_files = 10;
all_done = false;
while ~all_done
    pause(10)
    error_files = dir([save_dir '/*.error']);
    if ~isempty(error_files);
        warning('There are %d error files!', length(error_files));
    end
    
    done_files = dir([save_dir '/*.done']);
    if (length(done_files)+length(error_files))==num_expected_files
        all_done = true;
    end
end

% Get rid of all the '.done' files
delete([save_dir '/*.done']);



        