[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;

ui = mic.ui.common.Edit( ...
    'cLabel', 'Saved pos', ...
    'cType', 'd' ...
);

ui.build(h, 10, 10, 100, 30);

cbEnter = @(src, evt) (fprintf('eEnter callback ui.get() = %1.2f\n', ui.get()));
addlistener(ui, 'eEnter', cbEnter);


cbChange = @(src, evt) (fprintf('eChange callback ui.get() = %1.2f\n', ui.get()));
addlistener(ui, 'eEnter', cbChange);