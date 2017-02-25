classdef GetSetText < mic.interface.device.GetSetText

    properties (Access = private)
        cVal = '...';
        lIsInitialized = false;
    end


    properties

    end
            
    methods
        
        function this = GetSetText()

        end

        function c = get(this)
            c = this.cVal;
        end

        function set(this, cVal)
            this.cVal = cVal;
        end
        
        function initialize(this)
            this.lIsInitialized = true;
        end

        function l = isInitialized(this)
           l = this.lIsInitialized;
        end

    end %methods
end %class
    

            
            
            
        