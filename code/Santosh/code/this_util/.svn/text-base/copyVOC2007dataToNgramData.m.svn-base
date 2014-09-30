function copyVOC2007dataToNgramData(voc07dir, jpgdir, annodir, imgsetdir)

try
indir_info = [voc07dir '/ImageSets/Main/'];

indir  = [voc07dir '/JPEGImages/'];
%jpgdir  = [basedir '/Datasets/Pascal_VOC/VOC9990/JPEGImages/']; mymkdir(jpgdir);

indir_anno  = [voc07dir '/Annotations/'];
%annodir  = [basedir '/Datasets/Pascal_VOC/VOC9990/Annotations/']; mymkdir(annodir);

% copy images and annotations
disp(' copy images and annotations of trainval');
ids = textread([indir_info '/trainval.txt'], '%s');
for i = 1:length(ids)
    myprintf(i,100);
    system(['ln -s ' indir '/' ids{i} '.jpg' ' ' jpgdir '/']);
    
    system(['ln -s ' indir_anno '/' ids{i} '.xml' ' ' annodir '/']);
end
myprintfn;

disp(' copy images and annotations of  test');
ids = textread([indir_info '/test.txt'], '%s');
for i = 1:length(ids)
    myprintf(i,100);
    system(['ln -s ' indir '/' ids{i} '.jpg' ' ' jpgdir '/']);
    
    system(['ln -s ' indir_anno '/' ids{i} '.xml' ' ' annodir '/']);
end
myprintfn;

disp('copy .txt files')
ids = mydir([indir_info '/*.txt']);
for i = 1:length(ids)
    system(['ln -s ' indir_info '/' ids{i} ' ' imgsetdir '/']);
end

catch
    disp(lasterr); keyboard;
end


%{
%basedir = '/nfs/hn12/sdivvala/';

if 0
disp('copy VOC train images ');
indir_info = [basedir '/Datasets/Pascal_VOC/VOC2007/ImageSets/Main/'];
indir  = [basedir '/Datasets/Pascal_VOC/VOC2007/JPEGImages/'];
outdir  = [basedir '/Datasets/Pascal_VOC/VOC9990/JPEGImages/'];
ids = textread([indir_info '/trainval.txt'], '%s');
for i = 1:length(ids)
    myprintf(i,100);
    %copyfile([indir '/' ids{i} '.jpg'], outdir);    
    %%%system(['\rm ' outdir '/' ids{i} '.jpg']);
    system(['ln -s ' indir '/' ids{i} '.jpg' ' ' outdir '/']);
end
myprintfn;
end

if 0
disp('copy VOC test images ');
outdir  = [basedir '/Datasets/Pascal_VOC/VOC9990/JPEGImages/'];
indir  = [basedir '/Datasets/Pascal_VOC/VOC2007/JPEGImages/'];
indir_info = [basedir '/Datasets/Pascal_VOC/VOC2007/ImageSets/Main/'];
ids = textread([indir_info '/test.txt'], '%s');
for i = 1:length(ids)
    myprintf(i,100);
    %copyfile([indir '/' ids{i} '.jpg'], outdir);    
    %%%system(['\rm ' outdir '/' ids{i} '.jpg']);
    system(['ln -s ' indir '/' ids{i} '.jpg' ' ' outdir '/']);
end
myprintfn;
end

if 0
disp(' copy VOC trainval annotations ');
indir_info = [basedir '/Datasets/Pascal_VOC/VOC2007/ImageSets/Main/'];
indir_anno  = [basedir '/Datasets/Pascal_VOC/VOC2007/Annotations/'];
outdir_anno  = [basedir '/Datasets/Pascal_VOC/VOC9990/Annotations/'];
ids = textread([indir_info '/trainval.txt'], '%s');
for i = 1:length(ids)
    myprintf(i,100);    
    system(['ln -s ' indir_anno '/' ids{i} '.xml' ' ' outdir_anno '/']);
end
myprintfn;
end

if 0
disp(' copy VOC test annotations ');
indir_info = [basedir '/Datasets/Pascal_VOC/VOC2007/ImageSets/Main/'];
indir_anno = [basedir '/Datasets/Pascal_VOC/VOC2007/Annotations/'];
outdir_anno  = [basedir '/Datasets/Pascal_VOC/VOC9990/Annotations/'];
ids = textread([indir_info '/test.txt'], '%s');
for i = 1:length(ids)
    myprintf(i,100);    
    system(['ln -s ' indir_anno '/' ids{i} '.xml' ' ' outdir_anno '/']);
end
myprintfn;
end
%}
