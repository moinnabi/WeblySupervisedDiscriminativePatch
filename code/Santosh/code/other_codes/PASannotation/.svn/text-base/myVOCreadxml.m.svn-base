function rec = myVOCreadxml(path)

if length(path)>5&&strcmp(path(1:5),'http:')
    xml=urlread(path)';
else
    f=fopen(path,'r');
    xml=fread(f,'*char')';
    fclose(f);
end
rec=myVOCxml2struct(xml);
