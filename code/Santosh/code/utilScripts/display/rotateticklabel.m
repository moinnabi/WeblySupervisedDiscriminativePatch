function th=rotateticklabel(h,rot,demo)
%ROTATETICKLABEL rotates tick labels
%   TH=ROTATETICKLABEL(H,ROT) is the calling form where H is a handle to
%   the axis that contains the XTickLabels that are to be rotated. ROT is
%   an optional parameter that specifies the angle of rotation. The default
%   angle is 90. TH is a handle to the text objects created. For long
%   strings such as those produced by datetick, you may have to adjust the
%   position of the axes so the labels don't get cut off.
%
%   Of course, GCA can be substituted for H if desired.
%
%   TH=ROTATETICKLABEL([],[],'demo') shows a demo figure.
%
%   Known deficiencies: if tick labels are raised to a power, the power
%   will be lost after rotation.
%
%   See also datetick.

%   Written Oct 14, 2005 by Andy Bliss
%   Copyright 2005 by Andy Bliss

try
%DEMO:
if nargin==3
    x=[now-.7 now-.3 now];
    y=[20 35 15];
    figure
    plot(x,y,'.-')
    datetick('x',0,'keepticks')
    h=gca;
    set(h,'position',[0.13 0.35 0.775 0.55])
    rot=90;
end

%set the default rotation if user doesn't specify
if nargin==1
    rot=90;
end
%make sure the rotation is in the range 0:360 (brute force method)
while rot>360
    rot=rot-360;
end
while rot<0
    rot=rot+360;
end
%get current tick labels
a=get(h,'XTickLabel');
%erase current tick labels from figure
set(h,'XTickLabel',[]);
%get tick label positions
b=get(h,'XTick');
c=get(h,'YTick');
set(gca,'Position', [0.14 0.24 0.763537 0.74]); % set this for cvpr09 confusion matrix
%set(gca,'position',[0.13 0.35 0.775 0.55])

disp('here'); keyboard; 
%make new tick labels
if rot<180    
    %th=text(b,repmat(c(1)-.2*(c(2)-c(1)),length(b),1)+length(c),a,... 
    %    'HorizontalAlignment','right','rotation',rot, 'FontSize',24, 'FontWeight','bold');  % for cvpr09 conf mat
    th=text(b,repmat( c(1)-2*(c(2)-c(1)) ,length(b),1),a,...
       'HorizontalAlignment','right','rotation',rot, 'FontSize',24, 'FontWeight','bold');  % for bmvc12 plot
else
    th=text(b,repmat(c(1)-(c(2)-c(1)),length(b),1)+length(c),a,...
        'HorizontalAlignment','left','rotation',rot, 'FontSize',24, 'FontWeight','bold');    % for cvpr09 conf mat
    %th=text(b,repmat(c(1)-.1*(c(2)-c(1)),length(b),1),a,...
     %   'HorizontalAlignment','left','rotation',rot, 'FontSize',24, 'FontWeight','bold');
end

catch
    disp(lasterr); keyboard;
end
