classdef Text < mic.interface.ui.common.Base
    
    methods (Abstract)
        
        % @return {char 1xm}
        c = get(this)
        
        % @param {char 1xm}
        set(this, c)
        
        
    end
    
end

