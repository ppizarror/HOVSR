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

% Last Modified by GUIDE v2.5 06-Dec-2017 16:31:09

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
set(handles.button_exportresults, 'String', lang{37});
set(handles.panel_acceleration_plots, 'Title', lang{3});
set(handles.panel_averagesv, 'Title', lang{4});
set(handles.panel_iteraciones, 'Title', lang{5});
set(handles.menu_file, 'Label', lang{33});
set(handles.menu_edit, 'Label', lang{34});
set(handles.menu_help, 'Label', lang{35});
set(handles.menu_close_app, 'Label', lang{2});
set(handles.menu_export_results, 'Label', lang{37});
set(handles.select_file, 'Label', lang{1});
set(handles.menu_manual, 'Label', lang{38});
set(handles.menu_about, 'Label', lang{39});
set(handles.new_project, 'Label', lang{36});

% Figures id's
setappdata(handles.root, 'figureid1', 1);
setappdata(handles.root, 'resultmsg', 0);

% Last folder opened
setappdata(handles.root, 'lasthandles_folder', '');
setappdata(handles.root, 'lastsave_folder', '');

% Results
setappdata(handles.root, 'results', false);
setappdata(handles.root, 'results_shsv', []);
setappdata(handles.root, 'results_f', []);

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


% --- Executes on button press in button_exportresults.
function button_exportresults_Callback(hObject, eventdata, handles) %#ok<*INUSD>
% hObject    handle to button_exportresults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of button_exportresults
export_results(handles, getappdata(handles.root, 'lang'));


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_manual_Callback(hObject, eventdata, handles)
% hObject    handle to menu_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
manual(getappdata(handles.root, 'lang'));


% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
about(getappdata(handles.root, 'lang'));


% --------------------------------------------------------------------
function new_project_Callback(hObject, eventdata, handles)
% hObject    handle to new_project (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clear_status(handles, getappdata(handles.root, 'lang'));


% --------------------------------------------------------------------
function menu_export_results_Callback(hObject, eventdata, handles)
% hObject    handle to menu_export_results (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
export_results(handles, getappdata(handles.root, 'lang'));


% --------------------------------------------------------------------
function menu_close_app_Callback(hObject, eventdata, handles)
% hObject    handle to menu_close_app (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close;


% --------------------------------------------------------------------
function menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function select_file_Callback(hObject, eventdata, handles)
% hObject    handle to select_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
start_process(handles, getappdata(handles.root, 'lang'));