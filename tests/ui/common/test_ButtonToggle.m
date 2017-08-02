[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure();
uiButtonToggle = mic.ui.common.ButtonToggle( ...
    'cTextF', 'Play', ...
    'cTextT', 'Pause', ...
    'lAsk', true ...
);


uiButtonToggle.build(h, 10, 10, 100, 30);

cb = @(src, evt) (fprintf('mic.ui.common.ButtonTogle eChange lVal = %1.0f\n', uiButtonToggle.get()));
addlistener(uiButtonToggle, 'eChange', cb);