function reserveFreeNode_aws

filenameWithPath = which('reservenode.sh');
qsub -S /bin/sh -l cpu=24 -N INTERACTIVE -e /dev/null -o /dev/null filenameWithPath

%multimachine_grail_compiled('while(1), pause(10000); end;', 1, [], 1, 'reserveCPUnode', 8, 0);
%myWARPprocessMonitor('reserveCPUnode')
