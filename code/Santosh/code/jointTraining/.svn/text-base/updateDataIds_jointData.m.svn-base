function [pos, impos, neg] = updateDataIds_jointData(pos, impos, neg)

dataid = 0;
for i = 1:length(pos)
    dataid = dataid + 1;
    pos(i).dataids = dataid;
end
for i = 1:length(impos)    
    for j=1:length(impos(i).dataids)
        dataid = dataid + 1;
        impos(i).dataids(j) = dataid;
    end
end
for i = 1:length(neg)
    dataid = dataid + 1;
    neg(i).dataid = dataid;
end
