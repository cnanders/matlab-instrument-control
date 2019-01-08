classdef State < mic.interface.State
    
    
    properties (Constant)
        
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)

        
    end
    
    properties (Access = private)
       
        % {function_handle 1x1} called by go()
        fhGo
        
        % {function_handle 1x1} called by stop()
        fhStop
        
        % {function_handle 1x1} called by isGoing() returns {logical 1x1}
        fhIsGoing 
        
        % {function_handle 1x1} called by isThere() returns {logical 1x1}
        fhIsThere
        
        % {function_handle 1x1} returns {char 1xm} message to display when 
        % moving to this state
        fhGetMessage = @() 'Moving...'
    end
    
    
    events
      
      
    end
    
    
    methods
               
       function this = State(varargin)
          
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
       end
        
       function go(this)
           this.fhGo();
       end
       
       function stop(this)
           this.fhStop();
       end
       
       function l = isGoing(this)
           l = this.fhIsGoing();
       end
       
       function l = isThere(this)
           l = this.fhIsThere();
       end
       
       function c = getMessage(this)
           c = this.fhGetMessage();
       end
       
   
    end
    
    methods (Access = protected)
        

    end
    
    
    
    
    methods (Static)
        
        function state = fromUiGetSetNumber(ui, dGoal, dTolerance, cUnit)
            
            % This evalAll wrapper works because it doesn't return anything
            % and fits the function definition of fhGo defined in
            % mic.interface.State
            
            fhGo = @() mic.Utils.evalAll(...
                @() ui.setDestCal(dGoal, cUnit), ...
                @() ui.moveToDest() ...
            );
        
            % this also works
            fhGo = @() ui.setDestCalAndGo(dGoal, cUnit);
            
            % The following won't work because it returns a
            % logical and mic.interface.State requires fhGo to not return
            % anything
            
            % fhGo = @() ui.setDestCal(dGoal, cUnit) && ui.moveToDest();
            
            cMsg = sprintf(...
                'Moving %s to %1.3f %s...', ...
                ui.cName, ...
                dGoal, ...
                cUnit ...
            );
        
            state = mic.State(...
                'fhGo', fhGo, ...
                'fhStop', @() ui.stop(), ...
                'fhIsGoing', @() ~ui.getDevice().isReady(), ...
                'fhIsThere', @() abs(ui.getValCal(cUnit) - dGoal) <= dTolerance, ...
                'fhGetMessage', @() cMsg ... 
            );
            
        end
        
    end
    

end
