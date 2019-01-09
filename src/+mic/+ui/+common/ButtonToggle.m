classdef ButtonToggle < mic.interface.ui.common.Logical & mic.ui.common.Base

    % uibt
    
    % 2014.11.19 CNA
    % This is a hybrid of a button and a toggle.  The idea is you want a
    % button that can have two visual states and a property that indicates
    % which visual state it is showing.  The difference between it and a
    % toggle is that clicking it doesn't actually change its visual state.
    % The visual state can only be changed programatically.  This is used
    % for the play/pause button of HardwareIO

    properties (Constant)

    end


    properties
       
        

    end


    properties (Access = private)
        lVal = false            % true/false
        cTextT = 'True'         % "True" text
        cTextF = 'False'        % "False" text
        u8ImgT = uint8(0)         % "True" image
        u8ImgF = uint8(0)         % "False" image
        lImg = false          % use image?
        lAsk = false
        cMsg = 'Are you sure you want to do that?'
        
        % {function_handle 1x1} is called any time eChange is emitted (if
        % is not null)
        fhOnClick = @(src, evt)[];
    end


    events
        eChange  
    end


    methods
        %% constructor
        % LEGACY ORDER cTextT, cTextF,lImg,u8ImgT,u8ImgF,lAsk,cMsg
        function this = ButtonToggle(varargin)

            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
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
                'TooltipString', this.cTooltip, ...
                'Callback', @this.cb ...
                );
            
            % Set to update button image
            this.set(this.lVal)
            
        end

        %% Event handlers
        function cb(this, src, evt)
           switch src
               case this.hUI
                    if this.lAsk
                        % ask
                        cAns = questdlg(this.cMsg, 'Warning', 'Yes', 'Cancel', 'Cancel');
                        switch cAns
                            case 'Yes'
                                notify(this,'eChange');
                                this.fhOnCLick();

                            otherwise
                                return
                        end  

                    else
                        notify(this,'eChange');
                        this.fhOnClick();
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
        
        function l = get(this)
            l = this.lVal;
        end
            
            
        function set(this, l)
            
            % this.msg('set.lVal');
            
            this.lVal = l;  
            
            if this.lImg
                
                % Using image
                if this.lVal
                    set(this.hUI, 'CData', this.u8ImgT);
                else
                    set(this.hUI, 'CData', this.u8ImgF);
                end
                    
            else
                % Use text
                if this.lVal
                    set(this.hUI, 'String', this.cTextT);
                else
                    set(this.hUI, 'String', this.cTextF);
                end
            end
                        
            
        end

        % @return {struct} state to save
        function st = save(this)
            st = struct();
            st.lVal = this.get();
        end
        
        % @param {struct} state to load
        function load(this, st)
            this.set(st.lVal);
        end

        
        

    end

end