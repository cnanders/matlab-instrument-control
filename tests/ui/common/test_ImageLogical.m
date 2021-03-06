[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge;

ui = mic.ui.common.ImageLogical();

h = figure;
ui.build(h, 10, 10);
ui.set(true);
ui.set(false);
