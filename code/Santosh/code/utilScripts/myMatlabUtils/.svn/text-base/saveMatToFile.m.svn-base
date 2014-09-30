function saveMatToFile(mat)

CAOBopts = CAOBinit;
fid = fopen([CAOBopts.datadir '/featureData/sample3.txt'], 'w');

len = size(mat);
fprintf(fid, '%d %d\n',len(1), len(2));

for i=1:len(1)
    for j=1:len(2)
        fprintf(fid, '%e ', mat(i,j));
    end
    fprintf(fid, '\n');
end
fclose(fid);
