function thisinds = doStringMatch(ids, thisids)

thisinds = zeros(size(ids,1),1);
for i=1:numel(thisids)
    %myprintf(i, 100);
    thisinds(strcmp(thisids{i}, ids)) = 1;
end
%myprintfn;

