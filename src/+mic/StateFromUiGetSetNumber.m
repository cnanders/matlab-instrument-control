classdef StateFromUiGetSetNumber < mic.interface.State
    
    
    properties (Constant)
        
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)

        
        % { mic.ui.device.GetSetNumber 1x1}
        ui
        
        % {char 1x1} unit (the ui must support the unit)
        cUnit
        
        % {double 1x1} target value in specified unit
        dGoal
        
        % {double 1x1} tolerance in specified unit
        dTolerance
        
        
    end
    
    properties (Access = private)
       
        
    end
    
    
    events
      
      
    end
    
    
    methods
               
       function this = StateFromUiGetSetNumber(ui, dGoal, dTolerance, cUnit)
           this.ui = ui;
           this.dGoal = dGoal;
           this.dTolerance = dTolerance;
           this.cUnit = cUnit; 
       end
        
       function go(this)
           this.ui.setDestCal(this.dGoal, this.cUnit);
           this.ui.moveToDest();
       end
       
       function stop(this)
           this.ui.stop();
       end
       
       function lVal = isGoing(this)
           lVal = ~this.ui.getDevice().isReady();
       end
       
       function lVal = isThere(this)
           lVal = abs(this.ui.getValCal(this.cUnit) - this.dGoal) <= this.dTolerance;
       end
   
    end
    
    methods (Access = protected)
        
        
    end

end
