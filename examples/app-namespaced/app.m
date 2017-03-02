[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% mic library
cDirMic = fullfile(cDirThis, '..', '..', 'pkg');
addpath(genpath(cDirMic));

% this application
cDirApp = fullfile(cDirThis, '..');
addpath(genpath(cDirApp));

purge

exampleApp = ExampleDeviceApp();

% STUFF TO TRY
%{

uiDeviceX.turnOn()
uiDeviceX.turnOff()
uiDeviceX.disable()

uiDeviceX.setDestCal(5, 'mm')
uiDeviceX.moveToDest()


%}
