function nodeids = getNodeIds(dts, data)

if ~strcmp(class(data), 'double')
    data = double(data);
end
nodeids = zeros(size(data, 1), numel(dts));

for k = 1:numel(dts)

    dt = dts(k);
%        dt.npred = nvar;
    if 1           
        var = dt.var; cut = dt.cut; children = dt.children; catsplit = dt.catsplit;            
        nodevals = treevalc(int32(var), cut, int32(children(:, 1)), ...
                int32(children(:, 2)), catsplit(:, 1), data');                  
    else
        [tmp, nodevals] = treeval(dt, tx);             
    end        

    nodeids(:, k) = dt.node(nodevals)';
end