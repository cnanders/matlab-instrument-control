[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;

ui = mic.ui.common.ScanAxisSetup();

ui.build(h, 10, 50);
