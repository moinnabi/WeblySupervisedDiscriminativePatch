function [users] = unix_who()
%doesn't check for failure
%users is a cell array of users, without duplicates

[s,w] = unix('who');

carriage_returns = strfind(w, char(10));  %10 is the carriage return ?

num_lines = length(carriage_returns); 

users = cell(num_lines,1);

for i = 1:num_lines
    [t1,w] = strtok(w, char(10));
    [t2,r] = strtok(t1);
    users{i,1} = t2;    
end
