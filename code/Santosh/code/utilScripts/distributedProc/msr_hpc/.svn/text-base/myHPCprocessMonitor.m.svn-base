function myHPCprocessMonitor(headnode)

try
%outdir = '~/lustre/outputs/';
outdir ='\\msr-arrays\SCRATCH\msr-pool\REDMOND\t-sdivva\results\log_outputs\'; 
tailcmd = 'C:\project\code\utilScripts\distributedProc\tail.exe';
%if ~exist('procname', 'var'), procname = 'MultiMatlab';end

%[sstat res] = system(['qselect -u sdivvala -N ' procname]);
[sstat res] = system(['job list /scheduler:' headnode '>' outdir 'tmpout1.txt']); 
[ids blah blah blah blah] = textread([outdir 'tmpout1.txt'], '%s %s %s %s %s');
ids = ids(3:end-1);

hids = ids;
for i=1:length(ids)        
    [sstat, info] = system(['job view ' ids{i} ' /scheduler:' headnode]);
    ind = strfind(info, 'MSR');
    if ~isempty(ind)
        hids{i} = info(ind+(0:12));    
    else
        hids{i} = 'check status';
    end
end

fid = fopen([outdir '/tempout.txt'], 'w');
c=fix(clock);
fprintf(fid, '%d:%d:%d %d:%d:%d\n', c);
for i=1:length(ids)
    fprintf(fid, '\n--------------\n');
    fprintf(fid, '%s%s\n', ids{i}, hids{i});  
    %system(['head -n 23 ' outdir '/' ids{i} '.warp.output | tail -n 5 >> ' outdir '/tempout.txt']);
    %res = textread([outdir headnode '_' ids{i} '.warp.output']);
    %res = importdata([outdir headnode '_' ids{i} '.warp.output']);
    res = readline([outdir headnode '_' ids{i} '.warp.output'], [10 -1]);
    fprintf(fid, '%s\n', cat(1,res.textdata));
end
fclose(fid);

catch
    disp(lasterr); keyboard;
end
