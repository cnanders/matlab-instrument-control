classdef ActiveButton <  mic.ui.common.Base
    
    properties (Constant)

    end


    properties
    end


    properties (Access = private)
        
        % {function_handle 1x1} called on click
        fhOnClick
        
        % {function_handle 1x1} called on timer to update text of button
        fhGetText
        
        % {function_handle 1x1} called on timer to update color of button
        fhGetColor
        
        % {mic.Clock or mic.ui.Clock 1x1}
        clock
    end
    
    properties (SetAccess = private)
        
        cName = 'active-button-change-me'
        dDelay = 0.5
        
    end


    events
        

    end


    methods (Access = protected)
        
        function onClock(this)
            
            if ~ishandle(this.hUI)
                return
            end
            
            set(this.hUI, 'String', this.fhGetText());
            set(this.hUI, 'BackgroundColor', this.fhGetColor());

        end
                
        
    end
    
    methods
        
        function this = ActiveButton(varargin)
            
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
        end

        %% Methods
        function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
            
            this.hUI = uicontrol(...
                'Parent', hParent,...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent),...
                'Style', 'pushbutton',...
                'String', '...', ...
                'Callback', @(~, ~) this.fhOnClick() ...
             );

             this.clock.add(@this.onClock, this.id(), this.dDelay);
            
        end
        
       

    end

end