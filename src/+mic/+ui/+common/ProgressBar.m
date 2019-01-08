classdef ProgressBar < mic.interface.ui.common.ProgressBar & mic.ui.common.Base
    
    properties (Constant)
       
    end
    
      
    properties
    end
    
            
    properties (SetAccess = private)
        
        % {double 1x1} value in [0: 1]
        dVal = 0.3      
        lShowText = false
    end
    
    
    properties (Access = private)        
        
        dColorBg = [0.7 0.7 0.7]
        dColorFill = [0 0.6 0]
        dColorFont = [0 0 0]
        dWidthText = 50
        cWeightFont = 'normal'
        dSizeFont = 10
        
        hText
        hPanelBg
        hPanelFill
        
    end
    
    
    events

    end
    
    
    methods
        
       % constructor
       
       function this = ProgressBar(varargin)
       
           this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.set(this.dVal)
            
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
                                  
            this.hPanelBg =  uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'BackgroundColor', this.dColorBg, ...
                'BorderWidth', 0, ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent) ...
            );
        
        
            this.hPanelFill =  uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'BackgroundColor', this.dColorFill,...
                'BorderWidth', 0, ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent) ...
            );
                
            if this.lShowText
                this.hText = uicontrol( ...
                    'Parent', hParent, ...
                    'HorizontalAlignment', 'right', ...
                    'FontWeight', this.cWeightFont, ...
                    'FontSize', this.dSizeFont, ...
                    'ForegroundColor', this.dColorFont, ...
                    'BackgroundColor', this.dColorBg,...
                    'Position', mic.Utils.lt2lb([dLeft + dWidth dTop this.dWidthText dHeight], hParent), ...
                    'Style', 'text', ...
                    'String', '0%'...
                    );
            end
            
        
            this.set(0);
           
       end
       
       
       function d = get(this)
           d = this.dVal;
       end
       
       function set(this, dVal)
           
           this.dVal = dVal;
           
           if ishandle(this.hPanelFill)
           
               dPositionOfPanel = get(this.hPanelBg, 'Position');
               dWidthOfPanel = dPositionOfPanel(3);
               
               dPosition = get(this.hPanelFill, 'Position');
               dWidth = dWidthOfPanel * this.dVal;
               if dWidth < 1
                   dWidth = 1;
               end
               
               %LTWH
               set(this.hPanelFill, 'Position', ...
                   [dPosition(1) dPosition(2)  dWidth dPosition(4)]);
               
               %{
               dPosition = get(this.hText, 'Position');
               set(this.hText, 'Position', ...
                   [dWidth - this.dWidthText dPosition(2) dPosition(3) dPosition(4)]);
               %}
           end
           
           
           if ishandle(this.hText)
                set(this.hText, 'String', sprintf('%1.1f%%', this.dVal * 100));
           end
           
       end
       
       function setColor(this, dColor)
            this.dColorFill = dColor;
            this.hPanelFill.BackgroundColor = dColor;
       end
              
       
       function show(this)
    
            if ishandle(this.hPanelBg)
                set(this.hPanelBg, 'Visible', 'on');
            end
            
            if ishandle(this.hPanelFill)
                set(this.hPanelFill, 'Visible', 'on');
            end
            
            if ishandle(this.hText)
                set(this.hText, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanelBg)
                set(this.hPanelBg, 'Visible', 'off');
            end
            
            if ishandle(this.hPanelFill)
                set(this.hPanelFill, 'Visible', 'off');
            end
            
            if ishandle(this.hText)
                set(this.hText, 'Visible', 'off');
            end

        end
               
    end
end