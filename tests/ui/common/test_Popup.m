[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge;

h = figure;

ui = mic.ui.common.Popup( ...
    'ceOptions', {'Val 1' 'Val 2'}, ...
    'cLabel', 'Blah' ...
);

ui.build(h, 10, 10, 100, 30);

cb = @(src, evt) (fprintf('mic.ui.common.Popup eChange to item %1d\n', src.getSelectedIndex()));
addlistener(ui, 'eChange', cb);