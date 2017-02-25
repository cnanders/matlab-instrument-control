[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% mic library
cDirMic = fullfile(cDirThis, '..', '..', '..', 'pkg');
addpath(genpath(cDirMic));

% this application
cDirApp = fullfile(cDirThis, '..');
addpath(genpath(cDirApp));


purge

clock = mic.Clock('master');
vendorDevice = VendorDevice();

uiDeviceX = mic.ui.device.GetSetNumber( ...
    'cName', 'x', ...
    'clock', clock, ...
    'cLabel', 'x' ...
);

uiDeviceY = mic.ui.device.GetSetNumber( ...
    'cName', 'y', ...
    'clock', clock, ...
    'cLabel', 'y', ...
    'lShowLabels', false ...
);

getSetNumberX = VendorDevice2GetSetNumber(vendorDevice, 'x');
getSetNumberY = VendorDevice2GetSetNumber(vendorDevice, 'y');

uiDeviceX.setApi(getSetNumberX);
uiDeviceY.setApi(getSetNumberY);

h = figure();
uiDeviceX.build(h, 10, 10);
uiDeviceY.build(h, 10, 80);
