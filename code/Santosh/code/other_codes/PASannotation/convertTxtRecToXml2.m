function convertTxtRecToXml2(annfile, annfilexml)

rec = myPASreadrecord(annfile);
if 1
    rec.filename = rec.imgname;
    rec.segmented = 0;
    for j=1:numel(rec.objects)
        rec.objects(j).label = ['PAS' rec.objects(j).label];
    end
end
myVOCwritexml(rec, annfilexml);
