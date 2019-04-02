function varargout = gui_v0(varargin)
% GUI_V0 MATLAB code for gui_v0.fig
%      GUI_V0, by itself, creates a new GUI_V0 or raises the existing
%      singleton*.
%
%      H = GUI_V0 returns the handle to a new GUI_V0 or the handle to
%      the existing singleton*.
%
%      GUI_V0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_V0.M with the given input arguments.
%
%      GUI_V0('Property','Value',...) creates a new GUI_V0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_v0_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_v0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_v0

% Last Modified by GUIDE v2.5 01-Apr-2019 13:53:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_v0_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_v0_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_v0 is made visible.
function gui_v0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_v0 (see VARARGIN)

% Choose default command line output for gui_v0
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

axes(handles.image_place)
matlabImage = imread('eye_sketch.jpg');
image(matlabImage)
axis off
axis image

% UIWAIT makes gui_v0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_v0_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in menu_roi.
function menu_roi_Callback(hObject, eventdata, handles)
% hObject    handle to menu_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_roi contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_roi
% contents = cellstr(get(hObject,'String'))
% roi = contents{get(hObject,'Value')}
% if strcmp(roi,'ROI Not Set') || strcmp(roi,'No')
%     roi_set = 0;
% else
%     roi_set = 1;
% end



% --- Executes during object creation, after setting all properties.
function menu_roi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_format.
function menu_format_Callback(hObject, eventdata, handles)
% hObject    handle to menu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_format
contents = cellstr(get(hObject,'String'));
format = contents{get(hObject,'Value')};



% --- Executes during object creation, after setting all properties.
function menu_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 

function txt_fps_Callback(hObject, eventdata, handles)
% hObject    handle to txt_fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_fps as text
%        str2double(get(hObject,'String')) returns contents of txt_fps as a double
% try
%     fps_input = str2double(get(hObject,'String'));
% catch
%     ed = errordlg('Input must be a number','Error');
%     uiwait(ed);
% end



% --- Executes during object creation, after setting all properties.
function txt_fps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_fps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_export.
function menu_export_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_export contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_export
% contents = cellstr(get(hObject,'String'));
% export_yn = contents{get(hObject,'Value')};
% if strcmp(export_yn,'Yes')
%     vidYN = 1;
% else
%     vidYN = 0;
% end

% --- Executes during object creation, after setting all properties.
function menu_export_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function menu_rgb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_rgb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in menu_rgb.
function menu_rgb_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rgb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns menu_rgb contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_rgb
% contents = cellstr(get(hObject,'String'));
% rgb = contents{get(hObject,'Value')};
% handles.rgb = rgb;
% guidata(hObject,handles)


function txt_fname_Callback(hObject, eventdata, handles)
% hObject    handle to txt_fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_fname as text
%        str2double(get(hObject,'String')) returns contents of txt_fname as a double
% filename2 = get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function txt_fname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_launch.
function btn_launch_Callback(hObject, eventdata, handles)
% hObject    handle to btn_launch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
definput = {'0','0','your_file','1','0','RGB','jpg','500'};

% RGB / GRAY:
cont_rgb = handles.menu_rgb.get('String');
color = cont_rgb{get(handles.menu_rgb,'Value')};

% FORMAT JPG:

cont_format = handles.menu_format.get('String');
suffix = cont_format{get(handles.menu_format,'Value')};

% ROI:
cont_roi = handles.menu_roi.get('String');
roi = cont_roi{get(handles.menu_roi,'Value')};
if strcmp(roi,'ROI Not Set') || strcmp(roi,'No')
    roi_Need = 1;
else
    roi_Need = 0;
end

% VIDEO?
cont_export = handles.menu_export.get('String');
export_yn = cont_export{get(handles.menu_export,'Value')};
if strcmp(export_yn,'Yes')
    vidYN = 1;
else
    vidYN = 0;
end

% FPS: 
try
    fps = str2double(get(handles.txt_fps,'String'));
catch
    ed = errordlg('Input must be a number','Error');
    uiwait(ed);
end

% Filename:
fname = handles.txt_fname.get('String');

% Eye side:
radio_right = get(handles.radio_right,'Value');
if radio_right == 1 
    right_left = 1;
    % we are inspecting the right side
else
    % looking at left eye else
    right_left = 2;
end

% Launching the tracking protocol:
eyelid_tracking_gui(roi_Need,fps,vidYN,color,suffix,right_left,fname)


% --- Executes on button press in radio_right.
function radio_right_Callback(hObject, eventdata, handles)
% hObject    handle to radio_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RightLeft = 1;

% Hint: get(hObject,'Value') returns toggle state of radio_right


% --- Executes on button press in radio_left.
function radio_left_Callback(hObject, eventdata, handles)
% hObject    handle to radio_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
RightLeft = 2;

% Hint: get(hObject,'Value') returns toggle state of radio_left
