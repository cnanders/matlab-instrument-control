[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirMic));
purge

device = mic.device.GetSetText();
device.set('car')
device.get()