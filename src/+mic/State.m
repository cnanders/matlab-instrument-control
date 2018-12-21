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
        
        % {function_handle 1x1} called by isGoing()
        fhIsGoing
        
        % {function_handle 1x1} called by isThere()
        fhIsThere
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
   
    end
    
    methods (Access = protected)
        

    end
    
    %{
    
    CANNOT GET fhGo working with MATLABS crappy single-expression /lambda syntax
    
    methods (Static)
        
        function state = fromUiGetSetNumber(ui, dGoal, dTolerance, cUnit)
            
            
            state = mic.State(...
                'fhGo', @() ui.setDestCal(dGoal, cUnit) && ui.moveToDest(), ...
                'fhStop', @() ui.stop(), ...
                'fhIsGoing', @() ~ui.getDevice().isReady(), ...
                'fhIsThere', @() abs(ui.getValCal(cUnit) - dGoal) <= dTolerance ...
            );
            
        end
        
    end
    %}

end
