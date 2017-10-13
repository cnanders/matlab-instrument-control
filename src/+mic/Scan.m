classdef Scan < mic.Base
    
    % Event-based class that scans a system through a list of states.  One
    % constraint is that the scan must use the the same units for every
    % state.
    %
    % You can imagine passing in a list of states that looks like this
    % (assumes two degrees of control, x and y) (JSON):
    %
    %   [
    %       {
    %           "x": {
    %               "value": 1,
    %               "unit": "mm"
    %           },
    %           "y": {
    %               "value": 1,
    %               "unit": "mm"
    %           }
    %       },xzds1
    %       {
    %           "x": {
    %               "value": 2,
    %               "unit": "mm"
    %           },
    %           "y": {
    %               "value": 1,
    %               "unit": "mm"
    %           }
    %       }
    %   ]
    %
    % where the unit is stored along with the val of every property of
    % every state.  This would be OK, but it is easier to read if instead
    % the units are declared at the top and the states only contain the
    % values.  This also implicitly constrains the scan to not changing
    % units midway which is a good thing (imagine plotting a scan result
    % where the units changed midway).  Here is an example.
    %
    %   {
    %       "unit": {
    %           "x": "mm",
    %           "y": "mm"
    %       },
    %       "values": [
    %           {
    %               "x": 1,
    %               "y": 1
    %           },    
    %           {
    %               "x": 2,
    %               "y": 1
    %           }
    %       ]
    %   }
    %
    % this will be referred to as a "recipe" for the scan.  It defines the
    % unit structure and a list of state value structures
    %
    % The parent that instantiantes this Scan instance produces and
    % consumes the recipe, including the unit definition and each state definition.
    % recipe.unit and recipe.values[n] will be passed to each call
    % to setState() isAtState().
    %
    % RECIPE must only contain two properties: "unit" {struct} and "values"
    % {cell of struct}
    %
    % # Recommended Patterns
    %
    % If you need to initialize the system by setting many properties and 
    % then scan only a couple properties, the first value in "values"
    % should contain the initial state.  
    
    
    properties (Constant)
        dHeight = 30;
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)
       
        % {uint8 1x1} index of recipe.values list that is currently executing
        u8Index  
        
        % {cell of struct} list of value structures that define each state
        ceValues 
       
        stUnit
        
    end
    
    properties (Access = private)
       
        % {double 1x1} - how often fhIsAtState() and fhIsAcquired() are
        % called
        dDelay = 0.02;  
       
        % {mic.Clock 1x1}
        clock
        
        % {logical 1x1} - true when paused
        lPaused = false;
        
        
        % @param {function_handle} fhSetState(stUnit, stState) - function to update the
        % N-dimensional (N-motor / N-degree-of-freedom) destination 
        % of the system and tell the system to go to the destination.
        % The consumer of this function is responsible for handling
        % any order of operations, etc. to bring the system to the
        % state. 
        % 	@param {struct} stUnit - the unit definition structure 
        %   @param {struct} stState - the state
        fhSetState
        
        % @param {function_handle} fhIsAtState(stUnit, stState) - function that receives a
        % state and returns a logical to indicate if they system is
        % at that state
        %   @param {struct} stUnit - the unit definition structure 
        %   @param {struct} stState - the state
        %   @returns {logical} - true if the system is at the state
        fhIsAtState
        
        % @param {function_handle} fhAcquire(stUnit, stState) - function
        % that is called after the system reaches each state.  In most cases,
        % a task or action will be performed inside of this function.
        %
        % If the task that needs to be performed is not identical at each
        % state, states should contain information required to
        % execute the desired task at that state.  The recommended approach
        % is to make a "task" property on each state that is an object with
        % the required information
        %
        % Since you are the creator of the state objects, and the creator of the 
        % handler function, you can do whatever you want.  
        % 	@param {struct} stUnit - the unit definition structure 
        %   @param {struct} stState - the state
        fhAcquire
        
        % @param {function_handle} fhIsAcquired(stUnit, stState) - return true if the
        % acquire process for the current state is complete.
        %   @param {struct} stUnit - the unit definition structure 
        %   @param {struct} stState - the state
        %   @returns {logical} - true if the system is at the state
        fhIsAcquired
        
        % @param {function_handle} fhOnComplete - function to call when
        % scan has completed successfully.
        fhOnComplete
        
        % @param {function_handle} fhOnAbort - function to call when scan
        % was stopped prematurely
        fhOnAbort
        
        ticId
        dSecondsElapsed
    end
    
    
    events
      %{
      eNewStateStart
      eNewStateCheck
      eNewStateEnd
      eAcquireStart
      eAcquireEnd
      
      eComplete
      eAbort
      ePause
      eResume
      %}
      
    end
    
    
    methods
        
       % constructor
       
        function this= Scan( ....
                clock, ...
                stRecipe, ...
                fhSetState, ...
                fhIsAtState, ...
                fhAcquire, ...
                fhIsAcquired, ...
                fhOnComplete, ...
                fhOnAbort)
          
        
        %   @param {struct} stRecipe - see below
        %       @prop {struct} unit - defines the unit of
        %           every degree of freedom that will be controlled.  See notes
        %           at the top of this class for more explanation.
        %       @prop {cell of any} values - list of value structures that
        %           define each state. 
        
            this.clock = clock;
            this.stUnit = stRecipe.unit;
            this.ceValues = stRecipe.values;
            this.fhSetState = fhSetState;
            this.fhIsAtState = fhIsAtState;
            this.fhAcquire = fhAcquire;
            this.fhIsAcquired = fhIsAcquired;
            this.fhOnComplete = fhOnComplete;
            this.fhOnAbort = fhOnAbort;
            
        end
       
        function start(this) 
        %START start the scan 
        
            this.u8Index = 1;
            
            % Reset elapsed time and tic
            this.dSecondsElapsed = 0;
            this.ticId = tic;
            
            this.go();
            
        end

        function pause(this) 
        %PAUSE pause the scan
        
            % If Scan is paused while the system is settling to a new
            % state, the clock task that is asking the system if it has
            % settled is removed and u8Index remains the same.  If motors
            % need to be stopped, it is assumed that the parent class takes
            % care of that.  When theS Scan is unpaused, go() is
            % called which restarts the scan at the u8Index item of
            % ceValues
            % 
            % If Scan is paused while the system is in the middle of
            % acquiring, Scan waits for isAcquired to return true,
            % increments u8Index but then does not call go() to begin the
            % the set-wait-acquire process for the next state.
            
            if (~this.lPaused)
               this.lPaused = true; 
            else
               this.msg('Already paused'); 
            end
                        
        end

        function resume(this) 
        %PAUSE resume the scan
            if (this.lPaused)
                this.lPaused = false;
                
                % Reset tic
                this.ticId = tic;
                
                this.go();
            else
               this.msg('Was not paused.'); 
            end
            
            %notify(this,'eResume');
        end

        function stop(this)
        %STOP abort the scan, reset back to start index
             this.removeClockTask();
             this.u8Index = 1;
             
             %notify(this,'eAbort');
             this.fhOnAbort(this.stUnit);

        end
        
        % @typedef {struct 1x1} Status
        % @property {char 1xm} cTimeElapsed - HH:MM:SS of elapsed time
        % since the scan started
        % @property {char 1xm} cTimeComplete - HH:MM:SS local estimate of
        % the time when the scan will be complete
        % @property {char 1xm} cTimeRemaining - HH:MM:SS estimate of the
        % time remaining for the scan to complete
        % @property {double 1x1} dProgress - fractional progress bettween 0
        % and 1
        % @property {char 1xm} cStatus - ?Scanning 4.3%? text that shows if
        % it is scanning or complete and also the percentage
        % @return {Status 1x1}
        function st = getStatus(this)
                        
            dProgress = this.u8Index / length(this.ceValues);
                     
            % Fractional days since of scan time that have elapsed.  Pause
            % time is excluded from this number.  See updateElapsedTime()
            
            dDaysElapsed = this.dSecondsElapsed / (3600 * 24);
            
            % Use elapsed days and progress to estimate the number of days
            % for the entire scan to complete
            
            if dProgress == 0
                dDaysScan = 0;
            else
                dDaysScan = dDaysElapsed / dProgress;
            end
            
            dDaysRemaining = dDaysScan - dDaysElapsed;
            
            cTimeElapsed = datestr(dDaysElapsed, 'HH:MM:SS', 'local');
            
            % Add the estimated numbef of days for the full scan to the
            % number of days since Jan 0, 0000 (obtained with "now") to get
            % the estimated complete time.  
            
            try
                cTimeComplete = datestr(now + dDaysRemaining, 'HH:MM:SS', 'local');
                cTimeRemaining = datestr(dDaysRemaining, 'HH:MM:SS', 'local');
            catch me
                cTimeComplete = '...';
                cTimeRemaining = '...';
            end
            
            st = struct();
            if this.lPaused
                st.cStatus = sprintf('Paused (%1.1f%%)', dProgress * 100);
            else
                if dProgress == 1
                    st.cStatus = sprintf('Complete (%1.1f%%)', dProgress * 100);
                else
                    st.cStatus = sprintf('Scanning (%1.1f%%)', dProgress * 100);
                end
            end
            st.cTimeElapsed = cTimeElapsed;
            st.cTimeRemaining = cTimeRemaining;
            st.cTimeComplete = cTimeComplete;
            st.dProgress = dProgress;
            
        end
       
       
    end
    
    methods (Access = protected)
        
        function go(this)
        %GO call fhSetState with state at u8Index of the list, wait for the
        %system to get to the state, call fhAcquire, wait for acquire to
        %complete, which increments u8Index and calls go again
           
            this.fhSetState(this.stUnit, this.ceValues{this.u8Index});
            
            % Start checking the state
            this.clock.add(@this.handleClockIsAtState, this.id(), this.dDelay); 
            
        end
        
        
        function handleClockIsAtState(this)
            
            % this.msg('handleClockIsAtState');
            
            if (this.lPaused)
                this.removeClockTask();
                return;
            end
            
            if (this.fhIsAtState(this.stUnit, this.ceValues{this.u8Index}))
             
                this.removeClockTask();
                
                % Call acuire, passing in units
                this.fhAcquire(this.stUnit, this.ceValues{this.u8Index});
                
                % Start checking for acquire complete
                this.clock.add(@this.handleClockIsAcquired, this.id(), this.dDelay);
                                
            end
            
            this.updateElapsedTime()
            
        end
        
        
        function handleClockIsAcquired(this)
            
            % this.msg('handleClockIsAcquired');
            
            if (this.fhIsAcquired(this.stUnit, this.ceValues{this.u8Index}))
             
                % Remove the clock task
                this.removeClockTask();
                
                if (this.u8Index < length(this.ceValues))
                    
                   this.u8Index = this.u8Index + 1;
                   
                   if (~this.lPaused)
                        this.go();
                   end
                    
                else
                    
                    % No more values.  Done
                    this.fhOnComplete(this.stUnit);

                end
                
                                
            end
            
            this.updateElapsedTime()
            
        end
        
        function removeClockTask(this)
            
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end 
            
        end
        
        function delete(this)
            
            this.removeClockTask();
            
        end
        
        % this.ticId stores a reference to the last time tic was called
        % which is inside start() and resume().  dSecondsElapsed is 
        % reset to zero in one place: start()
        function updateElapsedTime(this)
            % Add the seconds sinced the last tic to the elapsed time
            this.dSecondsElapsed = this.dSecondsElapsed + toc(this.ticId);
            this.ticId = tic;
        end
        
        
        
    end

end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% COPY THESE PLACEHOLDERS INTO ANY CLASS THAT USES A mic.Scan
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


%{

% @param {struct} stUnit - the unit definition structure 
% @param {struct} stState - the state
function onScanSetState(this, stUnit, stValue)
            
end


% @param {struct} stUnit - the unit definition structure 
% @param {struct} stState - the state
% @returns {logical} - true if the system is at the state
function l = onScanIsAtState(this, stUnit, stValue)
    l = true;
end


% @param {struct} stUnit - the unit definition structure 
% @param {struct} stState - the state (possibly contains information about
the task to execute during acquire)
function onScanAcquire(this, stUnit, stValue)

end

% @param {struct} stUnit - the unit definition structure 
% @param {struct} stState - the state
% @returns {logical} - true if the acquisition task is complete
function l = onScanIsAcquired(this, stUnit, stValue)
    l = true;
end


function onScanAbort(this, stUnit)

end


function onScanComplete(this, stUnit)

end

%}



% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% RECOMMENDED PATTERN WITH ?CONTRACTS? FOR SET AND ACQUIRE
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% The ?contract? pattern uses a structure to help programatically check
% if the system has reached a particular state or executed an acquire task.
%
% The ?set contract? structure has a prop for each prop of the 
% system that can be set during the set call. Each prop is a structure 
% with two props: lRequired and lIssued, e.g.:
%  
% st.device_stage_x.lRequired = false
% st.device_stage_x.lIssued = false
% st.device_stage_y.lRequired = false
% st.device_stage_y.lIssued = false
% st.device_stage_z.lRequired = false
% st.device_stage_z.lIssued = false
%
% The ?acquire contract? structure has a prop for each prop of the 
% system that can be set or used during the acquire task.  Each prop is a
% structure with two props: lRequired and lIssued, e.g.:
%
% st.device_volt_meter.lRequired = false
% st.device_volt_meter.lIssued = false
% st.device_camera.lRequired = false
% st.device_camera.lIssued = false
%
% The ?set contract? structure is reset (all logical properties are set to
% false) at the begging of each setState().  All properties of the system
% that need to be modified in the setState() call have their ?lRequired?
% property set to true.  As properties are set(), the ?lIssued? property is
% set to true. isAtState() uses the ?set contract? structure to determine
% if they system reached the desired state.

%{



function initScanSetContract(this)

    ceFields = { ...
        this.cNameDeviceGratingTiltX, ...
        this.cNameDeviceShutter, ...
        this.cNameDeviceExitSlit, ...
        this.cNameDeviceUndulatorGap, ...
        this.cNameDeviceD142StageY ...
     };

    for n = 1 : length(ceFields)
        this.stScanSetContract.(ceFields{n}).lRequired = false;
        this.stScanSetContract.(ceFields{n}).lIssued = false;
    end

end

function initScanAcquireContract(this)

    ceFields = {...
        this.cNameDeviceMeasurPointD142
    };

    for n = 1 : length(ceFields)
        this.stScanAcquireContract.(ceFields{n}).lRequired = false;
        this.stScanAcquireContract.(ceFields{n}).lIssued = false;
    end

end

function resetScanSetContract(this)

    ceFields = fieldnames(this.stScanSetContract);
    for n = 1 : length(ceFields)
        this.stScanSetContract.(ceFields{n}).lRequired = false;
        this.stScanSetContract.(ceFields{n}).lIssued = false;
    end

end

function resetScanAcquireContract(this)

    ceFields = fieldnames(this.stScanAcquireContract);
    for n = 1 : length(ceFields)
        this.stScanAcquireContract.(ceFields{n}).lRequired = false;
        this.stScanAcquireContract.(ceFields{n}).lIssued = false;
    end

end






% @param {struct} stUnit - the unit definition structure 
% @param {struct} stValue - the system state that needs to be reached
% @returns {logical} - true if the system is at the state
function lOut = onScanIsAtState(this, stUnit, stValue)

    lOut = true;

    stContract = this.stScanSetContract
    ceFields= fieldnames(stContract);

    for n = 1:length(ceFields)

        cField = ceFields{n};

        % special case, skip task
        if strcmp(cField, 'task')
            continue;
        end


        if stContract.(cField).lRequired
   
            if stContract.(cField).lIssued

                % !!! PUT CODE HERE !!! 
                % Check if the set operation on the current device is
                % complete by calling isReady() on devices.  This will
                % often be a switch on cField that does something like:
                % this.uiDeviceStage.getDevice().isReady()

                % Example:
                %{
                lReady = true;
                
                switch cField
                    case 'reticleX'
                       if ~this.uiReticle.uiCoarseStage.uiX.getDevice().isReady()
                           lReady = false;
                       end

                    case 'reticleY'
                       if ~this.uiReticle.uiCoarseStage.uiY.getDevice().isReady()
                           lReady = false;
                       end
                    
                    otherwise

                        % UNSUPPORTED

                end
                %}

                % !!! END REQUIRED CODE !!!

                if lReady
                    if this.lDebugScan
                        this.msg(sprintf('onScanIsAtState() %s required, issued, complete', cField));
                    end

                else
                    % still isn't there.
                    if this.lDebugScan
                        this.msg(sprintf('onScanIsAtState() %s required, issued, incomplete', cField));
                    end
                    lOut = false;
                    return;
                end
            else
                if this.lDebugScan
                    this.msg(sprintf('onScanIsAtState() %s required, not issued.', cField));
                end

                lOut = false;
                return;
            end                    
        else

            if this.lDebugScan
                this.msg(sprintf('onScanIsAtState() %s not required', cField));
            end
        end
    end
end



% @param {struct} stUnit - the unit definition structure 
% @param {struct} stState - the state
% @returns {logical} - true if the acquisition task is complete
function lOut = onScanIsAcquired(this, stUnit, stValue)

    lOut = true;

    stContract = this.stScanAcquireContract;
    ceFields= fieldnames(stContract);

    for n = 1:length(ceFields)

        cField = ceFields{n};

        if stContract.(cField).lRequired

            if stContract.(cField).lIssued

                % !!! PUT CODE HERE !!! 
                % Check if the set operation on the current device is
                % complete by calling isReady() on devices.  This will
                % often be a switch on cField that does something like:
                % this.uiDeviceStage.getDevice().isReady()

                % !!! END REQUIRED CODE !!!

                if lReady
                    if this.lDebugScan
                        this.msg(sprintf('onScanIsAcquired() %s required, issued, complete', cField));
                    end

                else
                    if this.lDebugScan
                        this.msg(sprintf('onScanIsAcquired() %s required, issued, incomplete', cField));
                    end
                    lOut = false;
                    return;
                end
            else
                if this.lDebugScan
                    this.msg(sprintf('onScanIsAcquired() %s required, not issued.', cField));
                end

                lOut = false;
                return;
            end                    
        else

            if this.lDebugScan
                this.msg(sprintf('onScanIsAcquired() %s not required', cField));
            end
        end
    end

end
%}