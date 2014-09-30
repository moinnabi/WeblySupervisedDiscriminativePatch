function newstr = strcat_space(cellstrs)

newstr =cellstrs{1};
for i=2:numel(cellstrs)
    newstr = [newstr ' '  cellstrs{i}];
end
