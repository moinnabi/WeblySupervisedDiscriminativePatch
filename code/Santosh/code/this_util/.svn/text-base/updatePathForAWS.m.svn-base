function [pos, neg, impos] = updatePathForAWS(pos, neg, impos)

if exist('/home/ubuntu/JPEGImages/','dir')
    for i=1:numel(pos)
        [~, thisid] = myStrtokEnd(pos(i).im,'/');
        pos(i).im = ['/home/ubuntu/JPEGImages/' thisid];
    end
    for i=1:numel(neg)
        [~, thisid] = myStrtokEnd(neg(i).im,'/');
        neg(i).im = ['/home/ubuntu/JPEGImages/' thisid];
    end
    for i=1:numel(impos)
        [~, thisid] = myStrtokEnd(impos(i).im,'/');
        impos(i).im = ['/home/ubuntu/JPEGImages/' thisid];
    end
end
