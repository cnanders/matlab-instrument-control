classdef Clock < mic.Base

    % Implements the public interface of mic.clock (add, remove, has)
    % Can be passed to any UI as a valid clock
    % has additional methods start() and stop() to allow silencing of a
    % group of clock tasks that update UIs.  
    
    %% Properties
    
	properties
        
    end
    
    properties (SetAccess = private)
        
    end
    
    properties (Access = private)
        
        % {mic.Clock 1x1}
        clock
        
        %0x0 cell
        ceTaskFcn       = {};       % list of actions to perform
        %0x0 cell
        ceTaskName      = {};       % list of task names
        %0x0 double
        dTaskPeriod     = [];       % list of task periods
        %0x0 logical
        lTaskActive     = true(0);  % mask of active task
        
        lIsRunning = true;
        lEcho = false;
            
    end
    
    events
    end
    
    
    
    
    
    methods

        
        function this = Clock(clock)
            this.clock = clock;
        end
        
        % Returns true if the task name is on the task list and it is
        % active
        
        function lReturn = has(this, cName)
                        
            if isempty(this.ceTaskName)
                lReturn = false;
                return;
            end
            
            if any(strcmp(cName, this.ceTaskName) & this.lTaskActive)
                lReturn = true;
            else
                lReturn = false;
            end            
            
        end
        
        
        
        function add(this, fhFcn, cName, dPeriod)
            
            if this.has(cName)
                mE = MException( ...
                    'Clock:add', ...
                    sprintf('cName of %s already exists.  It must be unique.', cName) ...
                );
                throw(mE)
            end
            
            dIndex = this.nextIndex();
            this.ceTaskFcn{dIndex}      = fhFcn;
            this.ceTaskName{dIndex}     = cName;
            this.dTaskPeriod(dIndex)    = dPeriod;
            this.lTaskActive(dIndex)    = true;
            
            if this.lEcho
                cMsg = sprintf( ...
                    'Clock.add() %s', ...
                    this.ceTaskName{dIndex} ...
                );
                this.msg(cMsg, this.u8_MSG_TYPE_CLOCK);
            end
            
            if this.lIsRunning
                this.clock.add(fhFcn, cName, dPeriod);
            end
            

        end
        
        % De-activates a task from this tasklist and removes it from the
        % global clock if this mic.ui.Clock is running
        
        function remove(this, cName)
                    
            lItems = strcmp(cName, this.ceTaskName) & this.lTaskActive;
            
            if any(lItems)
                
                if this.lEcho
                    cMsg = sprintf(...
                        'mic.ui.Clock.remove() de-activating: %s() ', ...
                        this.ceTaskName{lItems} ...
                    );
                    this.msg(cMsg);
                end
                
                this.lTaskActive(lItems) = false;
                
            end
            
            if this.lIsRunning
                this.clock.remove(cName);
            end
            
                        
        end 
        
        function l = getIsRunning(this)
            l = this.lIsRunning;
        end
        
        % Adds all active tasks to the clock
        
        function start(this)
        
            if this.lIsRunning
                return
            end
            
            % Add all active tasks to the clock
            
            ceTaskFcnActive = this.ceTaskFcn(this.lTaskActive);
            ceTaskNameActive = this.ceTaskName(this.lTaskActive);
            dTaskPeriodActive = this.dTaskPeriod(this.lTaskActive) ;   
            
            if isempty(ceTaskNameActive)
                return
            end
            
            for n = 1 : length(ceTaskNameActive)
               this.clock.add(...
                   ceTaskFcnActive{n}, ...
                   ceTaskNameActive{n}, ...
                   dTaskPeriodActive(n) ...
               );
            end
            
            this.lIsRunning = true;
            
        end
        
        % Removes all active tasks from the clock
        
        function stop(this)
            
            if ~this.lIsRunning
                return
            end
            
            % Remove all active tasks from the clock
            
            ceTaskNameActive = this.ceTaskName(this.lTaskActive);
       
            if isempty(ceTaskNameActive)
                return
            end
            
            for n = 1 : length(ceTaskNameActive)
               this.clock.remove(ceTaskNameActive{n});
            end
            
            this.lIsRunning = false;
            
        end
        
    end
    
    
    methods (Access = protected)
        
        function dReturn = nextIndex(this)
        %NEXTINDEX Gives the next avaible slot in the clock tasklist
        %   dReturn = Clock.nextIndex()
            
            %{
            This will return the index of the next available slot in
            dTaskPeriod, ceTaskName, and ceTaskFcn.  First it will check
            this.lTaskActive to see if there are any inactive tasks (these
            can be overwritten).  If there are no inactive tasks, it
            computes the length of this.dTaskPeriod (don't use
            this.dTaskName b/c computing the length of a cell takes longer
            than computing the length of a double) and return the length
            incremented by 1
            %}
            
            dIndex = find(~this.lTaskActive);
            
            if ~isempty(dIndex)
                % There is a task that can be overwritten
                dReturn = dIndex(1);
                return;
            end
            
            dReturn = length(this.lTaskActive) + 1;
            
            
        end
        
        
    end
    
    
end