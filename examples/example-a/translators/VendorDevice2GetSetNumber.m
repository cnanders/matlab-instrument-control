classdef VendorDevice2GetSetNumber < mic.interface.device.GetSetNumber

    properties (Access = private)
        device
        cProp
    end
    
    methods
        
        function this = VendorDevice2GetSetNumber(device, cProp)
            this.device = device;
            this.cProp = cProp;
        end
        
        function d = get(this)
            switch this.cProp
                case 'x'
                    d = this.device.getXPosition();
                case 'y'
                    d = this.device.getYPosition();
            end
            
        end
        
        function set(this, dVal)
            switch this.cProp
                case 'x'
                    this.device.setXPosition(dVal);
                case 'y'
                    this.device.setYPosition(dVal);
            end
            
        end
        
        function l = isReady(this)
            l = true;
        end
        
        function stop(this)
            
        end
        
        function initialize(this)
            
        end
        
        function l = isInitialized(this)
            l = true;
        end
        
        function index(this)
            
        end

        
    end
        
    
end

