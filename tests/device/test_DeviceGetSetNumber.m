[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', 'pkg');
addpath(genpath(cDirMic));
purge

clock = mic.Clock('master');
device = mic.device.GetSetNumber(...
    'cName', 'Test', ...
    'clock', clock ...
);