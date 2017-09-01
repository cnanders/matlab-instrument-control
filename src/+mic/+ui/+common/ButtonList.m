classdef ButtonList < mic.Base
        
    properties (Constant)
       
         cLAYOUT_BLOCK = 'block'
         cLAYOUT_INLINE = 'inline'

    end
    
    
	properties
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = protected)
         
        dWidthButton = 200
        dHeightButton = 24
        
        dHeightPad = 5
        dHeightPadTop = 20
        dHeightPadBottom = 10
        
        dWidthPadLeft = 10
        dWidthPadRight = 10
        
        dWidthPad = 10
        
        dWidthBorderPanel = 1
        
        cTitle = 'Button List'
        
        % {char 1xm} this.cLAYOUT_INLINE | this.cLAYOUT_BLOCK
        cLayout
        
        hPanel
        
        % {mic.ui.common.Button 1xn}
        uiButtons = mic.ui.common.Button.empty
        
        % @typedef {struct 1x1} Button
        % @property {char 1xm} cLabel - label of the button
        % @property {function_handle 1x1} fhOnClick - function that is called 
        % when button is clicked.  Must return logical to indicate if the
        % action was successfull or not
        % %property {char 1xm} cTooltip - tooltip of the button
        
        % {struct 1xn} stButtonDefinitions - list of button definition
        % structures
        stButtonDefinitions

    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = ButtonList(varargin)
            
            % default this.stButtonDefinitions
                        
            stButton1 = struct(...
                'cLabel', 'Button 1', ...
                'fhOnClick', @this.onClickDefault1, ...
                'cTooltip', 'Button 1 Tooltip' ...
            );
        
            stButton2 = struct(...
                'cLabel', 'Button 2', ...
                'fhOnClick', @this.onClickDefault2, ...
                'cTooltip', 'Button 2 Tooltip' ...
            );
            
            this.stButtonDefinitions = [stButton1 stButton2];
            
            % Default layout
            
            this.cLayout = this.cLAYOUT_BLOCK;
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
             
            u8Num = length(this.stButtonDefinitions);
            switch this.cLayout
                case this.cLAYOUT_BLOCK
                    dHeight = this.dHeightPadTop + ...
                        u8Num * this.dHeightButton + ...
                        (u8Num - 1) * this.dHeightPad + ...
                        this.dHeightPadBottom;

                    dWidth = this.dWidthPadLeft + ...
                        this.dWidthButton + ...
                        this.dWidthPadRight;

                    this.hPanel = uipanel(...
                        'Parent', hParent,...
                        'Units', 'pixels',...
                        'Title', this.cTitle,...
                        'Clipping', 'on',...
                        'BorderWidth', this.dWidthBorderPanel, ...
                        'Position', mic.Utils.lt2lb([ ...
                        dLeft ...
                        dTop ...
                        dWidth ...
                        dHeight], hParent) ...
                    );

                    drawnow;

                    dTop = this.dHeightPadTop;
                    dLeft = this.dWidthPadLeft;

                    for n = 1 : u8Num
                        this.uiButtons(n).build(this.hPanel, dLeft, dTop, this.dWidthButton, this.dHeightButton);
                        this.uiButtons(n).setTooltip(this.stButtonDefinitions(n).cTooltip);
                        dTop = dTop + this.dHeightButton + this.dHeightPad;
                    end
                case this.cLAYOUT_INLINE
                    
                    dHeight = this.dHeightPadTop + ...
                        this.dHeightButton + ...
                        this.dHeightPadBottom;

                    dWidth = this.dWidthPadLeft + ...
                        u8Num * this.dWidthButton + ...
                        (u8Num - 1) * this.dWidthPad + ...
                        this.dWidthPadRight;

                    this.hPanel = uipanel(...
                        'Parent', hParent,...
                        'Units', 'pixels',...
                        'Title', this.cTitle,...
                        'Clipping', 'on',...
                        'BorderWidth', this.dWidthBorderPanel, ...
                        'Position', mic.Utils.lt2lb([ ...
                        dLeft ...
                        dTop ...
                        dWidth ...
                        dHeight], hParent) ...
                    );

                    drawnow;

                    dTop = this.dHeightPadTop;
                    dLeft = this.dWidthPadLeft;

                    for n = 1 : u8Num
                        this.uiButtons(n).build(this.hPanel, dLeft, dTop, this.dWidthButton, this.dHeightButton);
                        this.uiButtons(n).setTooltip(this.stButtonDefinitions(n).cTooltip);
                        dLeft = dLeft + this.dWidthButton + this.dWidthPad;
                    end
                    
            end
        
        end
        
                        
        %% Destructor
        
        function delete(this)
            this.msg('delete', this.u8_MSG_TYPE_CLASS_INIT_DELETE);
        end    
        
        
        function setButtonColorBackground(this, n, dValue)
            this.uiButtons(n).setColorBackground(dValue);
        end

    end
    
    methods (Access = protected)
        
        function onUiButtonClick(this, src, evt, n)
            cMsg = sprintf('onUiButtonClick(%1.0f)', n);
            this.msg(cMsg);
            this.stButtonDefinitions(n).fhOnClick();
        end
                
        function init(this)
            for n = 1 : length(this.stButtonDefinitions)
                this.uiButtons(n) = mic.ui.common.Button('cText', this.stButtonDefinitions(n).cLabel);
                addlistener(this.uiButtons(n), 'eChange', @(src, evt) this.onUiButtonClick(src, evt, n));
            end
        end
        
        
        function l = onClickDefault1(this)
            l = true;
            cMsg = sprintf('onClickDefault1');
            this.msg(cMsg);
        end
        
        function l = onClickDefault2(this)
            l = true;
            cMsg = sprintf('onClickDefault2');
            this.msg(cMsg);
        end
        
    end % private
    
    
end