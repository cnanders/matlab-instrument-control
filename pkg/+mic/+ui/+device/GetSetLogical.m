classdef GetSetLogical < mic.Base

    % mic.ui.common.Toggle lets you issue commands set(true/false)
    % there will be an indicator that shows a red/green dot baset on the
    % result of get() returning lTrue / lFalse.  The indicator will be a
    % small axes next to the toggle.  If software is talking to device api,
    % it shows one set of images (without the gray diagonal stripes) and
    % shows another set of images when it is talking to the virtual APIs
                
    
    properties (Constant)
        
        dHeight = 24;   % height of the UIElement
        dWidthBtn = 24;
        
        cTooltipApiOff = 'Connect to the real API';
        cTooltipApiOn = 'Disconnect the real API (go into virtual mode)';
        cTooltipInitButton = 'Send the initialize command to this device';

        
    end

    properties      
        setup           % setup -- FIXME : shouldbe renamed something like hioSetup
    end

    properties (SetAccess = private)
        cName   % name identifier
        cLabel = 'Fix me'
        lVal = false   % boolean status of device
        lActive     % boolean to tell whether the motor is active or not
    end

    properties (Access = protected)
        
        cLabelApi = 'Api'
        cLabelInit = 'Init'
        cLabelName = 'Name'
        cLabelValue = 'Val'
        cLabelCommand = 'Command'
        
        uitxLabelName
        uitxLabelVal
        uitxLabelApi
        uitxLabelInit
        uitxLabelCommand
        
        lShowLabels = true
        
        % {logical 1x1} show the API toggle on the left
        lShowApi = true
        
        % {logical 1x1} show the name
        lShowName = true
        
        % {logical 1x1} show value with mic.ui.common.ImageLogical
        lShowValue = true
        
        % {logical 1x1} show the initialize button
        lShowInitButton = true
        
        % {logical 1x1} show the command toggle
        lShowCommand = true
        
        % {mic.ui.common.Button 1x1} clicking it calls device.initialize()
        % Its logical state is updated on clock cycle by calling device.isInitialized()  
        % see lShowInitButon
        uibInit
        
        dHeightLabel = 16
        dHeightText = 16
        dHeightBtn = 24
        dWidthName = 100
        dWidthCommand = 100
        dWidth = 290
        dWidthValue = 24
        
        dWidthPadApi = 0;
        dWidthPadInitButton = 0;
        dWidthPadName = 5;
        dWidthPadVal = 0;
        dWidthPadCommand = 0;
        
        % {uint8 24x24} image when device.get() returns true
        u8ImgTrue = imread(fullfile(mic.Utils.pathAssets(), 'hiot-true-24.png'));
       
        % {uint8 24x24} image when device.get() returns false
        u8ImgFalse = imread(fullfile(mic.Utils.pathAssets(), 'hiot-false-24.png'));
        
        % {uint8 24x24} images for Api toggle
        u8ToggleOn = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-true.png'));
        u8ToggleOff = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-false-yellow.png'));

        u8InitTrue = imread(fullfile(mic.Utils.pathAssets(), 'init-button-true.png'));
        u8InitFalse = imread(fullfile(mic.Utils.pathAssets(), 'init-button-false-yellow.png'));
        
        
        % { < mic.interface.device.GetSetLogical 1x1}  
        % Can be set after initialized or passed in
        api             
        
        % { < mic.interface.device.GetSetLogical 1x1}
        % Builds its own
        apiv
                
        % {cell of X 1xm} - varargin list of arguments for instantiating
        % the mic.ui.common.Toggle instance.  To pass it into the
        % mic.ui.common.Toggle, need to use the {:} syntax
        % http://stackoverflow.com/questions/12558819/matlab-pass-varargin-to-a-function-accepting-variable-number-of-arguments
        ceVararginToggle = {}
        
           
        % {mic.Clock 1x1} must be provided in constructor
        clock        
        dPeriod = 1
        
        
        hPanel      % panel container for the UI element
        
        % {mic.ui.common.Toggle 1x1} issues set() commands to device
        % whenever the user clicks it
        uitCommand
        
        % {mic.ui.common.Text 1x1} for the label
        uitxName
        
        % {mic.ui.common.Toggle 1x1} toggle for the API
        uitApi
           
        % {mic.ui.commin.ImageLogical 1x1} visual state
        uiilValue
        
        % {logical 1x1} true in moments after calling device.initialize()
        % and before device.isInitialized() returns true. false otherwise
        lIsInitializing
               
                        
    end
    

    events
        
        
    end

    
    methods        
        
        function this = GetSetLogical(varargin)
    
            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
             
            this.init()            
        end
        
                
        function build(this, hParent, dLeft, dTop)
          
            dHeight = this.dHeight;
            if this.lShowLabels
                dHeight = dHeight + this.dHeightLabel;
            end
            
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop this.getWidth() dHeight], hParent) ...
            );
            drawnow
            
            dLeft = 0;
            
            dTop = -1;
            dTopLabel = -1;
            if this.lShowLabels
                dTop = this.dHeightLabel;
            end
            
            
            % Api toggle
            if this.lShowApi
                dLeft = dLeft + this.dWidthPadApi;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelApi.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uitApi.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);            
                dLeft = dLeft + this.dWidthBtn;
            end
            
            % Init button
            if (this.lShowInitButton)
                dLeft = dLeft + this.dWidthPadInitButton;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelInit.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibInit.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn; 
            end
            
            % Name
            if this.lShowName
                dLeft = dLeft + this.dWidthPadName;
                if this.lShowLabels
                    this.uitxLabelName.build(this.hPanel, dLeft, dTopLabel, this.dWidthName, this.dHeightLabel);
                end
                
                this.uitxName.build(this.hPanel, dLeft,  dTop + (this.dHeight - this.dHeightText)/2, this.dWidthName, this.dHeightText);

                dLeft = dLeft + this.dWidthName;
            end
            
            % Value (in this case it is a mic.ui.common.ImageLogical)
            if this.lShowValue
                dLeft = dLeft + this.dWidthPadVal;
                if this.lShowLabels
                    this.uitxLabelVal.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uiilValue.build(this.hPanel, ...
                    dLeft, ...
                    dTop ...
                );
                dLeft = dLeft + this.dWidthBtn;
            end
                
            % Command
            
            if this.lShowCommand
                dLeft = dLeft + this.dWidthPadCommand;
                if this.lShowLabels
                    this.uitxLabelCommand.build(this.hPanel, dLeft, dTopLabel, this.dWidthCommand, this.dHeightLabel);
                end
                this.uitCommand.build(this.hPanel, ...
                    dLeft, ...
                    dTop, ...
                    this.dWidthCommand, ...
                    this.dHeight ...
                );
            end
                        
            
        end

        
        
        %{
        % Expose the set command of the Api
        % @param {logical 1x1} 
        function set(this, l)
           this.getApi().set(l);
           
        end
        %}

           
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the API to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitApi.lVal = true;
            this.uitApi.setTooltip(this.cTooltipApiOn);
            
            
            % Kill the APIV
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
                this.apiv = []; % This is calling the setter
            end
            
        end
        
        
        function turnOff(this)
        %TURNOFF Turns the motor off
        %   HardwareIO.turnOn()
        %
        % See also TURNON
        
            % CA 2014.04.14: Make sure APIV is available
            
            if isempty(this.apiv)
                this.apiv = this.newApiv();
            end
            
            this.lActive = false;
            this.uitApi.lVal = false;
            this.uitApi.setTooltip(this.cTooltipApiOff);
            
        end
        

        function delete(this)
        %DELETE Class Destructor
        %   HardwareIO.Delete()
        %
        % See also HARDWAREIO, INIT, BUILD

           % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                % this.msg('Axis.delete() removing clock task'); 
                this.clock.remove(this.id());
            end

            
            % av.  Need to delete because it has a timer that needs to be
            % stopped and deleted

            if ~isempty(this.apiv)
                 delete(this.apiv);
            end

            % delete(this.setup);
            % setup ?

            if ~isempty(this.uitCommand)
                delete(this.uitCommand)
            end
            
        end
        
        
        function setApi(this, api)
            this.api = api;
        end
        
        function api = getApi(this)
            if this.lActive
                api = this.api;
            else
                api = this.apiv;
            end 
            
        end
        
    end %methods
    
    methods (Access = protected)
                    
        function api = newApiv(this)
            api = mic.device.GetSetLogical();
        end
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowApi
               dOut = dOut + this.dWidthPadApi + this.dWidthBtn ;
            end
            
            if this.lShowInitButton
               dOut = dOut + this.dWidthPadInitButton + this.dWidthBtn ;
            end
            
            if this.lShowName
                dOut = dOut + this.dWidthPadName + this.dWidthName ;
            end
            
            if this.lShowValue
               dOut = dOut + this.dWidthPadVal + this.dWidthBtn ;
            end

            if this.lShowCommand
                dOut = dOut + this.dWidthCommand + this.dWidthPadCommand;
            end
            
                        
        end
        
        function init(this)
            
            
            this.uitxName = mic.ui.common.Text('cVal', this.cLabel);
                        
            this.initCommandToggle();
            this.initApiToggle();
            this.initInitializeToggle();
            this.initValueImageLogical();
            this.initLabels();
                                       
            this.apiv = this.newApiv();
            this.clock.add(@this.onClock, this.id(), this.dPeriod);
            
        end
        
        
        function initLabels(this)
            
            this.uitxLabelApi = mic.ui.common.Text(...
                'cVal', this.cLabelApi, ...
                'cAlign', 'center' ...
            );    
            this.uitxLabelInit = mic.ui.common.Text(...
                'cVal', this.cLabelInit, ...
                'cAlign', 'center' ...
            );
            this.uitxLabelCommand = mic.ui.common.Text(...
                'cVal', this.cLabelCommand, ...
                'cAlign', 'center' ...
            );
            
            this.uitxLabelName = mic.ui.common.Text('cVal', this.cLabelName);
            this.uitxLabelVal = mic.ui.common.Text('cVal', this.cLabelValue);
        end
        
        
        function initInitializeToggle(this)
            
            this.uibInit = mic.ui.common.Button( ...
                'cText', 'Init', ...
                'lImg', true, ...
                'u8Img', this.u8InitFalse, ...
                'lAsk', true, ...
                'cMsg', 'Are you sure you want to initialize this device?  It may take a couple minutes.' ...
            );
            this.uibInit.setTooltip(this.cTooltipInitButton);
            addlistener(this.uibInit, 'eChange', @this.onInitChange);
            
        end
        
        function initValueImageLogical(this)
            
            this.uiilValue = mic.ui.common.ImageLogical(...
                'u8ImgTrue', this.u8ImgTrue, ...
                'u8ImgFalse', this.u8ImgFalse ...
            );
            
        end
        
        function initCommandToggle(this)
            
            % Need to expand cell array ceVararginToggle into comma-separated
            % list using the {:} syntax
            
            this.uitCommand = mic.ui.common.Toggle(this.ceVararginToggle{:});
            addlistener(this.uitCommand, 'eChange', @this.onCommandChange);
            
        end
        
        
        % API toggle on the left
        function initApiToggle(this)
            
            st1 = struct();
            st1.lAsk        = true;
            st1.cTitle      = 'Switch?';
            st1.cQuestion   = 'Do you want to change from the virtual API to the real API?';
            st1.cAnswer1    = 'Yes of course!';
            st1.cAnswer2    = 'No not yet.';
            st1.cDefault    = st1.cAnswer2;

            st2 = struct();
            st2.lAsk        = true;
            st2.cTitle      = 'Switch?';
            st2.cQuestion   = 'Do you want to change from the real API to the virtual API?';
            st2.cAnswer1    = 'Yes of course!';
            st2.cAnswer2    = 'No not yet.';
            st2.cDefault    = st2.cAnswer2;

            this.uitApi = mic.ui.common.Toggle( ...
                'lImg', true, ...
                'u8ImgOff', this.u8ToggleOff, ...
                'u8ImgOn', this.u8ToggleOn, ...
                'stF2TOptions', st1, ...
                'stT2FOptions', st2 ...
            );
            addlistener(this.uitApi,   'eChange', @this.onApiChange);
            
            
        end
        
        function onClock(this) 
           
            try
                this.lVal = this.getApi().get();
                
                % Force the toggle back to the current state without it
                % notifying eChange
                
                this.uitCommand.setValWithoutNotification(this.lVal);
                
                this.uiilValue.setVal(this.lVal);
                
                
                % Update visual appearance of button to reflect state
                lInitialized = this.getApi.isInitialized();
                if this.lShowInitButton
                    if lInitialized
                        this.uibInit.setU8Img(this.u8InitTrue);
                    else
                        this.uibInit.setU8Img(this.u8InitFalse);
                    end
                end
            
                                               
            catch err
                this.msg(getReport(err));
            end 

        end
        
        %{
        function set.apiv(this, value)
            
            if ~isempty(this.apiv) && ...
                isvalid(this.apiv)
                delete(this.apiv);
            end

            this.apiv = value;
            
        end
        %}
        
        function onCommandChange(this, src, evt)
            
            % Remember that lVal has just flipped from what it was
            % pre-click.  The toggle just issues set() commands.  It
            % doesn't do anything smart to show the value, this is handled
            % by the indicator image with each onClock()
            
            this.getApi().set(this.uitCommand.lVal);            
                        
        end
        
        function onApiChange(this, src, evt)
            if src.lVal
                this.turnOn();
            else
                this.turnOff();
            end
        end
        
        function onInitChange(this, src, evt)
            
            this.msg('onInitChange()');
            this.initialize();
            
        end
        
        function initialize(this)
           
            this.lIsInitializing = true;
            this.getApi().initialize();
            % this.disable();
            
        end
    end

end %class
