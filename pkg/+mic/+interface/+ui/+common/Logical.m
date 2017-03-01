classdef Logical < mic.interface.ui.common.Base
    
    methods (Abstract)
        
        % @return {logical 1x1}
        l = get(this)
        
        % @param {logical 1x1}
        set(this, l)
        
        
    end
    
end

