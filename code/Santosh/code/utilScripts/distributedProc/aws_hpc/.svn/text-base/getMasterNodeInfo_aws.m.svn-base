function machhostname = getMasterNodeInfo_aws(pathToEC2API, pathToJAVA, ackey, seckey)

try

[~, outres] = system('echo $PATH');
if isempty(strfind(outres, 'ec2-api-tools-1.6.4'))
    path1 = getenv('PATH');
    path1 = [path1 ':' pathToEC2API 'bin/'];
    setenv('PATH', path1);
    disp('$PATH');
    system('echo $PATH');
            
    setenv('EC2_HOME', pathToEC2API);
    disp('$EC2_HOME');
    system('echo $EC2_HOME');
    
    setenv('JAVA_HOME', pathToJAVA);
    disp('$JAVA_HOME');
    system('echo $JAVA_HOME');
        
    setenv('AWS_ACCESS_KEY', ackey);
    disp('$AWS_ACCESS_KEY');
    system('echo $AWS_ACCESS_KEY');
        
    setenv('AWS_SECRET_KEY', seckey);
    disp('$AWS_SECRET_KEY');
    system('echo $AWS_SECRET_KEY');
        
    %system('export EC2_HOME=/projects/grail/santosh/aws/ec2-api-tools-1.6.4/');
    %system('export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/');
    %system('. /projects/grail/santosh/aws/exportPaths.sh');    
end

[a instanceid] = system('ec2-describe-instances|grep master|grep alias|cut -f3');
instanceid = regexp(instanceid,'\n', 'split');
instanceid = instanceid(1:end-1);
%if numel(instanceid) > 1, disp('too many master nodes'); keyboard; end

[a machhostname] = system(['ec2-describe-instances | grep INSTANCE | grep running | grep ' instanceid{end} ' | awk {'' print $4 ''}']);
machhostname = regexp(machhostname,'\n', 'split');
machhostname = machhostname{1};

catch
    disp(lasterr); keyboard;
end
