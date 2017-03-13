[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', '..', '..', 'src');
addpath(genpath(cDirMic));

purge

test = TestGetSetText();

h = figure();
test.build(h, 10, 10);


test.ui.setDest('dog')
test.ui.getDest()
test.ui.moveToDest()

test.ui.setDest('cat')
test.ui.getDest()
test.ui.moveToDest()



