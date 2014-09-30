function bestIdx = kmeansWrapper(featMat, numClustersPerSplit, distfn)

if nargin < 3
    distfn = 'sqEuclidean';
end
 
maxiter = 5;
bestv = inf;
clusCentMat = [];
for j = 1:maxiter
    myprintf(j);
            
    [Idx, clusCentMat, v] = kmeans(featMat, numClustersPerSplit, 'Replicates', 5, 'distance', distfn);    
    
    v = sum(v);
    if v < bestv
        fprintf('new total intra-cluster variance: %f\n', v);
        bestv = v;        
        bestIdx = Idx';
        bestclusCentMat = clusCentMat';
    end
end
myprintfn;
