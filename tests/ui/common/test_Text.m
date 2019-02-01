[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;

uiText = mic.ui.common.Text( ...
    'cLabel', 'Saved pos', ...
    'fhButtonDownFcn', @(src, evt) fprintf('clicked the mic.Text!\n'), ...
    'lShowLabel', true, ...
    'cType', 'd' ...
);

uiText.build(h, 10, 10, 100, 30);

uiText.setBackgroundColor([1 1 0]);

uiText.setColor([1 0 1]);
