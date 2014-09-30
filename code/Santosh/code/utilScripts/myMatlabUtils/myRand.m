function randInds = myRand(numInds, maxRange)

myRandomize;
randInds = round(rand(numInds,1)*(maxRange-1))+1;  % e.g., generate 100 inds in range 1-numel(imlist)
