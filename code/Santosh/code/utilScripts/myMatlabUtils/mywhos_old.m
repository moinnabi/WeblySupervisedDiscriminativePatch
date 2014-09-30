function mywhos_old()

s = whos;
for k = 1:length(s)
    val = length(s(k).name);
end
maxlen = max(val);
fprintf(' %-20s %7s \t\t %10s  %s\n\n','Name','Size', 'MBytes', 'Class');
for k=1:length(s)
        fprintf(' %-20s %5dx%-5d \t %10.2f  %s \n',s(k).name,s(k).size(1), s(k).size(2), s(k).bytes/1000000,s(k).class);
end
fprintf('\n\tGrand Total is %10.3f MB\n\n',sum([s.bytes])/1000000);