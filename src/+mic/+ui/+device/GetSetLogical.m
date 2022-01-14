classdef GetSetLogical <    mic.interface.ui.device.GetSetLogical & ...
                            mic.ui.device.Base

    % mic.ui.common.Toggle lets you issue commands set(true/false)
    % there will be an indicator that shows a red/green dot baset on the
    % result of get() returning lTrue / lFalse.  The indicator will be a
    % small axes next to the toggle.  If software is talking to device device,
    % it shows one set of images (without the gray diagonal stripes) and
    % shows another set of images when it is talking to the virtual APIs
                
    
    properties (Constant)
        
        dHeight = 24;   % height of the UIElement
        dWidthBtn = 24;
        
        
    end

    properties      
        setup           % setup -- FIXME : shouldbe renamed something like hioSetup
    end

    properties (SetAccess = private)
        cName = 'CHANGE ME' % Must be unique in entire project / app  % name identifier
        cLabel = 'Fix me'
    end

    properties (Access = protected)
        
        lVal = false   % boolean status of device
        
        % @param {ConfigGetSetNumber 1x1} [config = new ConfigGetSetNumber()] - the config instance
        %   !!! WARNING !!!
        %   DO NOT USE a single Config for multiple HardwareIO instances
        %   because deleting one HardwareIO will delete the reference to
        %   the Config instance that the other Hardware IO is using
        config
        
        
        
        cLabelName = 'Name'
        cLabelValue = 'Val'
        cLabelCommand = 'Command'
        
        uitxLabelName
        uitxLabelVal
        uitxLabelCommand
        
        
        
        % {logical 1x1} - disable the "set" part of GetSet (removes jog,
        % play, dest, stores)
        lDisableSet = false
        
        lShowLabels = true
        
        % {logical 1x1} show the API toggle on the left
        % 2019 replaced with background colors
        lShowDevice = false
        
        % {logical 1x1} show the name
        lShowName = true
        
        % {logical 1x1} show value with mic.ui.common.ImageLogical
        lShowValue = true
        
        % {logical 1x1} show the initialize button
        lShowInitButton = true
        
        % {logical 1x1} show the command toggle
        lShowCommand = true
        
        
        
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
        u8ImgTrue = imread(fullfile(mic.Utils.pathImg(), 'hiot-true-24.png'));
       
        % {uint8 24x24} image when device.get() returns false
        u8ImgFalse = imread(fullfile(mic.Utils.pathImg(), 'hiot-false-24.png'));
        
                
        % {cell of X 1xm} - varargin list of arguments for instantiating
        % the mic.ui.common.Toggle instance.  To pass it into the
        % mic.ui.common.Toggle, need to use the {:} syntax
        % http://stackoverflow.com/questions/12558819/matlab-pass-varargin-to-a-function-accepting-variable-number-of-arguments
        ceVararginCommandToggle = {}
        
           
        % {mic.Clock 1x1} must be provided in constructor
        clock        
        
        % {handle 1x1} panel container for the UI element
        hPanel     
        
        % {mic.ui.common.Toggle 1x1} issues set() commands to device
        % whenever the user clicks it
        uitCommand
        
        % {mic.ui.common.Text 1x1} for the label
        uitxName
        

           
        % {mic.ui.commin.ImageLogical 1x1} visual state
        uiilValue
        
        % RM (2/2018): Adding new methods for implementing function callback mode:
        % {function handle 1x1} 
        fhGet = @() false

        % {function handle 1x1} 
        fhSet = @(lVal) [] % Called when button is pressed

        % {function handle 1x1} 
        fhIsInitialized = @() true % Controls state of display

        % {function handle 1x1} 
        % fhInitialize = @() [] % Not used
        
        fhGetV 
        fhSetV
        fhIsInitializedV
        % fhInitializeV
        
        cAlign = 'left'
                        
    end
    

    events
        
        
    end

    
    methods        
        
        function this = GetSetLogical(varargin)
    
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_DEVICE);
            this.config = mic.config.GetSetLogical();

            % Override properties with varargin
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if this.lDisableSet == true
                this.lShowCommand = false; 
            end
            
             
            this.init()            
        end
        
         
        function enable(this)

        
            this.uitCommand.enable()
            this.uitxName.enable()
            this.uitDevice.enable()
            this.uiilValue.enable()
        end
        
        function disable(this)
            
            this.uitCommand.disable()
            this.uitxName.disable()
            this.uitDevice.disable()
            this.uiilValue.disable()
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
                
                if ~this.lDeviceIsSet
                    this.uitDevice.disable(); % re-enabled in setDevice()
                end
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
            
            this.clock.add(@this.onClock, this.id(), this.config.dDelay);
            
%             if ~isempty(this.clock) && ...
%                 ~this.clock.has(this.id())
%                 this.clock.add(@this.onClock, this.id(), this.config.dDelay);
%             end
            
            
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    this.setColorOfBackgroundToWarning();
                end
            else
                if ~this.isActive()
                    this.setColorOfBackgroundToWarning();
                end
            end
            
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
          
        % Override
        function turnOn(this)
            
            turnOn@mic.ui.device.Base(this);
            this.setColorOfBackgroundToDefault();
        end
      
        
        function turnOff(this)
            turnOff@mic.ui.device.Base(this);
            this.setColorOfBackgroundToWarning();
        end
        
        function setColorOfBackgroundToWarning(this)
            this.setColorOfBackground([1 1 0.85]);
        end
        
        function setColorOfBackgroundToDefault(this)
            this.setColorOfBackground([0.94 0.94 0.94]);
        end
        

        % @param {double 1x3} dColor - RGB triplet, i.e.,[0.5 0.5 0]
        function setColorOfBackground(this, dColor)
            if isempty(this.hPanel)
                return
            end
            
            if ~ishandle(this.hPanel)
                return
            end
            
            this.uitxLabelCommand.setBackgroundColor(dColor)
            this.uitxLabelDevice.setBackgroundColor(dColor);
            this.uitxLabelInit.setBackgroundColor(dColor);
            this.uitxLabelInitState.setBackgroundColor(dColor);
            this.uitxLabelName.setBackgroundColor(dColor);
            this.uitxLabelVal.setBackgroundColor(dColor);
            this.uitxName.setBackgroundColor(dColor);
            
            set(this.hPanel, 'BackgroundColor', dColor);
                       
        end
        
        
        function set(this, l)
            % Programatic equivalent of pressing the command toggle to
            % given state
            this.uitCommand.set(l);
        end
        
        function l = get(this)

            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    l = this.fhGetV();
                else
                    l = this.fhGet();
                end
            else
                l = this.getDevice().get();
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
            
            init@mic.ui.device.Base(this);                        

                       
            this.uitxName = mic.ui.common.Text('cVal', this.cLabel, 'cAlign', this.cAlign);
                        
            this.initCommandToggle();
            this.initValueImageLogical();
            this.initLabels();
                                       
            this.deviceVirtual = this.newDeviceVirtual();
            
            % Set virtual functions:
            this.fhGetV             = @()this.deviceVirtual.get();
            this.fhSetV             = @(lVal)this.deviceVirtual.set(lVal);
            this.fhIsInitializedV   = @()this.deviceVirtual.isInitialized();
            this.fhInitializeV      = @()this.deviceVirtual.initialize();
        
            
        end
        
        
        function initLabels(this)
            
           
            this.uitxLabelCommand = mic.ui.common.Text(...
                'cVal', this.cLabelCommand, ...
                'cAlign', 'center' ...
            );
            
            this.uitxLabelName = mic.ui.common.Text('cVal', this.cLabelName);
            this.uitxLabelVal = mic.ui.common.Text('cVal', this.cLabelValue);
        end
        
        
        
        
        function initValueImageLogical(this)
            
            this.uiilValue = mic.ui.common.ImageLogical(...
                'u8ImgTrue', this.u8ImgTrue, ...
                'u8ImgFalse', this.u8ImgFalse ...
            );
            
        end
        
        function initCommandToggle(this)
            
            % Need to expand cell array ceVararginCommandToggle into comma-separated
            % list using the {:} syntax
            
            this.uitCommand = mic.ui.common.Toggle(this.ceVararginCommandToggle{:});
            addlistener(this.uitCommand, 'eChange', @this.onCommandChange);
            
        end
        
        
        function onClock(this) 
           
            if ~ishghandle(this.hPanel)
                this.msg('onClock() returning and removing task since not build', this.u8_MSG_TYPE_INFO);
                
                % Remove task
                if isvalid(this.clock) && ...
                   this.clock.has(this.id())
                    this.clock.remove(this.id());
                end
            end
            
            try
                if this.lUseFunctionCallbacks
                    if this.fhIsVirtual()
                        this.lVal = this.fhGetV();
                    else
                        this.lVal = this.fhGet();
                    end
                    
                else
                    this.lVal = this.getDevice().get();
                end

                
                
                % Force the toggle back to the current state without it
                % notifying eChange
                
                if ~this.lDisableSet
                    this.uitCommand.setWithoutNotification(this.lVal);
                end
                
                this.uiilValue.set(this.lVal);
                
                this.updateInitializedButton();
                            
                                               
            catch mE
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
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
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    this.fhSetV(this.uitCommand.get());     
                else
                    this.fhSet(this.uitCommand.get());     
                end
            else
                this.getDevice().set(this.uitCommand.get());     
            end
                   
                        
        end
        
        
        
        
        function updateInitializedButton(this)
            
            
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    lInitialized = this.fhIsInitializedV();
                else
                    lInitialized = this.fhIsInitialized();
                end
            else
                lInitialized = this.getDevice.isInitialized();
            end

                
            if this.lShowInitButton
                if lInitialized
                    this.uibInit.setU8Img(this.u8InitTrue);
                else
                    this.uibInit.setU8Img(this.u8InitFalse);
                end
            end

            if this.lIsInitializing && ...
               lInitialized
                this.lIsInitializing = false;
            end
            
        end
        
        
    end

end %class
