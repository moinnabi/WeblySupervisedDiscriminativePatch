function retval = myalldone(donedir, numImgs)

for f = 1:numImgs
    if ~exist([donedir '/' num2str(f) '.done'],'dir')
        retval = false;
        return;
    end
end
retval = true;
