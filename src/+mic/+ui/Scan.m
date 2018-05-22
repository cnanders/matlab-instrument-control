classdef Scan < mic.Base
    
    properties (Constant)
        
        
        
    end
    
    properties (Access = private)
        
       dHeight = 95
       dWidth = 240
       
       dWidthButton = 60
       dHeightButton = 24
       
       hPanel
       
       uiTextLabelStatus
       uiTextLabelTimeElapsed
       uiTextLabelTimeRemaining
       uiTextLabelTimeComplete
       
       uiTextStatus
       uiTextTimeElapsed
       uiTextTimeRemaining
       uiTextTimeComplete
       
       dWidthLabel = 60
       dWidthValue = 100;
       dHeightText = 16;
       dHeightPadText = 0
       
       dHeightPadPanel = 20
       dWidthPadPanel = 10 
       dWidthBorderPanel = 1
       cTitle = 'Scan Control'
       
       uiTogglePause
       uiButtonAbort
       uiButtonStart
       
       lDisableNotify = false
       
       % Eventually there should be callbacks passed in that call out to
       % the mic.Scan class on a timer and update these values.  The
       % buttons in this UI should serve as a "request" to the scan but the
       % state of the scan should dictate what the buttons show.
       
       % {logical 1x1} - true when paused
        lPaused = false;

        % {logical 1x1} - true when stop command is called, set to false
        % when start() is called
        lStopped = true;

    end
    
    events
      
      eAbort
      ePause
      eResume
      eStart
      
    end
    
    methods
        
        function this = Scan(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            this.init();
        end  
        
        
        function build(this, hParent, dLeft, dTop)
            
            
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cTitle,...
                'BorderWidth', this.dWidthBorderPanel, ...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
        
            drawnow;
            dLeft = 10;
            dTop = this.dHeightPadPanel;
            
            
            this.uiButtonStart.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton ...
            );
        
            this.uiTogglePause.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton ...
            );
            %dLeft = dLeft + this.dWidthButton + this.dWidthPadH;
            dTop = dTop + this.dHeightButton;
            
            this.uiButtonAbort.build( ...
                this.hPanel, ...
                dLeft, ...
                dTop, ...
                this.dWidthButton, ...
                this.dHeightButton ...
            );
            dLeft = dLeft + this.dWidthButton + 10;
            
            this.uiTogglePause.hide();
            this.uiButtonAbort.hide();
            
            dTop = this.dHeightPadPanel;
            
            
            
            this.uiTextLabelStatus.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextLabelTimeElapsed.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextLabelTimeRemaining.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextLabelTimeComplete.build(this.hPanel, dLeft, dTop, this.dWidthLabel, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            dLeft = dLeft + this.dWidthLabel;
         
            
            dTop = this.dHeightPadPanel;
            
            this.uiTextStatus.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextTimeElapsed.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextTimeRemaining.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.uiTextTimeComplete.build(this.hPanel, dLeft, dTop, this.dWidthValue, this.dHeightText);
            dTop = dTop + this.dHeightText + this.dHeightPadText;
            
            this.refreshButtons();
            
            
            
        end
        
        % @param {Status 1x1} - see mic.StateScan
        function setStatus(this, st)
            %{
            cTitle = sprintf('%s %s', ...
                this.cTitle, ...
                st.cStatus ...
            );
            
            set(this.hPanel, 'Title', cTitle);
            %}
            this.uiTextStatus.set(st.cStatus);
            this.uiTextTimeElapsed.set(st.cTimeElapsed);
            this.uiTextTimeRemaining.set(st.cTimeRemaining);
            this.uiTextTimeComplete.set(st.cTimeComplete);
        end
        
        
        function abort(this)
            notify(this, 'eAbort');
            
            this.lStopped = true;
            this.lPaused = false;
            this.refreshButtons();
            
        end
        
        function pause(this)
            notify(this, 'ePause');
            this.lPaused = true;
            this.refreshButtons();
        end
        
        function resume(this)
            notify(this, 'eResume');
            this.lPaused = false;
            this.refreshButtons();
        end
        
        
        function refreshButtons(this)
            if this.lStopped
                this.uiButtonStart.show();
                this.uiTogglePause.hide();
                this.uiButtonAbort.hide();
            else
                this.uiButtonStart.hide();
                this.uiTogglePause.show();
                this.uiButtonAbort.show();
            end
            
            if this.lPaused
                % Make sure pause/resume is showing resume
                if this.uiTogglePause.get() == false
                    this.lDisableNotify = true;
                    this.uiTogglePause.set(true)
                    this.lDisableNotify = false;
                end
                this.uiTogglePause.setTooltip('Resume the scan');
                
            else
                % Make sure pause/resume not showing resume
                if this.uiTogglePause.get()
                    this.lDisableNotify = true;
                    this.uiTogglePause.set(false)
                    this.lDisableNotify = false;
                end
                this.uiTogglePause.setTooltip('Pause the scan');
            end
            
        end
        
         function reset(this)
            this.lStopped = true;
            this.lPaused = false;
            this.refreshButtons();
            
        end
        
    end 
    
    methods (Access = private)
        
        function this = init(this)
            
            this.initUiScan();
            
            this.uiTextLabelStatus = mic.ui.common.Text(...
                'cVal', 'Status:' ...
            );
            this.uiTextLabelTimeElapsed = mic.ui.common.Text(...
                'cVal', 'Elapsed:' ...
            );
            this.uiTextLabelTimeRemaining = mic.ui.common.Text(...
                'cVal', 'Remaining:' ...
            );
            this.uiTextLabelTimeComplete = mic.ui.common.Text(...
                'cVal', 'Complete:' ...
            );
        
            this.uiTextStatus = mic.ui.common.Text(...
                'cVal', '...' ...
            );
            this.uiTextTimeElapsed = mic.ui.common.Text(...
                'cVal', '...' ...
            );
            this.uiTextTimeRemaining = mic.ui.common.Text(...
                'cVal', '...' ...
            );
            this.uiTextTimeComplete = mic.ui.common.Text(...
                'cVal', '...' ...
            );
        
        end
        
        function initUiScan(this)
            
            this.uiButtonStart = mic.ui.common.Button(...
                'cText', 'Start' ...
            );
            
            this.uiTogglePause = mic.ui.common.Toggle(...
                'cTextFalse', 'Pause', ...
                'cTextTrue', 'Resume' ...
            );
        
            this.uiButtonAbort = mic.ui.common.Button(...
                'cText', 'Abort', ...
                'lAsk', true, ...
                'cMsg', 'The scan is now paused.  Are you sure you want to abort?' ... 
            );
        
            this.uiButtonStart.setTooltip('Start a new scan');
            this.uiTogglePause.setTooltip('Pause the scan');
            this.uiButtonAbort.setTooltip('Abort the scan');
            addlistener(this.uiButtonAbort, 'ePress', @this.onUiButtonAbortPress);
            addlistener(this.uiButtonAbort, 'eChange', @this.onUiButtonAbort);
            addlistener(this.uiTogglePause, 'eChange', @this.onUiButtonPause);
            addlistener(this.uiButtonStart, 'eChange', @this.onUiButtonStart);
        
        end
        
        
       
        
        
        function start(this)
            
            this.lStopped = false;
            this.lPaused = false;
            this.refreshButtons();
            
            this.msg('onUiButtonStart');
            notify(this, 'eStart');
        end
        
        function onUiButtonStart(this, src, evt)
            
            this.start();
            
        end
        
        function onUiButtonPause(this, ~, ~)
            if this.lDisableNotify
                return
            end
            
            if (this.uiTogglePause.get()) % just changed to true, so was playing
                this.pause()
            else
                this.resume()
            end
        end
        
        function onUiButtonAbortPress(this, ~, ~)
            this.uiTogglePause.set(true);
        end
        
        function onUiButtonAbort(this, ~, ~)
            this.abort()
        end
        

     
    end
    
end

