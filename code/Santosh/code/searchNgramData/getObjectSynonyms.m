function objname_syns = getObjectSynonyms(objname)

[classes, ~, ~,all_objname_syns] = VOCoptsClasses;
objname_syns = all_objname_syns{strcmp(classes, objname)};

%{
if strcmp(objname, 'aeroplane')
    objname_syns = {'aeroplane', 'airplane', 'aircraft'};
%elseif strcmp(objname, 'boat')    
%    objname_syns = {'boat', 'ship'};
elseif strcmp(objname, 'motorbike')
    objname_syns = {'motorbike', 'motorcycle', 'moped', 'scooter'};
elseif strcmp(objname, 'tvmonitor')
    objname_syns = {'tv', 'monitor', 'television'};
elseif strcmp(objname, 'pottedplant')
    objname_syns = {'pottedplant', 'houseplant', 'flowerpot', 'plantpot'};
elseif strcmp(objname, 'diningtable')
    objname_syns = {'diningtable', 'table'};
elseif strcmp(objname, 'tehran')
    objname_syns = {'tehran', 'Tehran'};
elseif strcmp(objname, 'brazil')
    objname_syns = {'brazil', 'Brazil'};    
elseif strcmp(objname, 'diwali')
    objname_syns = {'diwali', 'Diwali', 'Navratri', 'Dussehra'};    
else 
    objname_syns = {objname};  
end
%}
