function getResultsTurkTask(objname, objturkdir)

%{
path2 = ['/projects/grail/santosh/turk/aws-mturk-clt-1.3.1/'];
setenv('MTURK_CMD_HOME', path2);
disp('$MTURK_CMD_HOME');
system('echo $MTURK_CMD_HOME');

path3 = ['/usr/lib/jvm/java-6-openjdk-amd64/'];
setenv('JAVA_HOME', path3);
disp('$JAVA_HOME');
system('echo $JAVA_HOME');
%}

filenameWithPath = which('getResults.sh');    % avoids hardcoding filepath ('/projects/grail/santosh/objectNgrams/code/turkAnnotate_detection/getResults.sh'
system([filenameWithPath ...
    ' ' objname ' ' objturkdir]);
