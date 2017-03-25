classdef Logical < mic.interface.ui.common.Base
    
    methods (Abstract)
        
        % @return {logical 1x1}
        l = get(this)
        
        % @param {logical 1x1}
        set(this, l)

        % @return {struct 1x1} the state to save
        st = save(this)

        % @para {struct 1x1} st - the state to load (must match signature
        % returned by save)
        load(this, st)
        
        
    end
    
end

