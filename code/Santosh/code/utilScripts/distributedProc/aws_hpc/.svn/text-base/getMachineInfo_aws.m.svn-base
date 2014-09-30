function machhostnames = getMachineInfo_aws()

[a machhostnames] = system('ec2-describe-instances | grep INSTANCE | grep running | awk {'' print $4 ''}');
machhostnames = regexp(machhostnames,'\n', 'split');
machhostnames = machhostnames(1:end-1);
