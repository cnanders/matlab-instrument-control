% Defers the execution of an "action" until a "trigger condition" is met.  This is useful when
% we need to wait for the completion of some asynchronous event (e.g., stage moving,
% stage homing) before executing subsequent actions.
%
% Instantiate a DeferredActionScheduler with function handle properties: 
%   fhTrigger: function that evaluates to true when a condtion is met
%   fhAction: function to be executed when trigger evaluates to true
%   fhExpire: function to be executed when scheduler times out 
%   clock: uses internal clock if this parameter is empty
%   dDelay: how often to check fhTrigger

classdef DeferredActionScheduler < mic.Base
    
    properties
        % Function to be called when trigger evaluates to true
        fhAction = @()[]
        
        % Evaluates to logical
        fhTrigger = @()true
        
        fhOnExpire = @()[]
        
        % DAS name
        cName = 'DAS_task'
        
        % Optional:
        clock = []
        dDelay = 1
        
        u64Tic
        
        % Expiration in seconds
        dExpiration = 10
        lShowExpirationMessage = false
    end
    
    methods
         function this = DeferredActionScheduler(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
                
                % If there's no clock, initialize default one:
                if isempty(this.clock)
                    this.initDefaultClock();
                end
            end
         end
        
         % Dispatch deferred action
         function dispatch(this)
              this.u64Tic = tic;
              this.clock.add(@this.scheduleLambda, this.cName, this.dDelay);
         end
        
         function abort(this)
              this.clock.remove(this.cName);
         end
        
    end
    
    methods (Access = protected)
        function initDefaultClock(this)
             this.clock = mic.Clock('DeferredActionScheduler');
        end
        
        function scheduleLambda(this)
            if this.fhTrigger()
                this.clock.remove(this.cName);
                this.fhAction();
            end
            
            if (toc(this.u64Tic) > this.dExpiration)
                this.clock.remove(this.cName);
                if this.lShowExpirationMessage
                    msgbox(sprintf('DAF: Task %s timed out after %0.1f s', this.cName, this.dExpiration));
                end
                this.fhOnExpire();
            end
        end
        
    end
    
    
end