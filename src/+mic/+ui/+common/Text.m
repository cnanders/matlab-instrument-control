classdef Text < mic.interface.ui.common.Text & mic.ui.common.Base
    
    % uitx
    
    % meant to be inside of a panel.  Matlab makes the default background
    % color of a uicontrol('text') the same as panels
    
    properties (Constant)
       
    end
    
      
    properties
        
    end
    
    
    properties (Access = private)
        cLabel = 'cLabel'
        cVal = 'cVal'
        cAlign = 'left'
        cFontWeight = 'normal'
        dFontSize = 10
        dColorBg = [.94 .94 .94]; % MATLAB default
        
        lShowLabel = false;
    end
    
    
    events

    end
    
    
    methods
        
       % constructor cVal, cAlign, cFontWeight, dFontSize
       
       function this = Text(varargin)
                       
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
              
            if this.lShowLabel
                this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', mic.Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'BackgroundColor', this.dColorBg, ...
                    'HorizontalAlignment', 'left' ...
                );

                %'BackgroundColor', [1 1 1] ...
            
                dTop = dTop + 13;
            end
            
            this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'HorizontalAlignment', this.cAlign, ...
                'FontWeight', this.cFontWeight, ... % 'FontSize', this.dFontSize, ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'text', ...
                'BackgroundColor', this.dColorBg, ...
                'TooltipString', this.cTooltip, ...
                'String', this.cVal ...
                );

       end
       
       function c = get(this)
           c = this.cVal;
       end
       
       function set(this, cVal)
           
           % prop
           if ischar(cVal)
               this.cVal = cVal;
           else
               cMsg = sprintf('Text.set.cVal() requires type "char".  You supplied type "%s".  Not overwriting the cVal property.', ...
                   class(cVal) ...
                   );
               cTitle = 'Text.set.sVal() error';
               % msgbox(cMsg, cTitle, 'warn');
               error(cMsg);
           end
           
           % ui
           if ~isempty(this.hUI) && ishandle(this.hUI)
               set(this.hUI, 'String', this.cVal);
           end
           
           drawnow;
            
           
       end
       
       
       
        
        % @param {double 1x3} dColor - RGB triplet, i.e., [1 1 0] [0.5 0.5
        % 0]
        function setBackgroundColor(this, dColor)
            
           if ~ishandle(this.hUI)
                return
            end
            
            set(this.hUI, 'BackgroundColor', dColor) 
        end
        
        % @param {double 1x3} dColor - RGB triplet, i.e., [1 1 0] [0.5 0.5
        % 0]
        function setColor(this, dColor)
            
            if ~ishandle(this.hUI)
                return
            end
            
            set(this.hUI, 'ForegroundColor', dColor)
            
        end
        
        
        
        function delete(this)
            cMsg = sprintf('delete() %s', this.cVal);
            % this.msg(cMsg);
        end
       
       
        
    end
end