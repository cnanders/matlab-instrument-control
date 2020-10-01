classdef TaskSequence <  mic.ui.common.Base & mic.interface.Task
    
    properties (Constant)

    end


    properties
    end


    properties (Access = private)
        
        % {mic.TaskSequence 1x1}
        task
        
        % {mic.Clock or mic.ui.Clock 1x1}
        clock
        
        % {logical 1x1} stores if this UI is updating itself
        lIsRunning = true
    end
    
    properties (SetAccess = private)
        
        cName = 'ui-task-sequence-change-me'
        dDelay = 1 % how often the UI updates
        
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
        
        % {logical 1x1} shows the text + red/green status of the sequence
        % and progress bar
        lShowStatus = true
        
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
                error('task must return a mic.TaskSequence');
            end
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
            
        end
        
        function execute(this)
            
            if this.task.isDone()
                return;
            end
            
            this.start(); % always make sure UI is updating
            this.task.execute();
            this.uiProgressBar.show();
       end

       function abort(this)
           this.task.abort();
           this.uiProgressBar.hide();
       end

       function l = isExecuting(this)
           l = this.task.isExecuting();
       end

       function l = isDone(this)
           l = this.task.isDone();
       end

       function c = getMessage(this)
           c = this.task.getMessage();
       end
        
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            this.clock.remove(this.id());
        end
        
        function show(this)
            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
            end
        end

        function hide(this)
            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
            end
        end
        
        function enable(this)
            this.uiButton.enable();
        end
        
        function disable(this)
            this.uiButton.disable();
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
        
            
            dTop = 4;
            dSep = 16;
            dLeft = 0;
            
            if this.lShowStatus
                dLeft = 10;
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
            end
            
            if (this.lShowButton || this.lShowIsDone)
                this.uiButton.build(this.hPanel, dWidth - 25, 1, 24, 24);
            end

            if this.lIsRunning
                this.clock.add(@this.onClock, this.id(), this.dDelay);
            end
            
        end
        
        
        
       

    end
    
    methods (Access = protected)
        
        function start(this)
            
            if this.lIsRunning
                return
            end
            
            if ishandle(this.hPanel)
                this.clock.add(@this.onClock, this.id(), this.dDelay);
            end
            
            this.lIsRunning = true;
        end
        
        function stop(this)
            
            if ~this.lIsRunning
                return
            end
            
            if this.clock.has(this.id())
                this.clock.remove(this.id());
            end
            
            this.lIsRunning = false;
        end
        
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
            
            if ~ishandle(this.hPanel)
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
            
            if ~this.lShowIsDone && ...
                ~this.task.isExecuting()
                % when not showing is done, no need to constantly
                % update the UI based when the task is not executing
                this.stop();
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
            
            if this.task.isExecuting() % button shows pause
                this.abort();
                return;
            end
            
            this.execute()
            
        end
        
        function printStatus(this)
            
            fprintf('*******************************\n');
            fprintf('STATUS: mic.ui.TaskSequence %s \n', this.task.getMessage());
            ceTasks = this.task.getTasks();
            for k = 1 : length(ceTasks)
                fprintf('Task %1d of %1d: (%s) %s\n', ...
                    k, ...
                    length(ceTasks), ...
                    mic.Utils.tern(ceTasks{k}.isDone(), 'done', 'not done'), ...
                    ceTasks{k}.getMessage() ...
                );
            end
            fprintf('*******************************\n');

            
        end
        
        function onPanelButtonDown(this, src, ~)
            
            src
            this.printStatus();
            
        end 
        
        function d = getColor(this)
            
            dColorBlue = [219 237 247]/255;
            dColorGreen = [.85, 1, .85];
            dColorRed = [1, .85, .85];
           d = mic.Utils.ifElse(...
               this.task.isExecuting(), dColorBlue, ...
               this.task.isDone(), dColorGreen, ...
               dColorRed ...
           );           
       end
        
        
        
    end
    
    

end