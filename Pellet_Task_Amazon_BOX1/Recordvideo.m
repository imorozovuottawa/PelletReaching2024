function [] = processvideo(fakevideo_number)
%% Change fakename and fakeday 
% note for Xuming from Nate: 
% XYZ04 is unmarked and goes on bottom rw (this one)
% XYZ06 is black and "                             "
vlog = tic;
fakename = 'test';
fakeday  = '1';
closepreview 

%% Create project directory with name and day
project_dir = strcat('C:\Users\imorozov\Documents\MATLAB\Pellet_Task_Amazon_BOX1\', fakename, '_', fakeday);
if ~exist(project_dir, 'dir')
    mkdir(project_dir)
end
timenow = datestr(now,'yymmdd_hhMMss.FFF');
name_of_video = strcat(project_dir, '\', fakename, '_', fakeday ,'_camera_1_',timenow, '.mp4');
str = strcat(project_dir, '\', fakename, '_', fakeday ,'_camera_1_',timenow,'.mat');
%% Construct a video input object
vobj = videoinput('winvideo', fakevideo_number , 'MJPG_640x480');
vobj.ROIPosition = [0 0 352 260];
vobj.ReturnedColorspace = 'grayscale';
%% Set Properties for Videoinput Object
vobj.TimeOut = Inf;
vobj.FrameGrabInterval = 1;
vobj.LoggingMode = 'disk';
vobj.FramesPerTrigger = Inf;
vobj.TriggerRepeat = Inf;
vobj.ReturnedColorSpace = 'grayscale';

%% Construct VideoWriter object and set Disk Logger Property
v = VideoWriter(name_of_video,'MPEG-4');
v.Quality = 75;
v.FrameRate = 120.1014;
vobj.DiskLogger = v;
%% Select the source to use for acquisition.
vobj.SelectedSourceName = 'input1';
vobj_Start = datestr(now,'yymmdd_hhMMss.FFF'); 
vlogTime = toc(vlog);
vStart = tic;
start(vobj)
%% Select time in min for duration of Video
%faketime = 1;% time in min
faketime = 40;% time in min
pause(60*faketime)% time in sec

%% Stop Video recording
stop(vobj);
vobj_Stop = datestr(now,'yymmdd_hhMMss.FFF'); 
elapsedTime = toc(vStart);
framesaq = vobj.FramesAcquired;
ActualFR = framesaq/elapsedTime;

%% Delete Object
delete(vobj); 

%% Save 
save(str,'name_of_video','elapsedTime','framesaq','ActualFR','vobj_Start','vobj_Stop','vlogTime');%Save matlab workspace
pause(5)
exit 

end