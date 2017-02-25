[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', 'pkg');
addpath(genpath(cDirMic));
purge

device = mic.device.GetText();


