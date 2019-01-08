classdef State <  mic.ui.common.Base
    
    properties (Constant)

    end


    properties
    end


    properties (Access = private)
        
        % {< mic.State || mic.StateSequence 1x1}
        state
        
        % {mic.Clock or mic.ui.Clock 1x1}
        clock
    end
    
    properties (SetAccess = private)
        
        cName = 'ui-state-change-me'
        dDelay = 0.5
        
        hPanel
        uiTextMain
        uiTextSub
        uiProgressBar
        uiButton
        
        dHeightProgressBar = 5
        
        % {uint8 24x24} images for play/pause
        u8Play = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'play-24.png'));
        u8Pause = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'pause-24.png'));
        u8Check = imread(fullfile(mic.Utils.pathImg(), 'check-green-24-2.png'));

        lShowPlay = true
        
    end


    events
        

    end


    
    
    methods
        
        function this = State(varargin)
            
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
        

        %% Methods
        function build(this, hParent, dLeft, dTop, dWidth) 
            
            
            dHeight = 24;
            
             this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', '',...
                'Clipping', 'on',...
                'ButtonDownFcn', @this.onPanelButtonDown, ...
                'Position', mic.Utils.lt2lb(...
                    [ ...
                        dLeft ...
                        dTop ...
                        dWidth ...
                        dHeight ...
                    ], ...
                    hParent ...
                ) ...
            );
        
            dLeft = 10;
            dTop = 4;
            dSep = 16;
            
            this.uiTextMain.build(this.hPanel, dLeft, dTop, dWidth - 20, 16);
            dTop = dTop + dSep;
            
            %{
            this.uiTextSub.build(this.hPanel, dLeft, dTop, dWidth - 20, 16);
            dTop = dTop + dSep;
            %}
            
            %{
            if (this.lShowPlay)
                dWidthProgressBar = dWidth - 25;
            else
                dWidthProgressBar = dWidth;
            end
            %}
            
            dWidthProgressBar = dWidth - 25;
            
            this.uiProgressBar.build(this.hPanel, ...
                0, ...
                dHeight - this.dHeightProgressBar, ...
                dWidthProgressBar, ...
                this.dHeightProgressBar ...
            )
            this.uiProgressBar.hide();
            
            if (this.lShowPlay)
                this.uiButton.build(this.hPanel, dWidth - 25, 1, 24, 24);
            end
            

            this.clock.add(@this.onClock, this.id(), this.dDelay);
            
        end
        
       

    end
    
    methods (Access = protected)
        
        function onClock(this)
            
            if ~ishandle(this.hUI)
                return
            end
                        
            dColor = this.getColor();
            
            this.uiTextMain.set(this.state.getMessage());
            this.uiTextMain.setBackgroundColor(dColor);
            this.uiTextSub.setBackgroundColor(dColor);
            this.uiProgressBar.set(this.state.getProgress());            
            set(this.hPanel, 'BackgroundColor', dColor);
            
            
            if this.state.isGoing()
                this.uiButton.setU8Img(this.u8Pause)
            elseif this.state.isThere()
                this.uiButton.setU8Img(this.u8Check)
            else
                this.uiButton.setU8Img(this.u8Play)
            end
            
            if this.state.isGoing()
                this.uiProgressBar.show();
            else
                this.uiProgressBar.hide();
            end
            


        end
        
        
        
        function init(this)
            this.uiTextMain = mic.ui.common.Text('fhButtonDownFcn', @this.onPanelButtonDown);
            this.uiTextSub = mic.ui.common.Text('fhButtonDownFcn', @this.onPanelButtonDown);
            this.uiProgressBar = mic.ui.common.ProgressBar();
            
            
        
            this.uiButton = mic.ui.common.Button( ...
                'lImg', true, ...
                'fhOnClick', @this.onUiButtonClick, ...
                'u8Img', this.u8Play ...
            );
        
            
        end
        
        function onUiButtonClick(this, ~, ~)
            
            if this.state.isThere()
                return;
            end
            
            if this.state.isGoing()
                this.state.stop();
                this.uiProgressBar.hide();
                return;
            end
            
            this.state.go();
            this.uiProgressBar.show();
            
        end
        
        function onPanelButtonDown(this, ~, ~)
            
            
            
        end 
        
        function d = getColor(this)
           d = mic.Utils.ifElse(...
               this.state.isGoing(), [1 1 0.85], ...
               this.state.isThere(), [.85, 1, .85], ...
               [1, .85, .85] ...
           );           
       end
        
        
        
    end
    
    

end