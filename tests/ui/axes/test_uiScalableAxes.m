[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));
purge


h = figure( ...
    'Position', [20 20 750 750] ... % left bottom width height
);


sa = mic.ui.axes.ScalableAxes();
sa.build(h, 10, 10, 700, 700);

sa.manny()
