classdef ProgressBar < mic.interface.ui.common.Base
    
    methods (Abstract)
        
        % @return {double 1xm}
        d = get(this)
        
        % @param {double 1xm}
        set(this, d)
        
        
    end
    
end

