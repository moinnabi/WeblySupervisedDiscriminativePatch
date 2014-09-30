function reserveFreeNode

multimachine_warp2('while(1), pause(10000); end;', 1, [], 1, 'reserveCPUnode', 8, 0);
myWARPprocessMonitor('reserveCPUnode')
