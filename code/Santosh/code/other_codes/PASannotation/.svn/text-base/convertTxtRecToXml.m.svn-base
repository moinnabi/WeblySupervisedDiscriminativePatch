function convertTxtRecToXml(annfile, annfilexml)

rec = myPASreadrecord(annfile);
if 0
    rec.filename = rec.imgname;
    rec.segmented = 0;
    for j=1:numel(rec.objects)
        rec.objects(j).label = ['PAS' rec.objects(j).label];
    end
end
if 1 % copied from convertTxtToXmlWrappper.m
    rec.filename = rec.imgname;
    rec.segmented = 0;
    for j=1:numel(rec.objects)
        %rec.objects(j).label = ['PAS' rec.objects(j).label];
        rec.objects(j).name = rec.objects(j).label;
        
        rec.objects(j).bndbox.xmin = rec.objects(j).bbox(1);
        rec.objects(j).bndbox.ymin = rec.objects(j).bbox(2);
        rec.objects(j).bndbox.xmax = rec.objects(j).bbox(3);
        rec.objects(j).bndbox.ymax = rec.objects(j).bbox(4);
                
    end
    rec.objects = rmfield(rec.objects, 'bbox');
    rec.objects = rmfield(rec.objects, 'label');
    rec.object = rec.objects;
    rec = rmfield(rec, 'objects');
    
    rec.size.depth = rec.imgsize(3);
    rec.size.height = rec.imgsize(2);
    rec.size.width = rec.imgsize(1);
    rec = rmfield(rec, 'imgsize');
    
    rec.folder = 'Google';
    
    rec.source.database = rec.database;
    rec.source.annotation = 'Google';
    rec.source.image = 'Google';
    
    rec = rmfield(rec, 'database');
end
blah.annotation = rec;
myVOCwritexml(blah, annfilexml);
