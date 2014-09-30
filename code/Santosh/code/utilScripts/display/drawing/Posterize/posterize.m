%This gui posterizes an rgb image with sliders for setting the no. of
%   levels for each r,g,b components.

function varargout = posterize(varargin)
% POSTERIZE M-file for posterize.fig
%      POSTERIZE, by itself, creates a new POSTERIZE or raises the existing
%      singleton*.
%
%      H = POSTERIZE returns the handle to a new POSTERIZE or the handle to
%      the existing singleton*.
%
%      POSTERIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in POSTERIZE.M with the given input arguments.
%
%      POSTERIZE('Property','Value',...) creates a new POSTERIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before posterize_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to posterize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help posterize

% Last Modified by GUIDE v2.5 02-Nov-2006 00:33:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @posterize_OpeningFcn, ...
                   'gui_OutputFcn',  @posterize_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before posterize is made visible.
function posterize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to posterize (see VARARGIN)

% Choose default command line output for posterize
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes posterize wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = posterize_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%--------------------------------------------------------------------------
% --- Executes on button press in open.
function open_Callback(hObject, eventdata, handles)
[FileName,PathName]=uigetfile( ...
{
'*.jpg*', '(*.jpg*)';
'*.bmp*', '(*.bmp*)';
'*.tiff*', '(*.tiff*)';
'*.png*', '(*.png*)';
'*.hdf*', '(*.hdf*)';
'*.ras*', '(*.ras*)';
'*.ppm*', '(*.ppm*)';
'*.*', 'All Files (*.*)'
}, 'Choose any RGB Image File');
y1= [PathName,FileName];
if(PathName~=0)
img_data=imread(y1);
[m n r]=size(img_data);
if(r==1)
    set(handles.warn_text,'String','Choose a RGB image please......')
    pause(2);
    set(handles.warn_text,'String','')
else
handles.img_data=img_data;
handles.output_data=img_data;
handles.red_val=0;handles.green_val=0;handles.blue_val=0;
guidata(handles.figure1,handles)
imshow(img_data)
end
end
%--------------------------------------------------------------------------
% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
[FileName,PathName,ext]=uiputfile( ...
{
'*.jpg*', '(*.jpg*)';
'*.bmp*', '(*.bmp*)';
'*.tiff*', '(*.tiff*)';
'*.png*', '(*.png*)';
'*.hdf*', '(*.hdf*)';
'*.ras*', '(*.ras*)';
'*.ppm*', '(*.ppm*)';
'*.*', 'All Files (*.*)'
}, 'Save the posterized image');
if(PathName~=0)
format_arr={'jpg' 'bmp' 'tiff' 'png' 'hdf' 'ras' 'ppm'};
FileName=[FileName '.' char(format_arr(ext))];
y2=[PathName,FileName];
imwrite(handles.output_data,y2);
end
%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function red_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% --- Executes on slider movement.
function red_Callback(hObject, eventdata, handles)
set(handles.status_text,'String','Updating Image......')
handles.red_val=get(hObject,'Value');
guidata(handles.figure1,handles)
output_data=posterize_rgb(handles.img_data,255-handles.red_val,255-handles.green_val,255-handles.blue_val);
set(handles.status_text,'String','')
imshow(output_data)
handles.output_data=output_data;
guidata(handles.figure1,handles)
%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function green_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% --- Executes on slider movement.
function green_Callback(hObject, eventdata, handles)
set(handles.status_text,'String','Updating Image......')
handles.green_val=get(hObject,'Value');
guidata(handles.figure1,handles)
output_data=posterize_rgb(handles.img_data,255-handles.red_val,255-handles.green_val,255-handles.blue_val);
set(handles.status_text,'String','')
imshow(output_data)
handles.output_data=output_data;
guidata(handles.figure1,handles)
%--------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blue_CreateFcn(hObject, eventdata, handles)
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% --- Executes on slider movement.
function blue_Callback(hObject, eventdata, handles)
set(handles.status_text,'String','Updating Image......')
handles.blue_val=get(hObject,'Value');
guidata(handles.figure1,handles)
output_data=posterize_rgb(handles.img_data,255-handles.red_val,255-handles.green_val,255-handles.blue_val);
set(handles.status_text,'String','')
imshow(output_data)
handles.output_data=output_data;
guidata(handles.figure1,handles)
%--------------------------------------------------------------------------





