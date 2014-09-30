function convertTxtToXmlWrappper

try
% convert .txt to .xml in Annotations
imgsetdir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/ImageSets/Main/';
annodir = '/nfs/hn12/sdivvala/objectNgrams/results/object_ngramImg_finalData/Annotations/';
[ids gt] = textread([imgsetdir '/test_withLabels.txt'], '%s %d');
ids = ids(gt == 1);
for i=1:length(ids)    
    myprintf(i,10);    
    annfile = [annodir '/' ids{i} '.txt'];
    annfilexml = [annodir '/' ids{i} '.xml'];
    if ~exist(annfilexml, 'file')
        rec = myPASreadrecord(annfile);
        if max(rec.imgsize(1), rec.imgsize(2)) > 501
            disp('jsm'); keyboard;
        end
        
        if 1
            rec.filename = rec.imgname;
            rec.segmented = 0;
            
            if numel(rec.objects) ==1 && isempty(rec.objects(1).label)
                rec.objects(1).label = 'bahbahblacksheep';
                rec.objects(1).bbox = [0 0 0 0];
            end
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
        rec_new = myVOCreadrecxml(annfilexml);
        delete(annfile);
    end
end
myprintfn;

catch
    disp(lasterr); keyboard;
end
