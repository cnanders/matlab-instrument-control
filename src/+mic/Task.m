classdef Task < mic.interface.Task
    
    
    properties (Constant)
        
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)

        
    end
    
    properties (Access = private)
       
        % {function_handle 1x1} called by execute()
        fhExecute
        
        % {function_handle 1x1} called by abort()
        fhAbort
        
        % {function_handle 1x1} called by isExecuting() returns {logical 1x1}
        fhIsExecuting 
        
        % {function_handle 1x1} called by isDone() returns {logical 1x1}
        fhIsDone
        
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
        
        function task = fromUiGetSetNumber(ui, dGoal, dTolerance, cUnit)
            
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
                ui.cName, ...
                dGoal, ...
                cUnit ...
            );
        
            cMsg = sprintf(...
                '%s at %1.3f %s', ...
                ui.cName, ...
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
                'fhAbort', @() ui.Abort(), ...
                'fhIsExecuting', @() ~ui.getDevice().isReady(), ...
                'fhIsDone', @() abs(ui.getValCal(cUnit) - dGoal) <= dTolerance, ...
                'fhGetMessage', fhGetMessage ... 
            );
            
        end
        
    end
    

end
