function setupAWSforMasterScript
% author: Santosh Divvala

% this is the Main setup script for Amazon AWS EC2. All variables/values
% are fine-tuned for my setup/machine.

%%% All keys info (search your email for "amazon aws ec2 key info" to fill these details)
% keyfile = '';
% ackey = '';
% seckey = '';

pathToEC2API = '/projects/grail/santosh/aws/ec2-api-tools-1.6.4/';
pathToJAVA = '/usr/lib/jvm/java-6-openjdk-amd64/';

%run this from my linux machine
%decideSpotBiddingPrize;
%startAWScluster(125, 0.26, 'm2.4xlarge');
startAWScluster(5, 0.35, 'cc2.8xlarge');
masternode=getMasterNodeInfo_aws(pathToEC2API, pathToJAVA, ackey,seckey);
disp('login as root to monitor cluster and run the following two commands (as root)');
disp('qconf -mattr queue load_thresholds np_load_avg=300 all.q ; qconf -mp orte $fill_up'); 
sshcmd = sprintf(['ssh -i %s -oStrictHostKeyChecking=no root@%s '], keyfile, masternode); disp(sshcmd);

% login to the cluster and set it up
sshcmd = sprintf(['ssh -i %s -oStrictHostKeyChecking=no ubuntu@%s '], keyfile, masternode); disp(sshcmd);
initcommandstr = getcommandstr2();
disp(initcommandstr);                                   % sshfs drives
filenameWithPath = which('summary.sh');
disp(['ln -s ' filenameWithPath ' ~/summary_aws.sh']);  % softlink summary file
disp('mkdir ~/outputs/');                               % create output dir

%restartAWScluster(keyfile);
%stopAWScluster;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [initcommandstr, exitcommandstr] = getcommandstr2()

%logininfo = 'sdivvala@onega.graphics.cs.cmu.edu';
%initcommandstr = ['sshfs santosh@sumatra.cs.washington.edu:/m-grail30/grail30/santosh /projects/grail/santosh -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ; mkdir /projects/grail/santosh2; sshfs santosh@peets.cs.washington.edu:/m-grail76/grail76/santosh /projects/grail/santosh2 -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ;'];
%initcommandstr = ['sshfs santosh@visionfs.cs.washington.edu:/m-vision02/vision02/santosh /projects/grail/santosh -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ; mkdir /projects/grail/santosh2; sshfs santosh@visionfs.cs.washington.edu:/m-vision03/vision03/santosh /projects/grail/santosh2 -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ;'];
initcommandstr = [...
    ' mkdir /projects/grail/santosh; sshfs santosh@visionfs.cs.washington.edu:/m-vision02/vision02/santosh /projects/grail/santosh -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ; '...
    ' mkdir /projects/grail/santosh2; sshfs santosh@visionfs.cs.washington.edu:/m-vision03/vision03/santosh /projects/grail/santosh2 -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ;'...
    ' mkdir /projects/grail/santosh3; sshfs santosh@visionfs.cs.washington.edu:/m-vision04/vision04/santosh /projects/grail/santosh3 -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ;'...
    ' mkdir /projects/grail/santosh4; sshfs santosh@visionfs.cs.washington.edu:/m-vision05/vision05/santosh /projects/grail/santosh4 -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ;'...
    ' mkdir /projects/matlab2012b; sshfs santosh@coco.cs.washington.edu:/m-matlab/matlab2012b /projects/matlab2012b -o IdentityFile=/home/ubuntu/.ssh/id_sumatra ;'];
exitcommandstr = [];

