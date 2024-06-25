classdef PClock < mic.Base

    %{
        This class is a reimagnining of the mic.Clock class designed to address several issues with the first version.

        The key differences are:
        1) The class executes tasks asynronously in separate threads from the main display thread.
        2) Task events are organized into their own class and their execution is staggered
        3) Tasks are not added and removed; they are activated and deactivated
        4) Tasks do not rely on a period that is a multiple of the clock period
        5) Tasks can be persistent
    %}

	properties
        cName % name ('identifier') of the Clock
    end
    
    properties (SetAccess = private)
        dPeriod       % Clock period
    end
    
    properties (Access = private)
        
        dNumWorkers = 8
        lIsParallel = false

        dDurationOfLastTimerExecution = 0;
        lBusy = false;
        lEcho = true;                      % Print statements
        t                                   % Timer
        
        % Stores the PClockTasks in a struct with the task name as the field name
        stTasks       = struct;       % list of actions to perform
               
        lIsStopped = false
    end
    
    methods
        %% Constructor
        function this = PClock(cName, dPeriod)
            if nargin == 1
                dPeriod = 0.1;
            end
            
            this.dPeriod = dPeriod;
            this.cName = cName;
            this.init();
        end
        
        function d = getDurationOfLastTimerExecution(this)
            d = this.dDurationOfLastTimerExecution;
        end
        
        function dReturn = getPeriod(this)
            dReturn = this.dPeriod;
        end
        
        function init(this)

            % Init pool:
            cToolboxes = ver;
            this.lIsParallel = any(strcmp({cToolboxes.Name}, 'Parallel Computing Toolbox'));

            if this.lIsParallel && isempty(gcp('nocreate'))
                parpool('local', this.dNumWorkers); % Adjust the number of workers as needed
            end
       
            % Initialize the master timer
            this.t =  timer( ...
                'TimerFcn',         @this.timerFcn, ...
                'Period',           this.dPeriod, ...
                'ExecutionMode',    'fixedRate', ...
                'Name',             sprintf('Clock (%s)', this.cName) ...
            );
            start(this.t);
        end
        
        % Checks if a task is already in the task list
        function lValue = has(this, hPClockTask)
            % Returns true if the task name is on the task list and it is
            sanitizedStr = this.sanitizeForStructName(hPClockTask.cName);
            lValue = isfield(this.stTasks, sanitizedStr);            
        end
        
        % Adds a task to the task list
        function lAdded = add(this, hPClockTask)

            % Don't add a task if it already exists
            if this.has(hPClockTask)
                mE = MException( 'PClock:add', sprintf('cName of %s already exists.  It must be unique.', hPClockTask.cName));
                disp(mE)
                lAdded = false;
                return
            end

            sanitizedStr = this.sanitizeForStructName(hPClockTask.cName);
            this.stTasks.(sanitizedStr) = hPClockTask;
            lAdded = true;
        end

        function clearAllTasks(this)
            this.stTasks = struct;
        end
        
        
        function lRemoved = remove(this, hPClockTask)
            if ~this.has(hPClockTask)
                mE = MException( 'PClock:remove',  sprintf('Trying to remove cName of %s does not exist.', hPClockTask.cName));
                throw(mE)
                lRemoved = false;
                return
            end

            % Remove the task
            sanitizedStr = this.sanitizeForStructName(hPClockTask.cName);
            this.stTasks = rmfield(this.stTasks, sanitizedStr);

            lRemoved = true;
        end 
        
        function d = getNumberOfActiveTasks(this)
            % Loop through all task structure values and count the number of active tasks
            d = 0;
            ceTasks = struct2cell(this.stTasks);
            for k = 1:length(ceTasks)
                if ceTasks{k}.lActive
                    d = d + 1;
                end
            end
        end
        
        function listTasks(this)
        %LISTTASKS Lists the tasks in the clock tasklist in the command wdw
        %   Clock.listTasks()
        % See also HAS, ADD, REMOVE
            
            ceTaskNameActive = {};
            dTaskPeriodActive = [];
            ceTasks = struct2cell(this.stTasks);

            for k = 1:length(ceTasks)
                if ceTasks{k}.lActive
                    ceTaskNameActive{end + 1} = ceTasks{k}.cName;
                    dTaskPeriodActive(end + 1) = ceTasks{k}.dPeriod;
                end
            end
            
            if isempty(ceTaskNameActive)
                cStr = 'No task running\n';
            else
                cStr = 'List of running tasks :\n';
                
                for n = 1:length(ceTaskNameActive)                    
                    
                    cStr = sprintf(...
                        '%s\t %1.0f. \t  (%1.3f s) \t %s \n', ...
                        cStr, ...
                        n, ...
                        dTaskPeriodActive(n), ...
                        ceTaskNameActive{n} ...
                    );
                end
                
            end
            fprintf(cStr);
        end
        

        function start(this)
        %START Starts/restarts the clock
        %   Clock.start()
        %
        % See also STOP
        
            this.lIsStopped = false;
            
            if isvalid(this) && ...
                    isvalid(this.t)
                
                if strcmp(this.t.Running, 'off')
                    start(this.t);
                end
            end
        end
        
        function stop(this)
        %STOP stops the Clock
        %   Clock.stop()
        %
        % See also START
        
            this.lIsStopped = true;
            stop(this.t);
           
          
        end
        
      
        function handleParEvalComplete(this, hPClockTask)
            santizedStr = this.sanitizeForStructName(hPClockTask.cName);

            if (this.stTasks.(santizedStr).lOneShot)
                this.remove(hPClockTask);
                return
            end

            this.stTasks.(santizedStr).dLastExecutionTime = posixtime(datetime('now'));
        end
        
        function timerFcn(this, ~, ~)
            t0 = tic;
            dTimeStart = posixtime(datetime('now'));
            ceTasks = struct2cell(this.stTasks);

            for k = 1:length(ceTasks)
                if ceTasks{k}.lActive
                    % Check the last time this task was executed, and if that time is greater than the period, execute the task
                    if ceTasks{k}.dLastExecutionTime == -1 || ...
                            dTimeStart - ceTasks{k}.dLastExecutionTime > ceTasks{k}.dPeriod

                        if this.lIsParallel
                            hFuture = parfeval(@()ceTasks{k}.cFn(), 0);
                            % after it's done, set the last execution time
                            afterEach(hFuture, @()this.handleParEvalComplete(hPClockTask));
                        else
                            % Synchronous execution
                            santizedStr = this.sanitizeForStructName(ceTasks{k}.cName);
                            ceTasks{k}.cFn();
                            if this.lEcho
                                cMsg = sprintf('PClock.timerFcn() execution period: %4.2f', posixtime(datetime('now')) - ceTasks{k}.dLastExecutionTime);
                                this.msg(cMsg, 2);
                            end
                            this.stTasks.(santizedStr).dLastExecutionTime = posixtime(datetime('now'));
                        end 
                    end
                end
            end

            this.dDurationOfLastTimerExecution = toc(t0);
            
        end
        
        
        function save(this)
        end
        
        function load(this)
        end
        
        function build(this,hParent,dTop,dLeft)
        end
        
        %% Destructor
        function delete(this)

            try
                if this.lIsParallel
                    pool = gcp('nocreate');
                    if ~isempty(pool)
                        delete(pool);
                    end
                end
            end

        %DELETE Destructor for the clock 
        %   Clock.delete()
        %
        % See also CLOCK, INIT, BUILD
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            
            this.lIsStopped = true;
            
            try
                if isvalid(this.t)
                
                    if strcmp(this.t.Running, 'on')
                        stop(this.t);
                    end
                    
                    this.msg('delete() deleting timer', this.u8_MSG_TYPE_INFO);

                    delete(this.t);
                end
                
            catch mE
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
            end
                
            
        end
        
        function nothing(this)
        end
        
    end

    methods(Static)
        function sanitizedStr = sanitizeForStructName(str)
            % Ensure the string starts with a letter
            if ~isletter(str(1))
                str = ['x' str];
            end
            
            % Replace invalid characters with underscores
            validChars = isletter(str) | ismember(str, '0123456789_');
            sanitizedStr = str;
            sanitizedStr(~validChars) = '_';
            
            % Ensure the field name does not start with a number
            if ismember(sanitizedStr(1), '0123456789')
                sanitizedStr = ['x' sanitizedStr];
            end
        end
    end
    
end