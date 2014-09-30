function selectedQdel(job1,jobn)

%clusterName = 'MSR-l27-SCL01';

[blah, ids] = myWARPprocessMonitor_all;
for i=1:numel(ids)
    if str2num(ids{i}) >= job1 & str2num(ids{i}) <= jobn
    %disp(['job cancel ' num2str(i) ' /scheduler:' clusterName]);
    %system(['job cancel ' num2str(i) ' /scheduler:' clusterName]);
    disp(['qdel ' ids{i}]); 
    system(['qdel ' ids{i}]);
    end
end

for i=1:numel(ids)
    fprintf('%s ', ids{i});
end

%{
fprintf('qdel ');
for i=1061441:2:1061509
    fprintf('%d ',i);
end
fprintf('\n');
%}

