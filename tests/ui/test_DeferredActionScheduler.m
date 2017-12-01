% Demonstrates the use of DeferredActionScheduler.  This class deferrs the
% execution of an "action" until a "trigger condition" is met.  This is useful when
% we need to wait for the completion of some asynchronous event (e.g., stage moving,
% stage homing) before executing subsequent actions.
%
% Instantiate a DeferredActionScheduler with function handle properties: 
% fhTrigger: function that evaluates to true when a condtion is met
% fhAction: function to be executed when trigger evaluates to true
% clock: uses internal clock if this parameter is empty
% dDelay: how often to check fhTrigger

function test_DeferredActionScheduler
% Set path
[cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
cDirSrc = fullfile(cDirThis, '..', '..', 'src');
addpath(genpath(cDirSrc));

% Set up figure and clock
hFig = figure;
clock = mic.Clock('DAS', 0.1);
tStart = tic;

% Rainbow colors
figureColors = {[1 0 0], [1 .5 0], [1 1 0], [0 1 0],  [0 0 1], [1 0 .5]};

% This button initializes the DAS instance
uibStartTrigger = mic.ui.common.Button('cText', 'Stop and notify when blue', 'fhDirectCallback', @()startDAS(clock, hFig));
uibStartTrigger.build(hFig, 10, 10, 250, 50);

% Switch figure colors from red to purple on loop once a second
clock.add(@() set(hFig, 'Color', figureColors{mod(floor(toc(tStart)), 6) + 1}), 'colorSwitcher', 1);
clock.start();
end

    
function startDAS(clock, hFig)
    % Define trigger:
    checkIfFigureIsBlue = @() all(hFig.Color == [0 0 1]);

    %Create a DAS instance
    DAS = mic.DeferredActionScheduler('fhTrigger', checkIfFigureIsBlue,...
                                        'fhAction', @() StopAndNotifyThatFigureIsBlue(clock), ...
                                        'clock', clock, ...
                                        'dDelay', 0.5);
    % Call "dispatch" to start watching
    DAS.dispatch();
end

function StopAndNotifyThatFigureIsBlue(clock)
    clock.stop();
    msgbox('Figure is blue')
end
