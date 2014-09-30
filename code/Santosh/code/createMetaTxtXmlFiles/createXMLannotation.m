function createXMLannotation(destfname_anno, imgFileName, ngramname, objname, sourcefname)

fid=fopen(destfname_anno,'w');

%writexml(fid,rec,0);
im = imread(sourcefname);
imw = size(im,2);
imh = size(im,1);
imd = size(im,3);

fprintf(fid, '<annotation>\n');
fprintf(fid, '\t<imgname>%s</imgname>\n', imgFileName);     % added later (for horse test, but not for horse train)
fprintf(fid, '\t<filename>%s</filename>\n', imgFileName);
fprintf(fid, '\t<folder>Google</folder>\n');
% write objname
fprintf(fid, '\t<object>\n');
fprintf(fid, '\t\t<orglabel>TBD</orglabel>\n');             % added later (for horse test, but not for horse train)
fprintf(fid, '\t\t<name>%s</name>\n', objname);
fprintf(fid, '\t\t<bndbox>\n');
fprintf(fid, '\t\t\t<xmax>%d</xmax>\n', imw);
fprintf(fid, '\t\t\t<xmin>1</xmin>\n');
fprintf(fid, '\t\t\t<ymax>%d</ymax>\n', imh);
fprintf(fid, '\t\t\t<ymin>1</ymin>\n');
fprintf(fid, '\t\t</bndbox>\n');
fprintf(fid, '\t\t<difficult>0</difficult>\n');
fprintf(fid, '\t\t<occluded>0</occluded>\n');
fprintf(fid, '\t\t<pose>0</pose>\n');
fprintf(fid, '\t\t<truncated>0</truncated>\n');
fprintf(fid, '\t</object>\n');
% write phrasename
fprintf(fid, '\t<object>\n');
fprintf(fid, '\t\t<orglabel>TBD</orglabel>\n');             % added later (for horse test, but not for horse train)
fprintf(fid, '\t\t<name>%s</name>\n', ngramname);
fprintf(fid, '\t\t<bndbox>\n');
fprintf(fid, '\t\t\t<xmax>%d</xmax>\n', imw);
fprintf(fid, '\t\t\t<xmin>1</xmin>\n');
fprintf(fid, '\t\t\t<ymax>%d</ymax>\n', imh);
fprintf(fid, '\t\t\t<ymin>1</ymin>\n');
fprintf(fid, '\t\t</bndbox>\n');
fprintf(fid, '\t\t<difficult>0</difficult>\n');
fprintf(fid, '\t\t<occluded>0</occluded>\n');
fprintf(fid, '\t\t<pose>0</pose>\n');
fprintf(fid, '\t\t<truncated>0</truncated>\n');
fprintf(fid, '\t</object>\n');
fprintf(fid, '\t<segmented>0</segmented>\n');
fprintf(fid, '\t<size>\n');
fprintf(fid, '\t\t<depth>%d</depth>\n', imd);
fprintf(fid, '\t\t<height>%d</height>\n', imh);
fprintf(fid, '\t\t<width>%d</width>\n', imw);
fprintf(fid, '\t</size>\n');
fprintf(fid, '\t<source>\n');
fprintf(fid, '\t\t<annotation>Google</annotation>\n');
fprintf(fid, '\t\t<database>Google Ngram Image Database</database>\n'); % updated later (for horse test, but not for horse train)
fprintf(fid, '\t\t<image>Google</image>\n');
fprintf(fid, '\t</source>\n');
fprintf(fid, '</annotation>\n');

fclose(fid);


%{
<annotation>
        <filename>2009_001390.jpg</filename>
        <folder>VOC2010</folder>
        <object>
                <name>aeroplane</name>
                <bndbox>
                        <xmax>478</xmax>
                        <xmin>8</xmin>
                        <ymax>223</ymax>
                        <ymin>107</ymin>
                </bndbox>
                <difficult>0</difficult>
                <occluded>0</occluded>
                <pose>0</pose>
                <truncated>0</truncated>
        </object>
        <segmented>0</segmented>
        <size>
                <depth>3</depth>
                <height>344</height>
                <width>500</width>
        </size>
        <source>
                <annotation>PASCAL VOC2009</annotation>
                <database>The VOC2009 Database</database>
                <image>flickr</image>
        </source>
</annotation>
%}
