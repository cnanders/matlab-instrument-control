classdef ProgressBar < mic.Base
    
    properties (Constant)
       
    end
    
      
    properties
    end
    
            
    properties (SetAccess = private)
        
        % {double 1x1} value in [0: 1]
        dProgress = 0.3      
        dHeight = 10
        dWidth = 300
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
       
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.setProgress(this.dProgress)
            
       end
       
       function build(this, hParent, dLeft, dTop) 
                                  
            this.hPanelBg =  uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'BackgroundColor', this.dColorBg, ...
                'BorderWidth', 0, ...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
        
        
            this.hPanelFill =  uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'BackgroundColor', this.dColorFill,...
                'BorderWidth', 0, ...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
                
            this.hText = uicontrol( ...
                'Parent', hParent, ...
                'HorizontalAlignment', 'right', ...
                'FontWeight', this.cWeightFont, ...
                'FontSize', this.dSizeFont, ...
                'ForegroundColor', this.dColorFont, ...
                'BackgroundColor', this.dColorBg,...
                'Position', mic.Utils.lt2lb([dLeft + this.dWidth dTop this.dWidthText this.dHeight], hParent), ...
                'Style', 'text', ...
                'String', '0%'...
                );
            
        
            this.setProgress(0);
           
       end
       
       function setProgress(this, dVal)
           
           this.dProgress = dVal;
           
           if ishandle(this.hPanelFill)
           
               dPosition = get(this.hPanelFill, 'Position');
               dWidth = this.dWidth * this.dProgress;
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
                set(this.hText, 'String', sprintf('%1.1f%%', this.dProgress * 100));
           end
           
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