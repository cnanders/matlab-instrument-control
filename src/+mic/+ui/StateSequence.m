classdef StateSequence <  mic.ui.common.Base
    
    properties (Constant)

    end


    properties
    end


    properties (Access = private)
        
        % {< mic.StateSequence 1x1}
        state
        
        % {mic.Clock or mic.ui.Clock 1x1}
        clock
    end
    
    properties (SetAccess = private)
        
        cName = 'ui-state-sequence-change-me'
        dDelay = 0.5
        uiTextMain
        uiTextSub
        hPanel
        uiProgressBar
        uiButtonToggle
        
        % {uint8 24x24} images for play/pause
        u8Play = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'play-24.png'));
        u8Pause = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'pause-24.png'));
                
        dHeightProgressBar = 2
        
    end


    events
        

    end


    
    
    methods
        
        function this = StateSequence(varargin)
            
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
            dTop = 5;
            dSep = 16;
            
            this.uiTextMain.build(this.hPanel, dLeft, dTop, dWidth - 20, 16);
            dTop = dTop + dSep;
            
            %{
            this.uiTextSub.build(this.hPanel, dLeft, dTop, dWidth - 20, 16);
            dTop = dTop + dSep;
            %}
            
            this.uiProgressBar.build(this.hPanel, ...
                0, ...
                dHeight - this.dHeightProgressBar, ...
                dWidth - 24, ...
                this.dHeightProgressBar ...
            )
            this.uiProgressBar.hide();
            this.uiButtonToggle.build(this.hPanel, dWidth - 24, 0, 24, 24);
            

            this.clock.add(@this.onClock, this.id(), this.dDelay);
            
        end
        
       

    end
    
    methods (Access = protected)
        
        function onClock(this)
            
            if ~ishandle(this.hUI)
                return
            end
            
            if this.state.getProgress() == 1
                this.uiProgressBar.hide();
            end
            
            dColor = this.state.getColor();
            
            this.uiTextMain.set(this.state.getMessage());
            this.uiTextMain.setBackgroundColor(dColor);
            this.uiTextSub.setBackgroundColor(dColor);
            
            this.uiProgressBar.set(this.state.getProgress());
            
            
            set(this.hPanel, 'BackgroundColor', dColor);
            
            if this.state.isGoing()
                this.uiButtonToggle.set(true)
            else
                this.uiButtonToggle.set(false);
            end

        end
        
        
        function init(this)
            this.uiTextMain = mic.ui.common.Text('fhButtonDownFcn', @this.onPanelButtonDown);
            this.uiTextSub = mic.ui.common.Text('fhButtonDownFcn', @this.onPanelButtonDown);
            this.uiProgressBar = mic.ui.common.ProgressBar();
            
            this.uiButtonToggle = mic.ui.common.ButtonToggle( ...
                'lImg', true, ...
                'fhOnClick', @this.onUiButtonToggleClick, ...
                'u8ImgT', this.u8Pause, ... % pressed
                'u8ImgF', this.u8Play ...
            );
        
            
        end
        
        function onUiButtonToggleClick(this, ~, ~)
            
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
    end
    
    

end