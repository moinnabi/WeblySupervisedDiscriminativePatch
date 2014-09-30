function mykillproc

machines = {'weh5336-g', 'weh5336-h', 'weh5336-i', 'weh5336-j', 'weh5336-k', 'weh5336-l', 'weh5336-m', ...
    'weh5336-a', 'weh5336-b', 'weh5336-c', 'weh5336-d', 'weh5336-e',  'weh5336-f',...
    'weh5336-n', 'weh5336-o', 'weh5336-p', 'weh5336-q', 'weh5336-r', 'weh5336-s', ...
    'weh5336-u', 'weh5336-v', 'weh5336-w', 'weh5336-x', 'weh5336-y', 'weh5336-t'};
%machines = machines(1:20);

garb = 92;
%for i=1:numel(machines)
    [status, output{i}] = system(['ps -aux -o %p|grep sdivvala|grep MultiM']);
    %[status, output{i}] = system(['pgrep ssh']);
    keyboard;
    pid = output{i}(garb-4:garb);    
    disp(['killing process ' pid]);
    [status result{i}] = system(['kill -9 ' pid]);
    if status == 0
        disp('killed process');
        disp(['message is ' result{i}]);
    end
%end

