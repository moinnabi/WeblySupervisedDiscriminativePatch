function pluralWord = getPlural(singword)

if strcmp(singword, 'sheep') 
    pluralWord = 'sheep';
    return;
elseif strcmp(singword, 'person')
    pluralWord = 'people';
    return;
end

if (singword(end)=='y' && ~isvowel(singword(end-1)))
    % ~boy, fly
    pluralWord = [singword(1:end-1) 'ies'];
elseif (singword(end) =='o' && ~isvowel(singword(end-1)))
    % potato
    pluralWord = [singword(1:end-1) 'es'];    
elseif (singword(end) =='z'|| singword(end) =='s'|| singword(end) =='x')
    % bus, fox, buzz
    pluralWord = [singword(1:end) 'es'];    
elseif (singword(end) == 'h' && (singword(end-1) =='c' || singword(end-1) =='s' )) 
    % church, wish
    pluralWord = [singword(1:end-1) 'es'];    
% elseif (singword(end) == 'f')
%     % leaf vs but not chef?
%     pluralWord = [singword(1:end-1) 'ves'];        
% elseif (singword(end) =='e' && singword(end-1) =='f')
%     % not for safe?    
%     pluralWord = [singword(1:end-1) 'ves'];
else
    pluralWord = [singword(1:end) 's'];    
end
