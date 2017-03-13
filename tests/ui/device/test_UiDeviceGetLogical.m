[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));
purge

clock = mic.Clock('Master');

ui = mic.ui.device.GetLogical(...
    'clock', clock, ...
    'dWidthToggle', 100, ...
    'lShowLabels', false, ...
    'lShowInitButton', false, ...
    'cLabel', 'Diode In/Out' ...
);

h = figure();
ui.build(h, 10, 10);


 

