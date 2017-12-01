[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;

ui = mic.ui.common.ScanSetup( ...
    'cLabel', 'Saved pos', ...
    'dScanAxes', 3, ...
    'cName', '3dscan', ...
    'cConfigPath', 'scan-axis-save'...
);

ui.build(h, 10, 10, 850, 210);
