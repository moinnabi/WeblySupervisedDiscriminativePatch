function retval = areAllFilesDone_pascaldet(resdir, phrasenames, suffix, boolval)

if nargin < 4
    boolval = 0;
end

numdone = getNumDone(resdir, phrasenames, suffix); 
num_ids = numel(phrasenames);

retval = 0;
if boolval    
    if numdone  < num_ids, retval = 0;
    else retval = 1; end
    return;
else
    while numdone  < num_ids
        fprintf('%s ', [num2str(numdone) '/' num2str(num_ids)]);
        pause(60);
        numdone = getNumDone(resdir, phrasenames, suffix);
        %numdone = length(mydir([resdir '/done/*.done']));
    end
    myprintfn;
end

function numdone = getNumDone(resdir, phrasenames, suffix)

numdone = 0;
for f=1:numel(phrasenames)    
    if exist([resdir '/' phrasenames{f} '/' phrasenames{f} '_' suffix '.mat'], 'file')
        numdone = numdone + 1;
    end
end
