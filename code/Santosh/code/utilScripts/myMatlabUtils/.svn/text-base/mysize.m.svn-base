function a=mysize(thisvar,cnt)

if iscell(thisvar)
    if exist('cnt','var')
        len = cnt;
    else
        len = numel(thisvar);
    end
    a = [];
    for i=1:len
        a(i,:) = size(thisvar{i});
    end
    %disp([[uint32(1:len)]'   a(1:len,:)]);
end



