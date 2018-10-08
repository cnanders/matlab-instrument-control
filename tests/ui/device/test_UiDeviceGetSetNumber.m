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
test.ui.moveToDest();


% test.ui.setUnit('um')
