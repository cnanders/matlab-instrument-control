try
    purge
end


[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirMic = fullfile(cDirThis, '..', 'src');
addpath(genpath(cDirMic));


clock = mic.Clock('Master');

uiA = mic.ui.device.GetSetNumber('clock', clock, 'cName', 'A');
uiB = mic.ui.device.GetSetNumber('clock', clock, 'cName', 'B');
uiC = mic.ui.device.GetSetNumber('clock', clock, 'cName', 'C');
uiD = mic.ui.device.GetSetNumber('clock', clock, 'cName', 'D');
h = figure;
uiA.build(h, 10, 10);
uiB.build(h, 10, 50);
uiC.build(h, 10, 100);
uiD.build(h, 10, 200);


% Create a list of three states

states = {...
    mic.StateFromUiGetSetNumber(uiA, 5, 0.1, uiA.getUnit().name), ...
    mic.StateFromUiGetSetNumber(uiB, 100, 0.1, uiB.getUnit().name) ...
    mic.StateFromUiGetSetNumber(uiC, 20, 0.1, uiC.getUnit().name) ...
};


% Alternatively (DOES NOT WORK, can't get lambda working in Static

%{
states = {...
    mic.State.fromUiGetSetNumber(uiA, 5, 0.1, uiA.getUnit().name), ...
    mic.State.fromUiGetSetNumber(uiB, 100, 0.1, uiB.getUnit().name) ...
    mic.State.fromUiGetSetNumber(uiC, 20, 0.1, uiC.getUnit().name) ...
};
%}

% This sequence is itself a "state" since it implements mic.interface.State
% Uses mic.Scan under the hood to implement go()
state = mic.StateSequence(...
    'clock', clock, ...
    'ceStates', states, ...
    'dPeriod', 0.5, ...
    'cName', 'Scan A + B + C' ...
);


% state.go();


state2 = mic.StateSequence(...
    'clock', clock, ...
    'ceStates', {...
        mic.StateFromUiGetSetNumber(uiD, 30, 0.1, uiD.getUnit().name), ...
        state ...
    }, ...
    'dPeriod', 0.5, ...
    'cName', 'ABCD' ...
);

state2.go();

