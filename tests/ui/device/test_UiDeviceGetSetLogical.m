[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));
purge

st1 = struct();
st1.lAsk        = false;
st1.cTitle      = 'Switch?';
st1.cQuestion   = 'Do you want to change from OFF to ON?';
st1.cAnswer1    = 'Yes of course!';
st1.cAnswer2    = 'No not yet.';
st1.cDefault    = st1.cAnswer2;

st2 = struct();
st2.lAsk        = false;
st2.cTitle      = 'Switch?';
st2.cQuestion   = 'Do you want to change from ON to OFF?';
st2.cAnswer1    = 'Yes of course!';
st2.cAnswer2    = 'No not yet.';
st2.cDefault    = st2.cAnswer2;

clock = mic.Clock('Master');

% Configure the mic.ui.common.Toggle instance
ceVararginCommandToggle = {...
    'stF2TOptions', st1, ...
    'stT2FOptions', st2 ...
    'cTextTrue', 'Remove', ...
    'cTextFalse', 'Insert' ...
};

ui = mic.ui.device.GetSetLogical(...
    'clock', clock, ...
    'ceVararginCommandToggle', ceVararginCommandToggle, ...
    'dWidthToggle', 100, ...
    'lShowLabels', true, ...
    'cLabel', 'Diode' ...
);

device = mic.device.GetSetLogical();

ui.setDevice(device);

h = figure();
ui.build(h, 10, 10);


 

