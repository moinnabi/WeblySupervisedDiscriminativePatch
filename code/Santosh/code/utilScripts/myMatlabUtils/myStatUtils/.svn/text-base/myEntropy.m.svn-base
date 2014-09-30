function e = myEntropy(histv)

ind = find(histv>0);
e = -sum(log(histv(ind)).*(histv(ind)));

%{
function ent = entropy(P) 
% rows of P must sum to 1
% from Svetlana

P_nonzero = P + (P==0);
L = -log(P_nonzero);
ent = sum(L .* P, 2);
%}

%{
ind = find(histv>0);
e = -sum(log(histv(ind)).*(histv(ind)));
%}
