[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'pkg');
addpath(genpath(cDirMic));
purge

ui = mic.ui.common.ProgressBar();

h = figure();
ui.build(h, 10, 10);
ui.setProgress(0.2)

