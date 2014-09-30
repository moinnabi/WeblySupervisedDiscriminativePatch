function retval = areAllFilesDone(resdir, num_ids, pauseTime, boolval)

if nargin < 3 || isempty(pauseTime)
    pauseTime = 60;
end
if nargin < 4
    boolval = 0;
end

numdone = length(mydir([resdir '/done/*.done']));

retval = 0;
if boolval
    %if numdone  < num_ids, retval = num_ids-numdone;
    %else retval = 0; end
    retval = num_ids-numdone;
    return;
else
    while numdone  < num_ids
        pause(pauseTime);
        numdone = length(mydir([resdir '/done/*.done']));
        fprintf('%s ', [num2str(numdone) '/' num2str(num_ids)]);
    end
    myprintfn;
end

%{
numdone = length(mydir([resdir '/done/*.done']));
while numdone  < numel(pos)
    pause(60);
    numdone = length(mydir([resdir '/done/*.done']));
    fprintf('%s ', [num2str(numdone) '/' num2str(numel(pos))]);
end
myprintfn;
%}
