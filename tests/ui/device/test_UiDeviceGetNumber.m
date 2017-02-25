[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'pkg');
addpath(genpath(cDirMic));
purge

test = TestGetNumber();

h = figure();
test.build(h, 10, 10);
