classdef GetText < mic.interface.device.GetText

    properties (Access = private)
        cVal = '...';
        lIsInitialized = false;
        
        cecValues = {
            'Val 1', ...
            'Val 2', ...
            'Val 3' ...
        }
    end


    properties

    end
            
    methods
        
        function this = GetText()

        end

        function c = get(this)
            u8Idx = ceil(rand(1) * 3);
            c = this.cecValues{u8Idx};            
        end
        
        function initialize(this)
            this.lIsInitialized = true;
        end

        function l = isInitialized(this)
           l = this.lIsInitialized;
        end

    end %methods
end %class
    

            
            
            
        