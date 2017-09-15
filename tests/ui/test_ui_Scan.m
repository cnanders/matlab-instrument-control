[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));

% src
cDirSrc = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirSrc));

purge

ui = mic.ui.Scan();

h = figure;

st = struct();
st.cStatus = 'Scanning (20%)';
st.cTimeElapsed = '00:00:02';
st.cTimeRemaining = '00:00:34';
st.cTimeComplete = '13:34:02';

ui.build(h, 10, 10);
ui.setStatus(st)


cbAbort = @(src, evt) (fprintf('eAbort\n'));
cbPause = @(src, evt) (fprintf('ePause\n'));
cbResume = @(src, evt) (fprintf('eResume\n'));
cbStart = @(src, evt) (fprintf('eStart\n'));

addlistener(ui, 'eAbort', cbAbort);
addlistener(ui, 'eStart', cbStart);
addlistener(ui, 'ePause', cbPause);
addlistener(ui, 'eResume', cbResume);


