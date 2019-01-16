classdef TaskSequence < mic.interface.Task
    
    
    properties (Constant)
        
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)

        % {char 1xm} app-wide unique name for clock
        cName = 'mic-task-sequence-change-me'
        
        
        
    end
    
    
    properties (Access = private)
       
        % {cell of < mic.interface.Task}
        ceTasks = {}
        
        % {function_handle 1x1} that returns a {cell of < mic.interface.Task}
        % fhGetTasks
        
        % {mic.Clock 1x1}  NOT {mic.ui.Clock}
        clock
        
        % {handle 1x1}
        hProgress
                
        % {double 1x1}
        dPeriod
        
        % {mic.Scan 1x1}
        scan
        
        % {char 1xm} - description of the task/seqeunce/state
        cDescription
        
    end
    
    
    events
      
      
    end
    
    
    methods
               
       function this = TaskSequence(varargin)
          
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    
                    switch varargin{k}
                        case 'ceTasks'
                            this.setTasks(varargin{k + 1}); % special case need to handle in special way
                        otherwise
                            this.(varargin{k}) = varargin{k + 1};
                    end
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                end
            end
            
            % Check that clock is not a uiClock
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
       end
       

       
        
       function execute(this)
           
            if this.isDone() 
                return
            end
            
            % this.hProgress = waitbar(0, [this.cName, '. Please wait...']);
            
            fhSetState      = @(~, task) task.execute();
            fhIsAtState     = @(~, task) task.isDone() && ~task.isExecuting();
            fhAcquire       = @(~, task) [];
            fhIsAcquired    = @(~, task) true;
            
            %fhOnComplete    = @(~, task) [];
            %fhOnAbort       = @(~, task) [];
            
            fhOnComplete    = @this.onScanComplete;
            fhOnAbort       = @this.onScanAbort;
        
            
            stRecipe = struct;
            stRecipe.values = this.ceTasks; % this.getFlatCellOfTasks();  % enumerable list of tasks that can be read by setTask
            stRecipe.unit = struct('unit', 'unit'); % not sure if we need units really, but let's fix later
            
            this.scan = mic.Scan(this.cName, ...
                                this.clock, ...
                                stRecipe, ...
                                fhSetState, ...
                                fhIsAtState, ...
                                fhAcquire, ...
                                fhIsAcquired, ...
                                fhOnComplete, ...
                                fhOnAbort, ...
                                this.dPeriod ...
                                );
            this.scan.start();
           
       end
       
       function abort(this)
           this.scan.stop();
           for n = 1 : length(this.ceTasks)
               this.ceTasks{n}.abort();
           end
       end
       
       
       
       
       function lVal = isExecuting(this)
           
           if this.isScanning()
               lVal = true;
               return
           end
               
           lVal = false;
       end
       
       function lVal = isDone(this)
           for n = 1 : length(this.ceTasks)
               if ~this.ceTasks{n}.isDone()
                   lVal = false;
                   return
               end
           end
           lVal = true;
       end
       
       
       
       % Returns {char 1xm} status message
       function c = getMessage(this)
           
           
           if this.isExecuting()
               c = this.ceTasks{this.scan.getCurrentStateIndex()}.getMessage(); 
               return;
           end
                      
           c = this.cDescription;
           
       end
       
       
       
       function d = getProgress(this)
           if isempty(this.scan)
               d = 0;
               return;
           end
           
           if length(this.scan.ceValues) == 0
               d = 0;
               return
           end
           % d = this.scan.getCurrentStateIndex() / length(this.ceTasks);
           d = this.scan.getCurrentStateIndex() / length(this.scan.ceValues);
       end
       
       
       %{
       % Returns a {mic.Task 1xm} from a cell that may contain
       % {mic.Task} and {mic.TaskSequence}.  Since this.ceTasks
       % can contain mic.Task and mic.TaskSequence, could not use
       % an object array to store the original list.  Could eventually
       % simplify this if we only allow adding tasks through push().
       
       function tasks = getFlatTasks(this)
                      
           tasks = []; % storage for object list {task 1xm}
           for k = 1 : length(this.ceTasks)
              if isa(this.ceTasks{k}, 'mic.TaskSequence')                  
                  tasks = [tasks, this.ceTasks{k}.getFlatTasks()];
              else
                  tasks = [tasks, this.ceTasks{k}];
              end
           end           
       end
       
       % Returns {cell of mic.Task}
       function ce = getFlatCellOfTasks(this)
           tasks = this.getFlatTasks();
           ce = {};
           for k = 1 : length(tasks)
               ce{end + 1} = tasks(k);
           end
       end
       %}
       
       function ce = getTasks(this)
           ce = this.ceTasks;
       end
       
       
       % Pushes a {mic.Task} or {mic.TaskSequence} to this TaskSequence.
       % if {mic.TaskSequence} is passed, it flattens
       
       function push(this, task)
           
            
            if isa(task, 'mic.TaskSequence')                  
                ceTasksOfSequence = task.getTasks();
                for l = 1 : length(ceTasksOfSequence)
                    this.ceTasks{end + 1} = ceTasksOfSequence{l};
                end
            else
              this.ceTasks{end + 1} = task;
            end
                      
           % this.ceTasks{end + 1} = task;
           
       end
            
   
    end
    
    methods (Access = protected)
        
        
        function lVal = isScanning(this)
           
           if ~isempty(this.scan)
               lVal = true;
               return
           end
           
           lVal = false;
        end
       
        
        function setTasks(this, ceTasks)
           this.ceTasks = {};
           for k = 1 : length(ceTasks)
              this.push(ceTasks{k});
           end  
        end
        
        function onScanComplete(this, unit, task)
            this.scan = [];
        end
        
        function onScanAbort(this, unit, task)
            this.scan = [];
        end
        
        
    end

end
