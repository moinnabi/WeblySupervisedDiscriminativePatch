function thisStruct = updateStruct(thisStruct, kept)
    
    resnames = fieldnames(thisStruct);
    for j=1:length(resnames)        
        value = getfield(thisStruct, resnames{j});
        value = value(kept,:);
        thisStruct = setfield(thisStruct, resnames{j}, value);
    end
