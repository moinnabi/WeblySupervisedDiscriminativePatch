%function thisrows = readRowsFromMat(fid, rowInds)
function thisrows = readRowsFromMat(filename, rowInds)

numBytePerCol = 16;
%filename = [CAOBopts.datadir '/featureData/sample.txt'];

fid = fopen(filename, 'r');

if fid ~= -1 
    %fseek(fid,0,'bof');
    siz= fscanf(fid, '%f %f\n',[1 2]);
    numcols = siz(2);
    thisrows = zeros(length(rowInds), numcols, 'single');

    [srowInds sinds] = sort(rowInds);
    sinvinds(sinds) = 1:length(rowInds);
    jumprowInds = [srowInds(1); srowInds(2:end) - srowInds(1:end-1)];
    for i=1:length(jumprowInds)
        rowindex = (jumprowInds(i)-1)*(numcols*numBytePerCol+1);    % +1 is for \n
        fseek(fid, rowindex, 'cof');
        thisrows(i,:) = fscanf(fid, '%g ',[1 numcols]);
    end
    thisrows = thisrows(sinvinds,:);
    fclose(fid);
else
    disp('cant open file');
end

