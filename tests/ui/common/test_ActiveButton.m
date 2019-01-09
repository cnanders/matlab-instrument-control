try
    purge
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));

clock = mic.Clock('test');

uiButton = mic.ui.common.ActiveButton( ...
    'clock', clock, ...
    'cName', 'test', ...
    'fhOnClick', @() disp('clicked'), ...
    'fhGetColor', @() [1 0 0], ...
    'fhGetText', @() 'Button Test' ...
);
   
h = figure;
uiButton.build(h, 10, 10, 200, 24);


