function PASannotatedir(PASdir)

try
    
%PASdir='../data/';
ORGlabel='TBD';     %original label
DATstr='Google Ngram Image Database';

JPEGdir=[PASdir,'JPEGImages/'];
ANNdir=[PASdir,'Annotations/'];
classfilename=[PASdir '/classes.txt'];

d=dir([JPEGdir,'/*.jpg']);
for i=1:length(d),
    img=imread([JPEGdir,d(i).name]);
    fprintf('-- Now annotating %s --\n',d(i).name);
    record=PASannotateimg(img,classfilename);
    record.imgname=d(i).name;
    record.database=DATstr;
    
    for j=1:length(record.objects),
        record.objects(j).orglabel=ORGlabel;
    end;
    
    [path,name,ext]=fileparts(d(i).name);
    annfile=[ANNdir,name,'.txt'];
    comments={}; % Extra comments = array of cells (one per line)
    PASwriterecord(annfile,record,comments);
    if (~PAScmprecords(record,PASreadrecord(annfile)))
        PASerrmsg('Records do not match','');
    end;
end;

catch
    disp(lasterr); keyboard;
end
