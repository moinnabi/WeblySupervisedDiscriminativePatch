function thisrows = readRowsFromMat_binary(filename, rowInds)

numBytePerCol = 4;
numcols = 1488;
%filename = [CAOBopts.datadir '/featureData/sample.txt'];

fid = fopen(filename, 'rb');

if fid ~= -1
    thisrows = zeros(length(rowInds), numcols, 'single');

    [srowInds sinds] = sort(rowInds);
    sinvinds(sinds) = 1:length(rowInds);
    jumprowInds = [srowInds(1); srowInds(2:end) - srowInds(1:end-1)];
    for i=1:length(jumprowInds)
        rowindex = (jumprowInds(i)-1)*(numcols*numBytePerCol);    % no +1 is for \n as binary
        fseek(fid, rowindex, 'cof');
        %thisrows(i,:) = fscanf(fid, '%g ',[1 numcols]);
        thisrows(i,:) = fread(fid, numcols, 'float32');
    end
    thisrows = thisrows(sinvinds,:);
    fclose(fid);
else
    disp('cant open file');
end

