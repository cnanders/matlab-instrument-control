classdef StateSequence < mic.interface.State
    
    
    properties (Constant)
        
    end
    
    properties
        
        
 
    end
    
    
    properties (SetAccess = private)

        % {char 1xm}
        cName
        
        
    end
    
    properties (Access = private)
       
        % {cell of < mic.interfaceState}
        ceStates
        
        % {mic.clock 1x1}
        clock
        
        % {handle 1x1}
        hProgress
        
        % {mic.Scan 1x1}
        scan
        
        % {double 1x1}
        dPeriod
    end
    
    
    events
      
      
    end
    
    
    methods
               
       function this = StateSequence(varargin)
          
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
           
            if this.isThere() 
                return
            end
            
            this.hProgress = waitbar(0, [this.cName, '. Please wait...']);
            
            fhSetState      = @(~, state) state.go();
            fhIsAtState     = @(~, state) state.isThere() && ~state.isGoing();
            fhAcquire       = @this.acquire;
            fhIsAcquired    = @(~, state) true;
            fhOnComplete    = @(~, state) delete(this.hProgress);
            fhOnAbort       = @(~, state) delete(this.hProgress);
        
            stRecipe = struct;
            stRecipe.values = this.ceStates; % enumerable list of states that can be read by setState
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
       
       function stop(this)
           this.scan.stop();
           for n = 1 : length(this.ceStates)
               this.ceStates{n}.stop();
           end
       end
       
       function lVal = isGoing(this)
           
           for n = 1 : length(this.ceStates)
               if this.ceStates{n}.isGoing
                   lVal = true;
                   return
               end
           end
           
           lVal = false;
       end
       
       function lVal = isThere(this)
           for n = 1 : length(this.ceStates)
               if ~this.ceStates{n}.isThere()
                   lVal = false;
                   return
               end
           end
           lVal = true;
       end
   
    end
    
    methods (Access = protected)
        
        function acquire(this, unit, state)
            waitbar( this.scan.getCurrentStateIndex() / length(this.ceStates), this.hProgress);
            
        end
        
    end

end
