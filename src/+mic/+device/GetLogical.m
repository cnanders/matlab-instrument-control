classdef GetLogical < mic.interface.device.GetLogical

    % deviceVirtual

    properties (Access = private)
        
        lIsInitialized = false
    end


    properties
        
    end

            
    methods
        
        function this = GetLogical(varargin)
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end

        end

        function l = get(this)
            % this.msg(sprintf('get() = %1.0f', this.lVal));
            l = logical(round(rand(1)));
        end
        
        function initialize(this)
            this.lIsInitialized = true;
        end

        function l = isInitialized(this)
           l = this.lIsInitialized;
        end


    end %methods
end %class
    

            
            
            
        