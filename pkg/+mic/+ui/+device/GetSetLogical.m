classdef GetSetLogical < mic.Base

    % mic.ui.common.Toggle lets you issue commands set(true/false)
    % there will be an indicator that shows a red/green dot baset on the
    % result of get() returning lTrue / lFalse.  The indicator will be a
    % small axes next to the toggle.  If software is talking to device device,
    % it shows one set of images (without the gray diagonal stripes) and
    % shows another set of images when it is talking to the virtual APIs
                
    
    properties (Constant)
        
        dHeight = 24;   % height of the UIElement
        dWidthBtn = 24;
        
        cTooltipDeviceOff = 'Connect to the real API';
        cTooltipDeviceOn = 'Disconnect the real API (go into virtual mode)';
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
        
        
        % @param {ConfigGetSetNumber 1x1} [config = new ConfigGetSetNumber()] - the config instance
        %   !!! WARNING !!!
        %   DO NOT USE a single Config for multiple HardwareIO instances
        %   because deleting one HardwareIO will delete the reference to
        %   the Config instance that the other Hardware IO is using
        config
        
        
        cLabelDevice = 'Device'
        cLabelInit = 'Init'
        cLabelName = 'Name'
        cLabelValue = 'Val'
        cLabelCommand = 'Command'
        
        uitxLabelName
        uitxLabelVal
        uitxLabelDevice
        uitxLabelInit
        uitxLabelCommand
        
        
        
        % {logical 1x1} - disable the "set" part of GetSet (removes jog,
        % play, dest, stores)
        lDisableSet = false
        
        lShowLabels = true
        
        % {logical 1x1} show the API toggle on the left
        lShowDevice = true
        
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
        
        dWidthPadDevice = 0;
        dWidthPadInitButton = 0;
        dWidthPadName = 5;
        dWidthPadVal = 0;
        dWidthPadCommand = 0;
        
        % {uint8 24x24} image when device.get() returns true
        u8ImgTrue = imread(fullfile(mic.Utils.pathAssets(), 'hiot-true-24.png'));
       
        % {uint8 24x24} image when device.get() returns false
        u8ImgFalse = imread(fullfile(mic.Utils.pathAssets(), 'hiot-false-24.png'));
        
        % {uint8 24x24} images for Device toggle
        u8ToggleOn = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-true.png'));
        u8ToggleOff = imread(fullfile(mic.Utils.pathAssets(), 'hiot-horiz-24-false-yellow.png'));

        u8InitTrue = imread(fullfile(mic.Utils.pathAssets(), 'init-button-true.png'));
        u8InitFalse = imread(fullfile(mic.Utils.pathAssets(), 'init-button-false-yellow.png'));
        
        
        % { < mic.interface.device.GetSetLogical 1x1}  
        % Can be set after initialized or passed in
        device             
        
        % { < mic.interface.device.GetSetLogical 1x1}
        % Builds its own
        deviceVirtual
                
        % {cell of X 1xm} - varargin list of arguments for instantiating
        % the mic.ui.common.Toggle instance.  To pass it into the
        % mic.ui.common.Toggle, need to use the {:} syntax
        % http://stackoverflow.com/questions/12558819/matlab-pass-varargin-to-a-function-accepting-variable-number-of-arguments
        ceVararginToggle = {}
        
           
        % {mic.Clock 1x1} must be provided in constructor
        clock        
        
        % {handle 1x1} panel container for the UI element
        hPanel     
        
        % {mic.ui.common.Toggle 1x1} issues set() commands to device
        % whenever the user clicks it
        uitCommand
        
        % {mic.ui.common.Text 1x1} for the label
        uitxName
        
        % {mic.ui.common.Toggle 1x1} toggle for the API
        uitDevice
           
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
    
            this.config = mic.config.GetSetLogical();

            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if this.lDisableSet == true
                this.lShowCommand = false; 
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
            
            
            % Device toggle
            if this.lShowDevice
                dLeft = dLeft + this.dWidthPadDevice;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelDevice.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uitDevice.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeight);            
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
        % Expose the set command of the Device
        % @param {logical 1x1} 
        function set(this, l)
           this.getDevice().set(l);
           
        end
        %}

           
        
        
        function turnOn(this)
        %TURNON Turns the motor on, actually using the API to control the 
        %   HardwareIO.turnOn()
        %
        % See also TURNOFF

            this.lActive = true;
            
            this.uitDevice.lVal = true;
            this.uitDevice.setTooltip(this.cTooltipDeviceOn);
            
            
            % Kill the APIV
            if ~isempty(this.deviceVirtual) && ...
                isvalid(this.deviceVirtual)
                delete(this.deviceVirtual);
                this.deviceVirtual = []; % This is calling the setter
            end
            
        end
        
        
        function turnOff(this)
        %TURNOFF Turns the motor off
        %   HardwareIO.turnOn()
        %
        % See also TURNON
        
            % CA 2014.04.14: Make sure APIV is available
            
            if isempty(this.deviceVirtual)
                this.deviceVirtual = this.newDeviceVirtual();
            end
            
            this.lActive = false;
            this.uitDevice.lVal = false;
            this.uitDevice.setTooltip(this.cTooltipDeviceOff);
            
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

            if ~isempty(this.deviceVirtual)
                 delete(this.deviceVirtual);
            end

            % delete(this.setup);
            % setup ?

            if ~isempty(this.uitCommand)
                delete(this.uitCommand)
            end
            
        end
        
        
        function setDevice(this, device)
            this.device = device;
        end
        
        function device = getDevice(this)
            if this.lActive
                device = this.device;
            else
                device = this.deviceVirtual;
            end 
            
        end
        
    end %methods
    
    methods (Access = protected)
                    
        function device = newDeviceVirtual(this)
            if this.lDisableSet
                device = mic.device.GetLogical();
            else
                device = mic.device.GetSetLogical();
            end
        end
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowDevice
               dOut = dOut + this.dWidthPadDevice + this.dWidthBtn ;
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
            this.initDeviceToggle();
            this.initInitializeToggle();
            this.initValueImageLogical();
            this.initLabels();
                                       
            this.deviceVirtual = this.newDeviceVirtual();
            this.clock.add(@this.onClock, this.id(), this.config.dDelay);
            
        end
        
        
        function initLabels(this)
            
            this.uitxLabelDevice = mic.ui.common.Text(...
                'cVal', this.cLabelDevice, ...
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
        function initDeviceToggle(this)
            
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

            this.uitDevice = mic.ui.common.Toggle( ...
                'lImg', true, ...
                'u8ImgOff', this.u8ToggleOff, ...
                'u8ImgOn', this.u8ToggleOn, ...
                'stF2TOptions', st1, ...
                'stT2FOptions', st2 ...
            );
            addlistener(this.uitDevice,   'eChange', @this.onDeviceChange);
            
            
        end
        
        function onClock(this) 
           
            try
                this.lVal = this.getDevice().get();
                
                % Force the toggle back to the current state without it
                % notifying eChange
                
                if ~this.lDisableSet
                    this.uitCommand.setValWithoutNotification(this.lVal);
                end
                
                this.uiilValue.setVal(this.lVal);
                
                
                % Update visual appearance of button to reflect state
                lInitialized = this.getDevice.isInitialized();
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
        function set.deviceVirtual(this, value)
            
            if ~isempty(this.deviceVirtual) && ...
                isvalid(this.deviceVirtual)
                delete(this.deviceVirtual);
            end

            this.deviceVirtual = value;
            
        end
        %}
        
        function onCommandChange(this, src, evt)
            
            % Remember that lVal has just flipped from what it was
            % pre-click.  The toggle just issues set() commands.  It
            % doesn't do anything smart to show the value, this is handled
            % by the indicator image with each onClock()
            
            this.getDevice().set(this.uitCommand.lVal);            
                        
        end
        
        function onDeviceChange(this, src, evt)
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
            this.getDevice().initialize();
            % this.disable();
            
        end
    end

end %class
