[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));
purge

clock = mic.Clock('Master');

ui = mic.ui.device.GetText(...
    'clock', clock, ...
    'lShowLabels', false, ...
    'lShowInitButton', true, ...
    'cLabel', 'State' ...
);

h = figure();
ui.build(h, 10, 10);


 

