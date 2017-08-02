[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));
purge

ui = mic.ui.common.ProgressBar();

h = figure();
ui.build(h, 10, 10);
ui.set(0.2)
ui.get()