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
        
        dWidth = 0;
        fhButtonDownFcn = @(src, evt)[]

    end
    
    
    events

    end
    
    
    methods
        
       % constructor 
       % legacy args: cVal, cAlign, cFontWeight, dFontSize
       
       function this = Text(varargin)
               
           this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
           
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
       end
       
       % Returns the width
       
       function d = getWidth(this)
           d = this.dWidth;
       end
       
       function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
              
           this.dWidth = dWidth;
           
            if this.lShowLabel
                this.hLabel = uicontrol( ...
                    'Parent', hParent, ...
                    'Position', mic.Utils.lt2lb([dLeft dTop dWidth 20], hParent),...
                    'Style', 'text', ...
                    'String', this.cLabel, ...
                    'FontWeight', 'Normal',...
                    'BackgroundColor', this.dColorBg, ...
                    'ButtonDownFcn', @this.fhButtonDownFcn, ...
                    'Callback', @this.fhButtonDownFcn, ...
                    ... %'Enable', 'Off', ... % allows left click to fire ButtonDownFcn
                    'HorizontalAlignment', 'left' ...
                );

                %'BackgroundColor', [1 1 1] ...
            
                dTop = dTop + 13;
            end
            
            this.hUI = uicontrol( ...
                'Parent', hParent, ...
                'HorizontalAlignment', this.cAlign, ...
                'FontWeight', this.cFontWeight, ... 
                'FontSize', this.dFontSize, ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                'Style', 'text', ...
                'Callback', @this.fhButtonDownFcn, ...
                'ButtonDownFcn', @this.fhButtonDownFcn, ...  % allows left click to fire ButtonDownFcn
                'BackgroundColor', this.dColorBg, ...
                'TooltipString', this.cTooltip, ...
                ... %'Enable', 'Off', ...
                'String', this.cVal ...
                );
            
            if ~this.lEnabled
                this.disable();
            end

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
        
        function setFontSize(this, dFontSize)
            if ~ishandle(this.hUI)
                return
            end
            set(this.hUI, 'FontSize', dFontSize)
        end
        
        function setAlign(this, cAlign)
            if ~ishandle(this.hUI)
                return
            end
            set(this.hUI, 'HorizontalAlignment', cAlign)
        end
        
        function delete(this)
            cMsg = sprintf('delete() %s', this.cVal);
            % this.msg(cMsg);
        end
        
        % @return {struct} state to save
        function st = save(this)
            st = struct();
            st.cVal = this.cVal;
        end
        
        % @param {struct} state to load
        function load(this, st)
            if isfield(st, 'cVal')
                this.set(st.cVal)
            end
        end
       
       
        
    end
end