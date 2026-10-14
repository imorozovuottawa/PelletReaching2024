function [s,flag] = setupSerial(comPort)
% Initialize the serial port communication between Arduino and MATLAB
% We ensure that the arduino is also communicatiing with MATLAB at this 
% time. A predefined code on the arduino acknowledges this.
% if setup is complete the value of setup is returned as 1 else 0

flag = 1;

s = serial(comPort);
set(s,'DataBits', 8);
set(s, 'StopBits', 1);
set(s,'BaudRate', 9600);
set(s,'Parity', 'none');
fopen(s);
a = 'b';
while(a ~= 'a')
    a = fread(s,1,'char');
end
if (a == 'a')
    disp('Serial Read');
end
    fprintf(s,'%c','a');
    disp('Serial Communication Setup');
    %mbox= msgbox('Serial Communication setup.'); uiwait(mbox);
    %fscanf(s,'%u');
end
    