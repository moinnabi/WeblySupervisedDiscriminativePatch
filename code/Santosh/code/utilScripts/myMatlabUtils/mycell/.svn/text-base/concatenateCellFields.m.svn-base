function s = concatenateCellFields(s,d)
% s = concatenateCellFields(s,d)
% 
% Concatenates all cell fields in s along dimension d

names = fieldnames(s);
for k = 1:numel(names)
    field = s.(names{k});
    if iscell(field)
        field = cat(d,field{:});
        s.(names{k}) = field;
    end
end