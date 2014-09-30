function restartAWScluster(keyfile)

%%% search your email for "amazon aws ec2 key info"
% keyfile = '';

system(['starcluster restart myWarp2Cluster']);
masternode = getMasterNodeInfo_aws;
sshcmd = sprintf(['ssh -i ' keyfile ' -oStrictHostKeyChecking=no root@%s ''%s'''], masternode);
disp(sshcmd);
disp('run the following two commands as root');
disp('qconf -mattr queue load_thresholds np_load_avg=10 all.q ; qconf -mp orte $fill_up');
