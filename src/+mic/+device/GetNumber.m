classdef GetNumber < mic.interface.device.GetNumber


    properties (Access = protected)
        
        
        % {mic.Clock 1x1}
        clock
        
        % {double 1x1} clock period (s)
        dPeriod = 0.5
        
        % {double 1x1} mean value
        dMean = 0 
        
        % {double 1x1} standard deviation of value
        dSig = 0.1
        
        % {double 1x1} the value (updated onClock)
        dVal = 0 
        
        % {logical 1x1} if the initialize command has been called
        lIsInitialized
    end


    properties

        cName
        

    end

            
    methods
        
        function this = GetNumber(varargin)
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.clock.add(@this.onClock, this.id(), this.dPeriod);

        end

        function dReturn = get(this)
            dReturn = this.dVal;
        end

        
            
        function delete(this)

            this.msg('DevicevHardwareO.delete()');

            % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end

        end
        
        
        function initialize(this)
            this.lIsInitialized = true;
        end
        
        function l = isInitialized(this)
            l = this.lIsInitialized;
        end

    end %methods
    
    methods (Access = protected)
        
        function onClock(this)
            this.dVal = this.dMean + this.dSig * randn(1);
        end
        
    end
end %class
    

            
            
            
        