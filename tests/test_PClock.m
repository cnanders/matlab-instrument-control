[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirMic));
purge


dPeriod = 0.1;
clock = mic.PClock('Master', dPeriod);



% Create some tasks:
taskA = mic.PClockTask('Task A', 'dPeriod', 1, 'cSource', 'Task A', 'hFn', @() disp('Task A'));
taskB = mic.PClockTask('Task B', 'dPeriod', 2, 'cSource', 'Task B', 'hFn', @() disp('Task B'));
taskC = mic.PClockTask('Task C', 'dPeriod', 1, 'cSource', 'Task C', 'hFn', @() disp('Task C'));


clock.addTask(taskA);
clock.addTask(taskB);
clock.addTask(taskC);

%%

% Try removing tasks:
clock.removeTask(taskA);