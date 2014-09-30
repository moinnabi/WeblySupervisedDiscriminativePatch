function showqstatus

disp('my bash_profile qu does the job for you; this is no longer being used'); keyboard;


[sstat res] = system(['qstat|cut -c44-55|uniq -u']);
minJobs = 2;

while ~isempty(res)
    [id, res] = strtok(res);   % get next user
    id = strtok(id);  % get rid of white space
    
    [sstat res2] = system(['qstat|grep ' id '|wc -l']);
    res2 = str2num(strtok(res2));
    %if res2 > minJobs
        fprintf('%s\t%d\n', id, res2);          
    %end
end
fprintf('\n');
