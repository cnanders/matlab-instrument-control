[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');

% Add mic
addpath(genpath(cDirMic));

purge

h = figure();


st1 = struct();
st1.lAsk        = true;
st1.cTitle      = 'Switch?';
st1.cQuestion   = 'Do you want to change from true to false?';
st1.cAnswer1    = 'Yes of course!';
st1.cAnswer2    = 'No not yet.';
st1.cDefault    = st1.cAnswer2;


st2 = struct();
st2.lAsk        = true;
st2.cTitle      = 'Switch?';
st2.cQuestion   = 'Do you want to change from true to false?';
st2.cAnswer1    = 'Yes of course!';
st2.cAnswer2    = 'No not yet.';
st2.cDefault    = st2.cAnswer2;

%{
ui = UIToggle( ...
    'Play', ...
    'Pause', ...
    false, ...
    uint8(0), ...
    uint8(0), ...
    st1, ...
    st2);
%}

ui = mic.ui.common.Toggle( ...
    'cTextTrue', 'Play', ...
    'cTextFalse', 'Pause', ...
    'stT2FOptions', st2 ...
);

fhOnChange = @(src, evt) disp('change');
addlistener(ui, 'eChange', fhOnChange);
ui.build(h, 10, 10, 100, 30);




