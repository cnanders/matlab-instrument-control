[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% mic library
cDirMic = fullfile(cDirThis, '..', '..', 'pkg');
addpath(genpath(cDirMic));

% this application
cDirApp = fullfile(cDirThis, '..');
addpath(genpath(cDirApp));


purge

uiEdit = mic.ui.common.Edit(...
    'cLabel', 'Hello World' ...
);
uiToggle = mic.ui.common.Toggle();

h = figure();
uiEdit.build(h, 10, 10, 100, 30);
uiToggle.build(h, 10, 50, 100, 30);

% Get {char} value of uiEdit
uiEdit.get()

% Set {logical} value of uiToggle
uiToggle.get()


% Set {char} value of uiEdit
uiEdit.set('Hello');

% Set {logical} value of uiToggle
uiToggle.set(true);

