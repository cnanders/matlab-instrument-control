[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;

uiCheckbox = mic.ui.common.Checkbox( ...
    'lChecked', true ...
);

uiCheckbox.build(h, 10, 10, 100, 30);

cecLogical = {'false' 'true'};
cb = @(src, evt) (...
    fprintf(...
        'mic.ui.common.ButtonTogle eChange lVal = %s\n', ...
        cecLogical{uiCheckbox.get() + 1} ...
    )...
);
addlistener(uiCheckbox, 'eChange', cb);


