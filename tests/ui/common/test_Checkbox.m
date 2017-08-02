[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure;

ui = mic.ui.common.Checkbox( ...
    'lChecked', true ...
);

ui.build(h, 10, 10, 100, 30);

cecLogical = {'false' 'true'};
cb = @(src, evt) (...
    fprintf(...
        'mic.ui.common.ButtonTogle eChange lVal = %s\n', ...
        cecLogical{ui.get() + 1} ...
    )...
);
addlistener(ui, 'eChange', cb);


