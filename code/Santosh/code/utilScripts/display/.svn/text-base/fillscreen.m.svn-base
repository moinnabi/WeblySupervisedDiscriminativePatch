function fillscreen(hFig)
%FILLSCREEN           Set a figure size to completely fill the screen
%
% fillscreen sets the current figure size to completely fill the screen
%
% fillscreen(hFig) sets figure with handle hFig to completely fill the screen

% Scott Hirsch
% shirsch@mathworks.com


if nargin==0
    hFig = gcf;
end;

res=get(0,'ScreenSize');
set(hFig,'Position',[1 1 res(3) res(4)-64]); %Leave room for title bar
%x = 50;
%set(hFig,'Position',[1 x res(3)-x res(4)-70-x]); %Leave room for title bar
