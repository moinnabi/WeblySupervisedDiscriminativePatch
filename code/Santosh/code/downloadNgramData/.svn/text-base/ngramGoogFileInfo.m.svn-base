function numNgramFiles = ngramGoogFileInfo(ngramtype)

%{
if ngramtype == 2, numNgramFiles = 100;
elseif ngramtype == 3, numNgramFiles = 200;
elseif ngramtype == 4, numNgramFiles = 400;
elseif ngramtype == 5, numNgramFiles = 800; end
%}

% get this info from http://storage.googleapis.com/books/ngrams/books/datasetsv2.html
if ngramtype == 0
    numNgramFiles = 26;
elseif ngramtype == 2 || ngramtype == 3 || ngramtype == 4 || ngramtype == 5
    numNgramFiles = length(getfcode_forngram(ngramtype, 0));
end
