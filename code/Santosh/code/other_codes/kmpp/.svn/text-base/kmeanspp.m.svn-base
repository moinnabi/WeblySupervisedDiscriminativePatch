function [L,C,sumd] = kmeanspp(X,k)
%KMEANS Cluster multivariate data using the k-means++ algorithm.
%   [L,C] = kmeans(X,k) produces a 1-by-size(X,2) vector L with one class
%   label per column in X and a size(X,1)-by-k matrix C containing the
%   centers corresponding to each class.

%   Version: 17/11/10
%   Authors: Laurent Sorber (Laurent.Sorber@cs.kuleuven.be)
%
%   References:
%   [1] J. B. MacQueen, Some Methods for Classification and Analysis of 
%       MultiVariate Observations, in Proc. of the fifth Berkeley Symposium
%       on Mathematical Statistics and Probability, L. M. L. Cam and
%       J. Neyman, eds., vol. 1, UC Press, 1967, pp. 281-297.
%   [2] D. Arthur and S. Vassilvitskii, k-means++: The Advantages of
%       Careful Seeding, Technical Report 2006-13, Stanford InfoLab, 2006.

% X has to be dim x numPts and C will be dim x k!!

L = [];
L1 = 0;

while length(unique(L)) ~= k    
    try
        randindx = randi(size(X,2));
    catch % randi does not exist in R2008
        randindx = myRand(1,size(X,2));
    end
    C = X(:,randindx);
    L = ones(1,size(X,2));
    for i = 2:k
        D = X-C(:,L);
        D = sqrt(dot(D,D));
        C(:,i) = X(:,find(rand < cumsum(D)/sum(D),1));
        [tmp,L] = max(bsxfun(@minus,2*real(C'*X),dot(C,C).'));
    end
    
    while any(L ~= L1)
        L1 = L;
        for i = 1:k, l = L==i; C(:,i) = sum(X(:,l),2)/sum(l); end
        [tmp,L] = max(bsxfun(@minus,2*real(C'*X),dot(C,C).'),[],1);
    end
    
end

% added 10Feb11
%within-cluster sums of point-to-centroid distances in the 1-by-k vector sumd
sumd = zeros(1,k);
for i=1:k
    l= L==i;    
    D = X(:,l)-repmat(C(:,i), [1 length(find(l))]);
    sumd(i) = sum(sqrt(dot(D,D)));
end
