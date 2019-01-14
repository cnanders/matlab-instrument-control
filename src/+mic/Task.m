classdef Task < mic.interface.Task
    
    
    properties (Constant)
        
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)

        
    end
    
    properties (Access = private)
       
        % {function_handle 1x1} called by execute()
        fhExecute = @() []
        
        % {function_handle 1x1} called by abort()
        fhAbort = @() []
        
        % {function_handle 1x1} called by isExecuting() returns {logical 1x1}
        fhIsExecuting = @() false
        
        % {function_handle 1x1} called by isDone() returns {logical 1x1}
        fhIsDone = @() true
        
        % {function_handle 1x1} returns {char 1xm} message to display when 
        % moving to this state
        fhGetMessage = @() 'Moving...'
        
    end
    
    
    events
      
      
    end
    
    
    methods
               
       function this = Task(varargin)
          
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
       end
        
       function execute(this)
           this.fhExecute();
       end
       
       function abort(this)
           this.fhAbort();
       end
       
       function l = isExecuting(this)
           l = this.fhIsExecuting();
       end
       
       function l = isDone(this)
           l = this.fhIsDone();
       end
       
       function c = getMessage(this)
           c = this.fhGetMessage();
       end
       
   
    end
    
    methods (Access = protected)
        

    end
    
    
    
    
    methods (Static)
        
        
        % @param {mic.ui.device.GetSetLogical 1x1}
        % @param {logical} lVal - the value to set
        % [@param {char 1xm} [cName = ui.cName] - optional name to display 
        % in the auto-generated message.  Message will look like: 
        % 'Set {cName} to true/false'
        function task = fromUiGetSetLogical(ui, lVal, cName)
           
            if nargin == 2
                cName = ui.cName;
            end
            
            if ~isa(ui, 'mic.ui.device.GetSetLogical')
                error('ui must be {mic.ui.device.GetSetLogial}');
            end
            
            if ~islogical(lVal)
                error('lVal must be {logical}');
            end
            
            if ~ischar(cName)
                error('cName must be {char}');
            end
                    
            cMsg = sprintf(...
                'Set %s to %s...', ...
                cName, ...
                mic.Utils.tern(lVal, 'true', 'false') ...
            );
            task = mic.Task(...
                'fhExecute', @() ui.set(lVal), ...
                'fhAbort', @() [], ...
                'fhIsExecuting', @() false, ...
                'fhIsDone', @() ui.get() == lVal, ...
                'fhGetMessage', @() cMsg ... 
            );
        end
        
        
        % @param {mic.ui.device.GetSetText 1x1}
        % @param {char 1xm} cVal - the value to set
        % [@param {char 1xm} [cName = ui.cName] - optional name to display 
        % in the auto-generated message.  Message will look like: 
        % 'Set {cName} to {cVal}'
        function task = fromUiGetSetText(ui, cVal, cName)
           
            if nargin == 2
                cName = ui.cName;
            end
            
            %{
            p = inputParser;
            addRequired(p, 'ui', @(x) isa(this.task, 'mic.TaskSequence'));
            addRequired(p, 'cVal', @ischar);
            parse(p, ui, cVal, cName);
            %}
            
            
            fhExecute = @() mic.Utils.evalAll(...
                @() ui.setDest(cVal), ...
                @() ui.moveToDest() ...
            );
        
        
            cMsg = sprintf(...
                'Set %s to %s...', ...
                cName, ...
                cVal ...
            );
            task = mic.Task(...
                'fhExecute', fhExecute, ...
                'fhAbort', @() [], ...
                'fhIsExecuting', @() false, ...
                'fhIsDone', @() strcmpi(ui.get(), cVal), ...
                'fhGetMessage', @() cMsg ... 
            );
        end
        
        
        % @param {mic.ui.device.GetSetText 1x1}
        % @param {double 1x1} dGoal - the destination to set
        % @param {double 1x1} dTolerance - the tolerance to check
        % @param {char 1xm} cUnit - the unit of dGoal and dTolerance
        % [@param {char 1xm} [cName = ui.cName] - optional name to display 
        % in the auto-generated message.  Message will look like: 
        % 'Set {cName} to {dVal}'
        function task = fromUiGetSetNumber(ui, dGoal, dTolerance, cUnit, cName)
            
            if nargin == 4
                cName = ui.cName;
            end
            % This evalAll wrapper works because it doesn't return anything
            % and fits the function definition of fhExecute defined in
            % mic.interface.State
            
            fhExecute = @() mic.Utils.evalAll(...
                @() ui.setDestCal(dGoal, cUnit), ...
                @() ui.moveToDest() ...
            );
        
            % this also works
            % fhExecute = @() ui.setDestCalAndGo(dGoal, cUnit);
            
            % The following won't work because it returns a
            % logical and mic.interface.State requires fhExecute to not return
            % anything
            % fhExecute = @() ui.setDestCal(dGoal, cUnit) && ui.moveToDest();
            
            cMsgGoing = sprintf(...
                'Set %s to %1.3f %s...', ...
                cName, ...
                dGoal, ...
                cUnit ...
            );
        
            cMsg = sprintf(...
                '%s at %1.3f %s', ...
                cName, ...
                dGoal, ...
                cUnit ...
            );
        
            %{
            fhGetMessage = @() mic.Utils.ifElseLambda(...
                @() ~ui.getDevice().isReady(), @() cMsgGoing, ...
                @() cMsg ...
            );
            %}
            fhGetMessage = @() cMsgGoing;
        
            task = mic.Task(...
                'fhExecute', fhExecute, ...
                'fhAbort', @() ui.stop(), ...
                'fhIsExecuting', @() ~ui.getDevice().isReady(), ...
                'fhIsDone', @() abs(ui.getValCal(cUnit) - dGoal) <= dTolerance, ...
                'fhGetMessage', fhGetMessage ... 
            );
            
        end
        
    end
    

end
