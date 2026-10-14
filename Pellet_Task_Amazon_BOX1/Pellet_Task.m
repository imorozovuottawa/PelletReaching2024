
function varargout = Pellet_Task(varargin)
% PELLET_TASK MATLAB code for P the handle to a new PELLET_TASK or the handle to
%      the existing singleton*.
%
%      PELLET_TASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PELLET_TASK.M with the given input arguments.
%
%      PELLET_TASK('Proper                                                         ty','Value',...) creates a new PELLET_TASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Pellet_Task_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Pellet_Task_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Pellet_Task

% Last Modified by GUIDE v2.5 11-Jun-2019 12:04:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Pellet_Task_OpeningFcn, ...
                   'gui_OutputFcn',  @Pellet_Task_OutputFcn, ...
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


% --- Executes just before Pellet_Task is made visible.
function Pellet_Task_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Pellet_Task (see VARARGIN)

% Choose default command line output for Pellet_Task
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Pellet_Task wait for user response (see UIRESUME)
% uiwait(handles.figure1);
clear comPort;
global out_s;
global Mouse_Name;
global numClicks;
global UP_TIME;
global DOWN_TIME;
global PLAY_TIME;
global TOTAL_TIME;
global Test_Time;
global up_flag;
global vobj;
global X_Offset;
global Y_Offset;
global data_path;
global Training_Day

data_path = 'C:\Users\imorozov\Documents\MATLAB\Pellet_Task_Amazon_BOX1\';
comPort = 'COM5';
[s,flag] = setupSerial(comPort);
out_s = s;

Mouse_Name = 'TEST';
numClicks = 15;
UP_TIME = 30;
DOWN_TIME = 5;
PLAY_TIME = 1;
Training_Day = 1;

TOTAL_TIME = 60;
Test_Time = 1;
up_flag = 0; % flag motor arm up

% --- Outputs from this function are returned to the command line.
function varargout = Pellet_Task_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
% hObject    handle to START (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out_s;
global data_path;
global Mouse_Name;
global UP_TIME;
global DOWN_TIME;
global PLAY_TIME;
global TOTAL_TIME;
global vobj;
global X_Offset;
global Y_Offset;
global project_folder;
global numClicks;
global Training_Day
closepreview 
X_Offset = str2double(get(handles.edit_X_Offset,'String'));
Y_Offset = str2double(get(handles.edit_Y_Offset,'String'));

timenow = datestr(now,'yymmdd_hhMMss.FFF');
%Start Time
Start_Time = timenow;

Training_Day = get(handles.edit_Training_Day,'String');
project_folder = [Mouse_Name '_' Training_Day];
% if ~exist(project_folder, 'dir')
%     mkdir(project_folder)
% end

set(handles.STOP, 'userdata', 0);

i = 1;% counter of Total Events
t_Total_Time = 0;
data_trail = [];

out_mode = 'B';
% Serial send read request to Arduino - Start Motor Rotation DOWN
fprintf(out_s, out_mode); 
pause(DOWN_TIME);

disp ('FOOD Training START!');
disp('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
disp(' ');
Recordvideo_tStart = datestr(now,'yymmdd_hhMMss.FFF'); 
Recordvideo_parallelinstance(1,Mouse_Name,Training_Day);% Record Videos for Camera 4 
pause(11);% delay to start - align with start video - Recordvideo.m - start(vobj)
while i <= numClicks 
    tStart = tic;  % TIC
    Trail_tStart = datestr(now,'yymmdd_hhMMss.FFF'); 
    data_trail(i).Start_Time = Trail_tStart;
    disp (['TRAIL# ', num2str(i),'--> Start Time: ',num2str(Trail_tStart) ] );
    
    t_TONE = datestr(now,'yymmdd_hhMMss.FFF'); 
    data_trail(i).TONE = t_TONE;
    disp (['TRAIL# ', num2str(i) ' --> Play Music: ',num2str(t_TONE )]);
    
    out_mode = 'P';
    % Serial send read request to Arduino - Play Music
    fprintf(out_s, out_mode);
    pause(PLAY_TIME);
    out_mode = 'S';
    % Serial send read request to Arduino - Stop Playing Music
    fprintf(out_s, out_mode); 
    
    % MOTOR ARM UP
    t_MUP = datestr(now,'yymmdd_hhMMss.FFF');
    disp (['TRAIL# ', num2str(i),'--> MOTOR ARM UP: ',num2str(t_MUP) ]);
    data_trail(i).MUP = t_MUP;
    
    out_mode = 'A';
    % Serial send read request to Arduino - Start Motor Rotation UP
    fprintf(out_s, out_mode); 
    pause(UP_TIME);
    
    % MOTOR ARM DOWN
    t_MDOWN = datestr(now,'yymmdd_hhMMss.FFF'); 
    disp (['TRAIL# ', num2str(i),'--> MOTOR ARM DOWN: ',num2str(t_MDOWN) ]);
    data_trail(i).MDOWN = t_MDOWN;  
    
    out_mode = 'B';
    % Serial send read request to Arduino - Start Motor Rotation DOWN
    fprintf(out_s, out_mode); 
    pause(DOWN_TIME);
   
    tStop = toc(tStart);  % TOC in sec
    data_trail(i).Trail_Time_sec = tStop;       
    t_Total_Time = t_Total_Time + tStop; % Total time in sec
    data_trail(i).Total_Time_min = t_Total_Time/60; % Total time in min
    disp (['TRAIL# ', num2str(i) ' --> Trail Time =  ', num2str(tStop,'%.2f') '(sec) & Total Time =  ', num2str((t_Total_Time/60),'%.2f') '(min)'] );

    i = i + 1;
    
    if  get(handles.STOP, 'userdata') % stop condition
        break;
    end

    if  (t_Total_Time/60) >= TOTAL_TIME % stop condition
        break;
    end    
end

disp (['FOOD Training End!', 'NUMBER OF TRAILS : ', num2str(i-1) ' --> Total Time =  ', num2str((t_Total_Time/60),'%.2f') '(min)'] );
disp('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
disp(' ');

numTrails = numClicks;
Total_Time = t_Total_Time/60; % in min

filename = strcat(data_path, project_folder, '\', project_folder, '_Data_' ,Start_Time ,'.mat');%String to save matlab file to .mat
save(filename,'Training_Day','Mouse_Name','Recordvideo_tStart','Start_Time','numTrails','Total_Time','data_trail');

% --- Executes on button press in STOP.
function STOP_Callback(hObject, eventdata, handles)
% hObject    handle to STOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.STOP,'userdata',1)

% --- Executes on button press in EXIT.
function EXIT_Callback(hObject, eventdata, handles)
% hObject    handle to EXIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
closeSerial

function edit_Mouse_Name_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Mouse_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Mouse_Name as text
%        str2double(get(hObject,'String')) returns contents of edit_Mouse_Name as a double
global Mouse_Name;
%Name of Mouse
Mouse_Name = get(handles.edit_Mouse_Name, 'String');

% --- Executes during object creation, after setting all properties.
function edit_Mouse_Name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Mouse_Name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in PLAY.
function PLAY_Callback(hObject, eventdata, handles)
% hObject    handle to PLAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out_s;
global PLAY_TIME;

%set(handles.STOP,'userdata',1)
disp ('TEST SOUND ');

out_mode = 'P';
% Serial send read request to Arduino - Play Music
fprintf(out_s, out_mode); 

pause(PLAY_TIME);  

out_mode = 'S';
% Serial send read request to Arduino - Stop Playing Music
fprintf(out_s, out_mode); 

pause(1);  
     


% --- Executes on button press in UP.
function UP_Callback(hObject, eventdata, handles)
% hObject    handle to UP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out_s;
global PLAY_TIME;
global up_flag;
global  Test_Time;

if up_flag == 0
    
    up_flag = 1;% flag motor arm down
    
    disp ('TEST SOUND ');   
    
    tStart = tic;  
    
    out_mode = 'P';
    % Serial send read request to Arduino - Play Music
    fprintf(out_s, out_mode); 
    
    tStop = toc(tStart);
%     disp (['TEST PLAY SOUND TIME: ' num2str(tStop)]); 
    
    pause(PLAY_TIME);  
    
    tStart = tic;  

    out_mode = 'S';
    % Serial send read request to Arduino - Stop Playing Music
    fprintf(out_s, out_mode); 
    
    tStop = toc(tStart);
%     disp (['TEST STOP SOUND TIME: ' num2str(tStop)]); 
    
    % DOWN
    disp ('TEST MOTOR ARM DOWN');
    
    tStrat = tic;
    
    out_mode = 'B';
    % Serial send read request to Arduino - Start Motor Rotation DOWN
    fprintf(out_s, out_mode); 
    
    tStop = toc(tStart);   
%     disp (['TEST MOTOR ARM DOWN: ' num2str(tStop)]); 
    
    %UP   
    disp ('TEST MOTOR UP');  
    
    tStrat = tic;  
    
    out_mode = 'A';
    % Serial send read request to Arduino - Start Motor Rotation UP
    fprintf(out_s, out_mode); 
    
    tStop = toc(tStart);
%     disp (['TEST MOTOR ARM UP: ' num2str(tStop)]); 
    
    pause(Test_Time);
    up_flag = 0;% flag motor arm up

elseif up_flag == 1
    
    disp ('TEST SOUND ');
    
    tStart = tic;
    
    out_mode = 'P';
    % Serial send read request to Arduino - Play Music
    fprintf(out_s, out_mode); 
    
    tStop = toc(tStart);
%     disp (['TEST PLAY SOUND TIME: ' num2str(tStop)]);

    pause(PLAY_TIME); 
    
    tStart = tic;
    
    out_mode = 'S';
    % Serial send read request to Arduino - Stop Playing Music
    fprintf(out_s, out_mode); 
    
    tStop = toc(tStart);
%     disp (['TEST STOP SOUND TIME: ' num2str(tStop)]); 

    %UP   
    disp ('TEST MOTOR UP');
    
    tStrat = tic; 
    
    out_mode = 'A';
    % Serial send read request to Arduino - Start Motor Rotation UP
    fprintf(out_s, out_mode);
    
    tStop = toc(tStart);
%     disp (['TEST MOTOR UP: ' num2str(tStop)]);  
    
    pause(Test_Time);   
    up_flag = 0;% flag motor arm up
end
 
function Test_Time_Callback(hObject, eventdata, handles)
% hObject    handle to Test_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Test_Time as text
%        str2double(get(hObject,'String')) returns contents of Test_Time as a double
global Test_Time;
%Test_Time
Test_Time = str2double(get(handles.Test_Time,'String'));

% --- Executes during object creation, after setting all properties.
function Test_Time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Test_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_Trails_Numbers_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Trails_Numbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Trails_Numbers as text
%        str2double(get(hObject,'String')) returns contents of edit_Trails_Numbers as a double
global numClicks;
%Trails Numbers
numClicks = str2double(get(handles.edit_Trails_Numbers,'String'));

% --- Executes during object creation, after setting all properties.
function edit_Trails_Numbers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Trails_Numbers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_UP_TIME_Callback(hObject, eventdata, handles)
% hObject    handle to edit_UP_TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_UP_TIME as text
%        str2double(get(hObject,'String')) returns contents of edit_UP_TIME as a double
global UP_TIME;
%Motor up time
UP_TIME = str2double(get(handles.edit_UP_TIME,'String'));

% --- Executes during object creation, after setting all properties.
function edit_UP_TIME_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_UP_TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_DOWN_TIME_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DOWN_TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_DOWN_TIME as text
%        str2double(get(hObject,'String')) returns contents of edit_DOWN_TIME as a double
global DOWN_TIME;
%Motor down time
DOWN_TIME = str2double(get(handles.edit_DOWN_TIME,'String'));

% --- Executes during object creation, after setting all properties.
function edit_DOWN_TIME_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DOWN_TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_PLAY_TIME_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PLAY_TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PLAY_TIME as text
%        str2double(get(hObject,'String')) returns contents of edit_PLAY_TIME as a double
global PLAY_TIME;
%Duration of sound when pellet holder UP
PLAY_TIME = str2double(get(handles.edit_PLAY_TIME,'String'));

% --- Executes during object creation, after setting all properties.
function edit_PLAY_TIME_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PLAY_TIME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Total_Time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Total_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Total_Time as text
%        str2double(get(hObject,'String')) returns contents of edit_Total_Time as a double
global TOTAL_TIME;
%Total Time of experiment
TOTAL_TIME = str2double(get(handles.edit_Total_Time,'String'));


% --- Executes during object creation, after setting all properties.
function edit_Total_Time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Total_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DOWN.
function DOWN_Callback(hObject, eventdata, handles)
% hObject    handle to DOWN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global out_s;
global up_flag;

if up_flag == 0
    
    up_flag = 1;% flag motor arm down
    
    % DOWN
    disp ('TEST MOTOR DOWN');
    
    tStart = tic;
    
    out_mode = 'B';
    % Serial send read request to Arduino - Start Motor Rotation DOWN
    fprintf(out_s, out_mode); 

    tStop = toc(tStart);
%     disp (['TEST MOTOR DOWN TIME:' num2str(tStop)]);
    
end


function edit_Test_Time_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Test_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Test_Time as text
%        str2double(get(hObject,'String')) returns contents of edit_Test_Time as a double
global Test_Time;
%Test_Time
Test_Time = str2double(get(handles.edit_Test_Time,'String'));

% --- Executes during object creation, after setting all properties.
function edit_Test_Time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Test_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Video_Preview.
function Video_Preview_Callback(hObject, eventdata, handles)
% hObject    handle to Video_Preview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Preview a stream of image frames.
global vobj;
global X_Offset
global Y_Offset
closepreview 
X_Offset = str2double(get(handles.edit_X_Offset,'String'));
Y_Offset = str2double(get(handles.edit_Y_Offset,'String'));
vobj = videoinput('winvideo', 1, 'MJPG_640x480');
vobj.ROIPosition = [X_Offset Y_Offset 352 260];
vobj.ReturnedColorspace = 'grayscale';
preview(vobj);
    
function edit_X_Offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_X_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_X_Offset as text
%        str2double(get(hObject,'String')) returns contents of edit_X_Offset as a double

global X_Offset
closepreview
X_Offset = str2double(get(handles.edit_X_Offset,'String'));

% --- Executes during object creation, after setting all properties.
function edit_X_Offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_X_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Y_Offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Y_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Y_Offset as text
%        str2double(get(hObject,'String')) returns contents of edit_Y_Offset as a double
global Y_Offset
closepreview
Y_Offset = str2double(get(handles.edit_Y_Offset,'String'));

% --- Executes during object creation, after setting all properties.
function edit_Y_Offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Y_Offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Training_Day_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Training_Day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Training_Day as text
%        str2double(get(hObject,'String')) returns contents of edit_Training_Day as a double
global Training_Day
Training_Day = get(handles.edit_Training_Day,'String');

% --- Executes during object creation, after setting all properties.
function edit_Training_Day_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Training_Day (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
