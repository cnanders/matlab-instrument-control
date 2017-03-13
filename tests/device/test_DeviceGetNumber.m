[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirMic));
purge

clock = mic.Clock('master');
device = mic.device.GetNumber(...
    'cName', 'Test', ...
    'dMean', 10, ...
    'clock', clock ...
);


