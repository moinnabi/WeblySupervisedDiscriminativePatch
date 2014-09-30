function r = need_to_exit(play_nice)
%to use this code in a deployed manner on public machines, I need to quit
%if someone else (such as a graphics student) logs in
r = 0;

if(play_nice)
  users = unix_who;
  if(~all( strcmp(users, 'jhhays'))) %if all the users aren't me
     fprintf('!!! In play nice mode and detected other user. EXITING !!!\n');
     r = 1;
  end
end