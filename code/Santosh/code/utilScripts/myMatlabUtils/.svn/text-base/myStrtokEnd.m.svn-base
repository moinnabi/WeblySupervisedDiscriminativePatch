function [tok str] = myStrtokEnd(str, delim)

[str remstr] = strtok(fliplr(str), delim);
tok = fliplr(remstr(2:end));
str = fliplr(str);