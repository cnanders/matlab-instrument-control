classdef GetSetLogical < mic.interface.device.GetSetLogical

    % deviceVirtual

    properties (Access = private)
        lVal = false
        lIsInitialized = false
    end


    properties
        
    end

            
    methods
        
        function this = GetSetLogical(varargin)
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end

        end

        function lReturn = get(this)
            % this.msg(sprintf('get() = %1.0f', this.lVal));
            lReturn = this.lVal;
        end


        function set(this, lVal)
            % this.msg(sprintf('set(%1.0f)', lVal));
            this.lVal = lVal;
        end 
        
        function initialize(this)
            this.lIsInitialized = true;
        end

        function l = isInitialized(this)
           l = this.lIsInitialized;
        end


    end %methods
end %class
    

            
            
            
        