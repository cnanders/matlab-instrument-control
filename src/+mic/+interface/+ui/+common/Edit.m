classdef Edit < mic.interface.ui.common.Base
    
    methods (Abstract)
        
        % @return {mixed 1xm}
        x = get(this)
        
        % @param {mixed 1x1}
        set(this, x)

        % @return {struct 1x1} the state to save
        st = save(this)

        % @para {struct 1x1} st - the state to load (must match signature
        % returned by save)
        load(this, st)
        
        
    end
    
end

