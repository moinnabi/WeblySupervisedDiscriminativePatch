function result_new = doNMS_result(result)

for i=1:numel(result)
    myprintf(i,1000);
    I = nms([result(i).bbox result(i).scores], 0.5);
    result_new(i).bbox = result(i).bbox(I,:);
    result_new(i).scores = result(i).scores(I);
end
myprintfn;
