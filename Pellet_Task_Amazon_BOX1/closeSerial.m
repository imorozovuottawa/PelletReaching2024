clc
clear all
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
closepreview
close all
clc
disp('Serial Port Closed')