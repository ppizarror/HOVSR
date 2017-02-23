function varargout = HOVSR(varargin)
% HOVSR MATLAB code for HOVSR.fig
%      HOVSR, by itself, creates a new HOVSR or raises the existing
%      singleton*.
%
%      H = HOVSR returns the handle to a new HOVSR or the handle to
%      the existing singleton*.
%
%      HOVSR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HOVSR.M with the given input arguments.
%
%      HOVSR('Property','Value',...) creates a new HOVSR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HOVSR_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HOVSR_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HOVSR

% Last Modified by GUIDE v2.5 15-Feb-2017 17:43:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HOVSR_OpeningFcn, ...
                   'gui_OutputFcn',  @HOVSR_OutputFcn, ...
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


% --- Executes just before HOVSR is made visible.
function HOVSR_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HOVSR (see VARARGIN)

% Choose default command line output for HOVSR
handles.output = hObject;
movegui(gcf, 'center');

% Load configs
config;

% Load language
lang = load_lang(LANGUAGE);
setappdata(handles.root, 'lang', lang);

% Set app strings
set(handles.boton_seleccionar_archivo, 'String', lang{1});
set(handles.close_button, 'String', lang{2});
set(handles.panel_acceleration_plots, 'Title', lang{3});
set(handles.panel_averagesv, 'Title', lang{4});
set(handles.panel_iteraciones, 'Title', lang{5});

% Figures id's
setappdata(handles.root, 'figureid1', 1);

% Clear status
clear_status(handles, lang);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HOVSR wait for user response (see UIRESUME)
% uiwait(handles.root);


% --- Outputs from this function are returned to the command line.
function varargout = HOVSR_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in boton_seleccionar_archivo.
function boton_seleccionar_archivo_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
% hObject    handle to boton_seleccionar_archivo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of boton_seleccionar_archivo
start_process(handles, getappdata(handles.root, 'lang'));

% --- Executes on button press in close_button.
function close_button_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to close_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of close_button
clear_status(handles, getappdata(handles.root, 'lang'));
close;
