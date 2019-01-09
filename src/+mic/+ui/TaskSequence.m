classdef TaskSequence <  mic.ui.common.Base
    
    properties (Constant)

    end


    properties
    end


    properties (Access = private)
        
        % {< mic.TaskSequence 1x1}
        task
        
        % {mic.Clock or mic.ui.Clock 1x1}
        clock
    end
    
    properties (SetAccess = private)
        
        cName = 'ui-task-sequence-change-me'
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

        % {logical 1x1} shows the play/pause button
        lShowButton = true
        
        % {logical 1x1} 
        % when isDone === false: colors background red;
        % when isDone === true: colors background green and shows checkmark
        % at the right which will cover the play/pause button if that is
        % visible
        lShowIsDone = true
        
    end


    events
        

    end


    
    
    methods
        
        function this = TaskSequence(varargin)
            
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.task, 'mic.TaskSequence')
                error('task must be mic.TaskSequence');
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
            if (this.lShowButton)
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
            
            if (this.lShowButton || this.lShowIsDone)
                this.uiButton.build(this.hPanel, dWidth - 25, 1, 24, 24);
            end
            

            this.clock.add(@this.onClock, this.id(), this.dDelay);
            
        end
        
       

    end
    
    methods (Access = protected)
        
        function updateButtonWhenShowingButton(this)
            
            
        end
        
        function updateButton(this)
            
            % This is a little stupidly complicated, but oh well
            
            if this.lShowButton
                
                if this.task.isExecuting()
                    this.uiButton.setU8Img(this.u8Pause)
                elseif this.task.isDone()
                    if this.lShowIsDone
                        this.uiButton.setU8Img(this.u8Check)
                    else
                       this.uiButton.setU8Img(this.u8Play)
                    end
                else
                    this.uiButton.setU8Img(this.u8Play)
                end
            end
            
            if ~this.lShowButton && this.lShowIsDone
                % Need to show or hide the button and make it look like a
                % checkmark
                if this.task.isDone()
                    this.uiButton.setU8Img(this.u8Check)
                    this.uiButton.show();
                else
                    this.uiButton.hide();
                end
                
            end
        
            
        end
        
        function onClock(this)
            
            if ~ishandle(this.hUI)
                return
            end
                        
            dColor = this.getColor();
            
            this.uiTextMain.set(this.task.getMessage());
            this.uiProgressBar.set(this.task.getProgress());            
            
            if this.lShowIsDone
                this.uiTextMain.setBackgroundColor(dColor);
                this.uiTextSub.setBackgroundColor(dColor);
                set(this.hPanel, 'BackgroundColor', dColor);
            end
            
            
            this.updateButton();
            
            if this.task.isExecuting()
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
            
            if this.task.isDone()
                return;
            end
            
            if this.task.isExecuting()
                this.task.abort();
                this.uiProgressBar.hide();
                return;
            end
            
            this.task.execute();
            this.uiProgressBar.show();
            
        end
        
        function onPanelButtonDown(this, ~, ~)
            
            
            
        end 
        
        function d = getColor(this)
           d = mic.Utils.ifElse(...
               this.task.isExecuting(), [1 1 0.85], ...
               this.task.isDone(), [.85, 1, .85], ...
               [1, .85, .85] ...
           );           
       end
        
        
        
    end
    
    

end