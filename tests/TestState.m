classdef TestState < mic.interface.State
    
    
    properties (Constant)
        
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)

        dGoal
        dTolerance
        ui
    end
    
    properties (Access = private)
       
        
    end
    
    
    events
      
      
    end
    
    
    methods
               
       function this = TestState()
          
            
            
       end
        
       function go(this)
           this.ui.setDestCalDisplay(this.dGoal);
           this.ui.moveToDest();
       end
       
       function abort(this)
           this.ui.stop();
       end
       
       function lVal = isGoing(this)
           lVal = this.ui.getDevice().isReady();
       end
       
       function lVal = isThere(this)
           lVal = abs(this.ui.getValCalDisplay() - this.dGoal) <= this.dTolerance;
       end
   
    end
    
    methods (Access = protected)
        
        function acquire(this, unit, state)
            waitbar( this.scan.getCurrentStateIndex() / length(this.ceScans), this.hProgress);
            
        end
        
    end

end
