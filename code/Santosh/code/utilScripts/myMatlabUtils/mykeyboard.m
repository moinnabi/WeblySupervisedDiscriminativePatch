%function mykeyboard(info)%, mode)

disp(info); keyboard;
%{
if mode == 1
    disp(info); keyboard;
elseif mode == 2
    if info == 1, keyboard; end
end
%}
