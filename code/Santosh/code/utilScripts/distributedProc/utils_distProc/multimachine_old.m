function multimachine(singleMachFunc, numClasses, resdir, dataFileName, pathFileName)

machineInfo.machines = { 'anim1.graphics', 'anim2.graphics', 'anim3.graphics', 'anim4.graphics', ...
    'anim5.graphics', 'anim6.graphics', 'anim7.graphics', 'anim8.graphics',...
    'anim9.graphics', 'anim10.graphics', 'anim11.graphics', 'anim12.graphics', ...
    'anim13.graphics', 'anim14.graphics', 'anim15.graphics', 'weh5336-e.intro', 'weh5336-b.intro','weh5336-s.intro', ...
    'weh5336-h.intro', 'weh5336-i.intro', 'weh5336-j.intro', 'weh5336-l.intro', 'weh5336-m.intro', ...
    'weh5336-a.intro', 'weh5336-c.intro', 'weh5336-d.intro', 'weh5336-f.intro', 'weh5336-g.intro',  ...
    'weh5336-n.intro', 'weh5336-w.intro', 'weh5336-o.intro', 'weh5336-p.intro', 'weh5336-v.intro', ...
    'weh5336-q.intro', 'weh5336-r.intro', 'weh5336-k.intro', ...
    'weh5336-u.intro', 'weh5336-x.intro', 'weh5336-y.intro', 'weh5336-t.intro', 'gs8510.sp', 'balaton.graphics',};
machineInfo.domain = 'cs.cmu.edu';

%{
%%%% WEAN
machineInfo.machines = {'weh5336-g', 'weh5336-n', 'weh5336-h', 'weh5336-i', 'weh5336-j', 'weh5336-k',...
    'weh5336-l', 'weh5336-m', ...
    'weh5336-a', 'weh5336-b',  'weh5336-d', 'weh5336-e',  'weh5336-f',...
    'weh5336-c', 'weh5336-o', 'weh5336-p', 'weh5336-q', 'weh5336-r', 'weh5336-s', ...
    'weh5336-u', 'weh5336-v', 'weh5336-w', 'weh5336-x', 'weh5336-y'};%,'weh5336-t'};
machineInfo.domain = 'intro.cs.cmu.edu';
%}
machineInfo.machines = {machineInfo.machines{1:15}};
machineInfo.pathdef = 'pathdef_graphics';
%machineInfo.nicingInfo = '+15';
machineInfo.nicingInfo = '-n15';
machineInfo.num_procs = 1;

cmd = sprintf(['cd %s; dbstop if error; dbstop if naninf; '...
    'load %s; %s; '... 
    '%s; exit'], pwd, dataFileName, pathFileName, singleMachFunc);

%disp('Commented out KINIT warning!!!!');
disp('Check machine Info!! & HOPE YOU HAVE DONE --- KINIT ----'); keyboard;

run_multi_machine(cmd, machineInfo.machines, machineInfo.domain, machineInfo.num_procs, machineInfo.nicingInfo);

% Wait for everybody to finish
num_expected_files = numClasses;
all_done = false;
while ~all_done    
    pause(10);       
    done_files = dir([resdir '/*.done']);
    lock_files = dir([resdir '/*.lock']);
    disp([num2str(length(done_files)) '/' num2str(num_expected_files) ' completed... (' num2str(length(lock_files)) ' in process..)' ]);
    if (length(done_files)==num_expected_files)
        all_done = true;
    end
end

% Get rid of all the '.done' files
disp('saved stuff and returning');

%%%%%%%%%%%%%%%%%%%%%
%%%% VMR
% machineInfo.machines = {'lewis', 'islay', 'harris', 'orkney', 'muck'};
% machineInfo.machines = {'muck'};
% machineInfo.domain = 'ius.cs.cmu.edu';
% machineInfo.nicingInfo = '-n19';
% machineInfo.pathdef = 'pathdef_lin';
% machineInfo.num_procs = 3;

%  cmd = sprintf(['cd %s; dbstop if error; '...    
%      'VOCinit; '...
%      '%s(VOCopts); exit'], pwd, singleMachFunc);
 

%% Machine Info
%%%% GRAPHICS
% machineInfo.machines = {'balaton'};
% machineInfo.domain = 'graphics.cs.cmu.edu';
% machineInfo.pathdef = 'pathdef_graphics';
% machineInfo.nicingInfo = '-n15';
% machineInfo.num_procs = 2;

