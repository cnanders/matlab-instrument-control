% purge

[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
% Add mic
addpath(genpath(cDirMic));


h = figure;

ui = mic.ui.common.ListDir(...
    'cDir', fullfile(cDirThis, 'ui-list-dir-save'), ...
    'cFilter', '*.mat', ...
    'lShowLabel', false, ...
    'lShowChooseDir', true, ...
    'cTitle', 'List 1', ...
    'cLabel', 'Hello, World!' ...
);

ui.build(h, 10, 10, 550, 180);


ui2 = mic.ui.common.ListDir(...
    'cDir', fullfile(cDirThis, 'ui-list-dir-save'), ...
    'cFilter', '*.mat', ...
    'lShowLabel', false, ...
    'lShowChooseDir', false, ...
    'cTitle', 'List 2', ...
    'cLabel', 'Hello, World!' ...
);

ui2.build(h, 10, 220, 550, 180);



% Define callback functions

%{
onRefresh = @(src, evt) ({'bob', 'dave', 'joel', 'chris'});
onDelete = @(src, evt) (evt.stData.ceOptions);

addlistener(ui, 'eDelete', onDelete);
ui.setRefreshFcn(onRefresh);
%}


