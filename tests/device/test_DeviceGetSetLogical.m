[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirMic));
purge

device = mic.device.GetSetLogical();
device.set(false)
device.get()

device.set(true)
device.get()