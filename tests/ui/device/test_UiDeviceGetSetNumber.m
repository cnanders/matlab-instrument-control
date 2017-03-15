[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));
purge

test = TestGetSetNumber();

h = figure();
test.build(h, 10, 10);


test.ui.getUnit()
test.ui.setDestCal(15, 'nm')
test.ui.getDestCal('nm')
test.ui.setDestCal(92, 'eV')
test.ui.getDestCal('eV')

% test.ui.setUnit('um')

%{
clock = mic.Clock('master');   

cPathConfig = fullfile(...
    mic.Utils.pathConfig(), ...
    'config-default-offset.json' ...
);

config = mic.config.GetSet('cPathJson', cPathConfig);
cb = @(src, evt) (fprintf('validate dest\n'));

ui = mic.ui.device.GetSetNumber(...
    'cName', 'abc', ...
    'cLabel', 'abc', ...
    'clock', clock, ...
    'config', config, ...
    'lShowStores', true, ...
    'lShowUnit', true, ...
    'lShowInitButton', true, ...
    'lShowInitState', false, ...
    'lShowRange', true, ...
    'cConversion' , 'e', ... % exponential notaion
    'fhValidateDest', cb ...
);

h = figure();
ui.build(h, 10, 10);
%}
