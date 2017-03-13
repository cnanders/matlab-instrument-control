classdef Base < mic.Base
    
    % Implements show, hide, enable, disable, which are common to
    % mic.ui.common.*
   
    properties (Access = protected)
        hUI
        cTooltip = 'Tooltip: set me!';
    end

    methods
        
        function this = Base()

        end
        
        function show(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'on');
            end
        end

        function hide(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'off');
            end
        end
        
        
        function setTooltip(this, cText)
            this.cTooltip = cText;
            if ishandle(this.hUI)        
                set(this.hUI, 'TooltipString', this.cTooltip);
            end
        end
        
        function enable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'on');
            end
        end
        
        function disable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'off');
            end
            
        end

    end

end