classdef Button < mic.interface.ui.common.Button & mic.ui.common.Base
    % uib
    % Button(cText, lImg, u8Img, lAsk, cMsg)

    properties (Constant)

    end


    properties
    end


    properties (Access = private)
        cText = 'Fix Me'
        u8Img = []          % image cdata
        lImg = false            % use image?
        lAsk = false
        cMsg = 'Are you sure you want to do that?'
        
        % {function_handle 1x1} is called any time eChange is emitted (if
        % is not null)
        fhOnClick = @(src, evt)[];
        
        % {function_handle 1x1} is called any time eChange is emitted 
        % need to deprecate fhOnClick
        fhDirectCallback = @(src, evt)[];
    end
    


    events
        
        % When it is pressed. Always
        ePress
        
        % Fired in two situations
        % 1. If confirmation dialog approval is required and the user
        % authorizes
        % 2. If confirmation dialog approval is not required and the user
        % presses.
        eChange
        
        
    end


    
    methods
        %% constructor 
        % LEGACY cText, lImg, u8Img, lAsk, cMsg
        function this = Button(varargin)
            
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
                
            end
            
            % this.lImg = false; % Temp performance check 2018.09.10

        end

        %% Methods
        function build(this, hParent, dLeft, dTop, dWidth, dHeight) 
            this.hUI = uicontrol(...
                'Parent', hParent,...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent),...
                'Style', 'pushbutton',...
                'TooltipString', this.cTooltip, ...
                'Callback', @this.cb ...
             );

            if this.lImg
                set(this.hUI, 'CData', this.u8Img);
            else
                set(this.hUI, 'String', this.cText);
            end

        end
        
        function setText(this, cText)
            if ~ishandle(this.hUI)
                return
            end
            set(this.hUI, 'String', cText);
        end
        
        function setColor(this, dColor)
            if ~ishandle(this.hUI)
                return
            end
            set(this.hUI, 'BackgroundColor', dColor);
        end

        %% Event handlers
        function cb(this, src, evt)
           switch src
               case this.hUI
                    notify(this, 'ePress');
                    if this.lAsk
                        % ask
                        cAns = questdlg(this.cMsg, 'Warning', 'Yes', 'Cancel', 'Cancel');
                        switch cAns
                            case 'Yes'
                                this.fhOnClick(this, evt);
                                this.fhDirectCallback(this, evt);
                                notify(this,'eChange');

                            otherwise
                                return
                        end  

                    else
                        
                        this.fhOnClick(this, evt);
                        this.fhDirectCallback(this, evt);
                        notify(this,'eChange');
                    end
           end
        end
        
       
        
        function lReturn = isVisible(this)
            
            if ishandle(this.hUI)
                switch get(this.hUI, 'Visible')
                    case 'on'
                        lReturn = true;
                    otherwise
                        lReturn = false;
                end
            else
                lReturn = false;
            end
            
        end
            
        
        %AW2013-7-17 : addded a setter to update the image
        function setU8Img(this, value)
            
            if ishandle(this.hUI) 
                this.u8Img = value;
                set(this.hUI, 'CData', this.u8Img);
            end
        end
        
        % @param {double 1x3} dColor - RGB triplet, i.e., [1 1 0] [0.5 0.5
        % 0]
        function setColorOfBackground(this, dValue)
            
            if ~ishandle(this.hUI)
                return
            end
            
            set(this.hUI, 'BackgroundColor', dValue) 
            
        end
        
        % @param {double 1x3} dColor - RGB triplet, i.e., [1 1 0] [0.5 0.5
        % 0]
        function setColorText(this, dValue)
            
            if ~ishandle(this.hUI)
                return
            end
            
            set(this.hUI, 'ForegroundColor', dValue)
            
            
        end
        
       
        

    end

end