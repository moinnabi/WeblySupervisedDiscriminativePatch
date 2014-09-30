function MR = row_rescale(M)
% normalizing i.e., rescaling rows of a matrix to [0 1] interval
% from Svetlana

sums = sum(M,2);
sums(find(sums==0)) = 1;

S = repmat(sums, [1 size(M,2)]);
MR = M ./ S;
