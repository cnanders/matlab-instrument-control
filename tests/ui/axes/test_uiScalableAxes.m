[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));
purge


h = figure( ...
    'Position', [20 20 900 900] ... % left bottom width height
);


sa = mic.ui.axes.ScalableAxes('hParentFigure', h);
sa.build(h,h, 200, 10, 500, 500);

sa.manny()
