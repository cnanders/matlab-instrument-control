[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirMic));
purge


dPeriod = 0.1;
clock = mic.PClock('Master', dPeriod);



% Create some tasks:
taskA = mic.PClockTask('Task A', 'dPeriod', 1, 'cSource', 'Task A', 'cFn', @() disp('Task A'));
taskB = mic.PClockTask('Task B', 'dPeriod', 2, 'cSource', 'Task B', 'cFn', @() disp('Task B'));
taskC = mic.PClockTask('Task C', 'dPeriod', 1, 'cSource', 'Task C', 'cFn', @() disp('Task C'));


clock.add(taskA);
clock.add(taskB);
clock.add(taskC);

