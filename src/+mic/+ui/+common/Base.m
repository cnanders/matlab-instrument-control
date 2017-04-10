classdef Base < mic.Base
    
    % Implements show, hide, enable, disable, which are common to
    % mic.ui.common.*
   
    properties (Access = protected)
        hUI
        hLabel
        cTooltip = 'Tooltip: set me!';
    end

    methods
        
        function this = Base()

        end
        
        function show(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'on');
            end
            
            if ishandle(this.hLabel)
                set(this.hLabel, 'Visible', 'on');
            end
        end

        function hide(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Visible', 'off');
            end
            
            if ishandle(this.hLabel)
                set(this.hLabel, 'Visible', 'off');
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
            
            if ishandle(this.hLabel)
                set(this.hLabel, 'Enable', 'on');
            end
        end
        
        function disable(this)
            if ishandle(this.hUI)
                set(this.hUI, 'Enable', 'off');
            end
            
            if ishandle(this.hLabel)
                set(this.hLabel, 'Enable', 'off');
            end
            
        end

    end

end