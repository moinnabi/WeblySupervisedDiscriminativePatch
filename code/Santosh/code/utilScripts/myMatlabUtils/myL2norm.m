function N = myL2norm(matrix)

N = sqrt(sum(abs(matrix).^2,2));
