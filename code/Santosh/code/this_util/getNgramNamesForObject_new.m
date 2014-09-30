function [ngramnames, ngramnames_display] = getNgramNamesForObject_new(objname, inpfname)
   
[~, ngramnames] = system(['cat ' inpfname]);
ngramnames = regexp(ngramnames, '\n', 'split');
ngramnames(cellfun('isempty', ngramnames)) = [];

for f=1:numel(ngramnames)
    ngramnames{f} = strrep(ngramnames{f}, ' ', '_');
end
 
numcls = numel(ngramnames);
ngramnames_display = cell(numcls, 1);
for i=1:numcls
    ngramnames_display{i} = strrep(ngramnames{i}, ['_' objname], '');
end

