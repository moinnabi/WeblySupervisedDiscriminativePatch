function myPASwriteRecordWrapper(VOCopts, classlabel, baseclasslabel, id, bbox, diffic, gtsubdir)

ORGlabel='TBD';     %original label
DATstr='Google Ngram Image Database';

record=myPASemptyrecord;

img=imread(sprintf(VOCopts.imgpath,id));
[Y, X, N]=size(img);
record.imgsize=[X Y N];
record.imgname=[id '.jpg'];

xmin = bbox(1); ymin = bbox(2);
xmax = bbox(3); ymax = bbox(4);

record.objects(1)=myPASemptyobject;
record.objects(1).bbox=round([xmin ymin xmax ymax]);
record.objects(1).difficult = logical(diffic);
record.objects(1).label=baseclasslabel;

record.objects(2)=myPASemptyobject;
record.objects(2).bbox=round([xmin ymin xmax ymax]);
record.objects(2).difficult = logical(diffic);
record.objects(2).label=classlabel;

record.database=DATstr;
for j=1:length(record.objects),
    record.objects(j).orglabel=ORGlabel;
end

%annfile = [tempname '.txt'];
%PASwriterecord(annfile, record, {});
%convertTxtRecToXml(annfile, sprintf(VOCopts.annopath, [gtsubdir '/' id]));
%rec_new = myVOCreadrecxml(sprintf(VOCopts.annopath, [gtsubdir '/' id]));
%delete(annfile);

convertRecToXml(record, sprintf(VOCopts.annopath, [gtsubdir '/' id]));
