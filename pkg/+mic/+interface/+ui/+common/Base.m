classdef Base < mic.Base
    %BASE Summary of this class goes here
    %   Detailed explanation goes here
    
    methods (Abstract)
    
        % Build the UI on a figure or uipanel. 
        % mic.ui.common.* elements can be built in multiple places
        build(this, hParent, dLeft, dTop, dWidth, dHeight)
        
        
        % Remove a visible UI
        hide(this)
        
        % Show a hidden UI
        show(this)
        
        % @param {char 1xm}
        setTooltip(this, cTooltip)
        
        enable(this)
        disable(this)
        
    end
    
end

