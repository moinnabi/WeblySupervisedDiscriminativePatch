function row = readRowFromMat(filename, rowInd)

numBytePerCol = 16;
%filename = [CAOBopts.datadir '/featureData/sample.txt'];

fid = fopen(filename, 'r');

if fid ~= -1
    siz= fscanf(fid, '%f %f\n',[1 2]);
    numcols = siz(2);

    rowindex = (rowInd-1)*(numcols*numBytePerCol+1);    % +1 is for \n
    fseek(fid, rowindex, 'cof');
    row = fscanf(fid, '%g ',[1 numcols]);
    fclose(fid);
else
    disp('cant open file');
end

%%
