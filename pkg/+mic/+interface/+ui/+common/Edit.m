classdef Edit < mic.interface.ui.common.Base
    
    methods (Abstract)
        
        % @return {mixed 1xm}
        x = get(this)
        
        % @param {mixed 1x1}
        set(this, x)
        
        
    end
    
end

