function W = getRandSymmetric(n)

W = rand(n);
W = triu(W);
W = W + W';
