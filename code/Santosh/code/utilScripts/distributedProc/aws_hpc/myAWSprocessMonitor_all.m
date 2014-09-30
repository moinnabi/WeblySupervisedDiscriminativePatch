function [hids ids] = myAWSprocessMonitor_all

numLines = 10;

[sstat res] = system(['qselect -u sdivvala']);
i = 1;
while true
    [ids{i}, res] = strtok(res);     
    ids{i} = strtok(ids{i},'.');
    
    [sstat hostres] = system(['qstat -n ' ids{i} '| tail -n 1']);
    hids{i} = strtok(hostres, '/');
    
    if isempty(res),  break;  end    
    i = i+1;
end

fid = fopen([outdir '/tempout.txt'], 'w');
c=fix(clock);
fprintf(fid, '%d:%d:%d %d:%d:%d\n', c);
for i=1:length(ids)-1   % -1 as the last seems to be an empty one?!?!
    fprintf(fid, '\n--------------\n');
    fprintf(fid, '%s%s\n', ids{i}, hids{i});  
    %system(['head -n 23 ' outdir '/' ids{i} '.warp.output | tail -n 5 >> ' outdir '/tempout.txt']);
    [sstat res] = system(['tail -n ' num2str(numLines) ' ' outdir '/' ids{i} '.warp.output']);         
    fprintf(fid, '%s\n', res);
end
fclose(fid);
