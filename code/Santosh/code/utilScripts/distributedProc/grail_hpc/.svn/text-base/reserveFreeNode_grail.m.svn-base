function reserveFreeNode_grail

%multimachine_warp2('while(1), pause(10000); end;', 1, [], 1, 'INTERACTIVE', 8, 0);
%myWARPprocessMonitor('reserveCPUnode');

filenameWithPath = which('reservenode.sh'); %/projects/grail/santosh/objectNgrams/code/utilScripts/distributedProc/grail_hpc/reservenode.sh
disp(['qsub -S /bin/sh -e /dev/null -o /dev/null -N INTERACTIVE -pe orte 24 ' filenameWithPath]);

