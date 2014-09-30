function dump_text_data(gt,FD,outname)

fid = fopen(outname, 'w');
for i=1:length(gt)
    fprintf(fid, '%d ', gt(i));
    fprintf(fid, '%d:%g ', [1:length(FD(i,:));FD(i,:)]);
    fprintf(fid, '\n');
end
fclose(fid);
