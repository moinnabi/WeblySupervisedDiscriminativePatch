function a=deleteEmptyCells(a)

a(cellfun(@isempty,a)) = [];

