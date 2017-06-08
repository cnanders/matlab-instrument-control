purge


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
% Add mic
addpath(genpath(cDirMic));


h = figure;

ui = mic.ui.common.ListDir(...
    'cDir', fullfile(cDirThis, 'ui-list-dir-save'), ...
    'cFilter', '*.mat', ...
    'lShowLabel', false, ...
    'lShowChooseDir', false, ...
    'cLabel', 'Hello, World!' ...
);

ui.build(h, 10, 10, 550, 100);

% Define callback functions

%{
onRefresh = @(src, evt) ({'bob', 'dave', 'joel', 'chris'});
onDelete = @(src, evt) (evt.stData.ceOptions);

addlistener(ui, 'eDelete', onDelete);
ui.setRefreshFcn(onRefresh);
%}


