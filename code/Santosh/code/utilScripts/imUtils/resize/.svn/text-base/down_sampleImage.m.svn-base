function small=down_sampleImage(big,rows,cols,psize)
% function from small=down_samplegist2(big,nr,nc)
% averaging over non-overlapping spatial blocks

nr = size(rows,1);
nc = size(cols,1);

small = zeros(nr, nc, size(big,3));
for r=1:nr
  for c=1:nc
    v = big(rows(r):rows(r)+psize-1, cols(c):cols(c)+psize-1, :);
    v = mean(mean(v,1),2);
    small(r,c,:) = v(:);
  end
end
