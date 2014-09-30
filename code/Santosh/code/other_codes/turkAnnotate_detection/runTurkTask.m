function runTurkTask(objname, objturkdir)

disp('check path2 value (avoid hardcoding)!!'); keyboard;
path2 = ['/projects/grail/santosh/turk/aws-mturk-clt-1.3.1/'];
setenv('MTURK_CMD_HOME', path2);
disp('$MTURK_CMD_HOME');
system('echo $MTURK_CMD_HOME');

path3 = ['/usr/lib/jvm/java-6-openjdk-amd64/'];
setenv('JAVA_HOME', path3);
disp('$JAVA_HOME');
system('echo $JAVA_HOME');
    
filenameWithPath = which('run.sh'); %'/projects/grail/santosh/objectNgrams/code/turkAnnotate_detection/run.sh'
system([filenameWithPath ...
    ' ' objname ' ' objturkdir]);
