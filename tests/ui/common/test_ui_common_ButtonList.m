[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));


ui = mic.ui.common.ButtonList(...
    'cLayout', mic.ui.common.ButtonList.cLAYOUT_INLINE, ...
    'dWidthButton', 80 ...
);

h = figure();
ui.build(h, 10, 10);


 

