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

uiDeviceMode = mic.ui.device.GetText( ...
    'clock', clock, ...
    'cName', 'mode', ...
    'cLabel', 'mode', ...
    'lShowLabels', false ...
);

getSetNumberX = VendorDevice2GetSetNumber(vendorDevice, 'x');
getSetNumberY = VendorDevice2GetSetNumber(vendorDevice, 'y');
getTextMode = VendorDevice2GetText(vendorDevice, 'mode');

uiDeviceX.setDevice(getSetNumberX);
uiDeviceY.setDevice(getSetNumberY);
uiDeviceMode.setDevice(getTextMode);

h = figure();
uiDeviceX.build(h, 10, 10);
uiDeviceY.build(h, 10, 80);
uiDeviceMode.build(h, 10, 130);
