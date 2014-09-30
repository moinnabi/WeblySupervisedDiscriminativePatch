function D = ps2D(ps)
% convert Santosh's format to Label Me format
clear D;
    for i = 1:length(ps)
       D(i).annotation.filename = ps{i}.I(end-15:end);
       D(i).annotation.folder = 'VOC9990';

       D(i).annotation.object.polygon.pt = bbox2poly(uint16(ps{i}.bbox));
       D(i).annotation.object.name = ps{i}.cls;
       D(i).annotation.object.partof = [];
       D(i).annotation.object.partofobject = [];
       D(i).annotation.object.id = 1;
       

       %D(i).annotation.object = objs;
       D(i).annotation.train = 1;
       D(i).annotation.val = 0;
       D(i).annotation.test = 0;
    end
end

function pts = bbox2poly(bbox);
% Grabbed from labelme
pts(1).x = num2str(bbox(1));
pts(1).y = num2str(bbox(2));

pts(2).x = num2str(bbox(1));
pts(2).y = num2str(bbox(4));

pts(3).x = num2str(bbox(3));
pts(3).y = num2str(bbox(4));

pts(4).x = num2str(bbox(3));
pts(4).y = num2str(bbox(2));
%pts = pts);


end

