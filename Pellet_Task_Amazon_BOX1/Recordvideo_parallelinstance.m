function [] = parallelinstance (fakevideo_number,fakename,fakeday)
% Create project directory with name and day
project_dir = strcat('C:\Users\imorozov\Documents\MATLAB\Pellet_Task_Amazon_BOX1\', fakename, '_', fakeday);
if ~exist(project_dir, 'dir')
    mkdir(project_dir)
end
% create command
% -sd(set directory), pwd(current directory), -r(run function)...
% finally "&" to indicate background computation
command = strcat('matlab -cd ',project_dir,{' '}, pwd,{' '},'-r "Recordvideo(',num2str(fakevideo_number),')" -nodesktop -nosplash &');
% disp(command)
% call command
system(command{1}); 
end