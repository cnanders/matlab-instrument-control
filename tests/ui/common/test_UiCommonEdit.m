[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;

uiEdit = mic.ui.common.Edit( ...
    'cLabel', 'Saved pos', ...
    'cType', 'd' ...
);

uiEdit.build(h, 10, 10, 100, 30);

cb = @(src, evt) (fprintf('pressed enter %1.2f\n', uiEdit.get()));
addlistener(uiEdit, 'eEnter', cb);


