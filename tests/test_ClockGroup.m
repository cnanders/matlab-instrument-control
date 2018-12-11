[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirMic));
purge

clock = mic.Clock('Master');

clockGroupA = mic.ClockGroup(clock);
clockGroupB = mic.ClockGroup(clock);


clockGroupA.add(@()disp('A1'), 'A1', 0.5);
clockGroupA.add(@()disp('A2'), 'A2', 0.5);

clockGroupB.add(@()disp('B1'), 'B1', 0.5);
clockGroupB.add(@()disp('B2'), 'B2', 0.5);