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
        
        % {function_handle 1x1} returns {char 1xm}
        fhGetMessageThere = @() 'Ready'
        fhGetMessageNotThere = @() 'Not Ready'
        fhGetMessageMoving = @() 'Moving...'
    end
    
    
    events
      
      
    end
    
    
    methods
               
       function this = StateSequence(varargin)
          
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    
                    switch varargin{k}
                        case 'ceStates'
                            this.setStates(varargin{k + 1}); % special case need to handle in special way
                        otherwise
                            this.(varargin{k}) = varargin{k + 1};
                    end
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                end
            end
            
       end
       
        
       function go(this)
           
            if this.isThere() 
                return
            end
            
            % this.hProgress = waitbar(0, [this.cName, '. Please wait...']);
            
            fhSetState      = @(~, state) state.go();
            fhIsAtState     = @(~, state) state.isThere() && ~state.isGoing();
            fhAcquire       = @this.acquire;
            fhIsAcquired    = @(~, state) true;
            % fhOnComplete    = @(~, state) delete(this.hProgress);
            % fhOnAbort       = @(~, state) delete(this.hProgress);
            
            fhOnComplete    = @(~, state) [];
            fhOnAbort       = @(~, state) [];
            
            fhOnComplete    = @this.onScanComplete;
            fhOnAbort       = @this.onScanAbort;
        
            
            stRecipe = struct;
            stRecipe.values = this.ceStates; % this.getFlatCellOfStates();  % enumerable list of states that can be read by setState
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
           
           if ~isempty(this.scan)
               lVal = true;
               return
           end
           
           %{
           for n = 1 : length(this.ceStates)
               if this.ceStates{n}.isGoing
                   lVal = true;
                   return
               end
           end
           %}
           
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
       
       %{
       function c = getMessageThere(this)
           c = this.fhGetMessageThere();
       end
       
       function c = getMessageNotThere(this)
           c = this.fhGetMessageNotThere();
       end
       
       function c = getMessageMoving(this)
           c = this.fhGetMessageMoving();
       end
       %}
       
       % Returns {char 1xm} status message
       function c = getMessage(this)
           
           if this.isGoing()
               c = this.ceStates{this.scan.getCurrentStateIndex()}.getMessage(); % this.fhGetMessageMoving(); 
               return;
           end
                      
           c = mic.Utils.ifElse(...
               this.isThere(), this.fhGetMessageThere(), ...
               this.fhGetMessageNotThere() ...
           );
           
       end
       
       function d = getColor(this)
           d = mic.Utils.ifElse(...
               this.isGoing(), [1 1 0.85], ...
               this.isThere(), [.85, 1, .85], ...
               [1, .85, .85] ...
           );           
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
           % d = this.scan.getCurrentStateIndex() / length(this.ceStates);
           d = this.scan.getCurrentStateIndex() / length(this.scan.ceValues);
       end
       
       
       %{
       % Returns a {mic.State 1xm} from a cell that may contain
       % {mic.State} and {mic.StateSequence}.  Since this.ceStates
       % can contain mic.State and mic.StateSequence, could not use
       % an object array to store the original list.  Could eventually
       % simplify this if we only allow adding states through push().
       
       function states = getFlatStates(this)
                      
           states = []; % storage for object list {state 1xm}
           for k = 1 : length(this.ceStates)
              if isa(this.ceStates{k}, 'mic.StateSequence')                  
                  states = [states, this.ceStates{k}.getFlatStates()];
              else
                  states = [states, this.ceStates{k}];
              end
           end           
       end
       
       % Returns {cell of mic.State}
       function ce = getFlatCellOfStates(this)
           states = this.getFlatStates();
           ce = {};
           for k = 1 : length(states)
               ce{end + 1} = states(k);
           end
       end
       %}
       
       function ce = getStates(this)
           ce = this.ceStates;
       end
       
       
       % Pushes a {mic.State} or {mic.StateSequence} to this StateSequence.
       % if {mic.StateSequence} is passed, it flattens
       
       function push(this, state)
           
            if isa(state, 'mic.StateSequence')                  
                ceStatesOfSequence = state.getStates();
                for l = 1 : length(ceStatesOfSequence)
                    this.ceStates{end + 1} = ceStatesOfSequence{l};
                end
            else
              this.ceStates{end + 1} = state;
            end
           
       end
            
   
    end
    
    methods (Access = protected)
        
        function setStates(this, ceStates)
           this.ceStates = {};
           for k = 1 : length(ceStates)
              this.push(ceStates{k});
           end  
        end
        
        function onScanComplete(this, unit, state)
            this.scan = [];
        end
        
        function onScanAbort(this, unit, state)
            this.scan = [];
        end
        
        function acquire(this, unit, state)
            % waitbar( this.scan.getCurrentStateIndex() / length(this.ceStates), this.hProgress);
            
        end
        
    end

end
