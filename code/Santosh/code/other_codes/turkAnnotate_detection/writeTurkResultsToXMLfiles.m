function writeTurkResultsToXMLfiles(objname, objturkdir, annodir)

try
    
inpfname = [objturkdir '/' objname '.results'];
[~, annotateInfo] = system(['cat ' inpfname ' | gawk ''{print $NF}'' | cut -b 1 --complement | rev | cut -b  2- | rev']);
annotateInfo = regexp(annotateInfo, '\n', 'split');
annotateInfo(cellfun('isempty', annotateInfo)) = [];

annotateInfo = annotateInfo(2:end);

for f=1:numel(annotateInfo)
    myprintf(f,100);
    toks = strtokAll(annotateInfo{f},',');
    clsname = toks{1}; imgid = toks{2};
    if ~strcmp(clsname, objname), disp('some issue here'); keyboard; end
    xmin=str2num(toks{3}); ymin=str2num(toks{4});
    xmax=str2num(toks{5}); ymax=str2num(toks{6});

    %{
    img = imread([jpgdir '/' imgid]);
    [Y X N]=size(img);
    record=PASemptyrecord;
    record.imgsize=[X Y N];
    record.imgname=imgid;
    record.database=DATstr;
    
    record.objects(1)=PASemptyobject;
    record.objects(1).bbox=[xmin ymin xmax ymax];
    record.objects(1).label=clsname;
        
    record.objects(2)=PASemptyobject;
    record.objects(2).bbox=[xmin ymin xmax ymax];
    record.objects(2).label=classlabel;
    
    for j=1:length(record.objects),
        record.objects(j).orglabel=ORGlabel;
    end
    %}
    
    rec=PASreadrecord([annodir '/' strtok(imgid,'.') '.xml']);
    
    rec.objects(1).bbox = [xmin ymin xmax ymax];
    rec.objects(1).bndbox.xmin = rec.objects(1).bbox(1);
    rec.objects(1).bndbox.ymin = rec.objects(1).bbox(2);
    rec.objects(1).bndbox.xmax = rec.objects(1).bbox(3);
    rec.objects(1).bndbox.ymax = rec.objects(1).bbox(4);
    rec.objects(2).bbox = [xmin ymin xmax ymax];
    rec.objects(2).bndbox.xmin = rec.objects(2).bbox(1);
    rec.objects(2).bndbox.ymin = rec.objects(2).bbox(2);
    rec.objects(2).bndbox.xmax = rec.objects(2).bbox(3);
    rec.objects(2).bndbox.ymax = rec.objects(2).bbox(4);
    
    convertRecToXml(rec, [annodir '/' strtok(imgid,'.') '.xml']);    
end
myprintfn;

catch
    disp(lasterr); keyboard;
end
