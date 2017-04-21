classdef Base < mic.Base
    
    %BASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = protected)
        
        
        % {< mic.interface.device.* 1x1}
        device
        
        % {< mic.interface.device.* 1x1}
        deviceVirtual
        
        % {logical 1x1} controls routing to real or virtual device
        lActive = false
        
        
                
    end
    
    properties (SetAccess = protected)
        
        % {uint8 24x24} images for play/pause
        u8Play = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'play-24.png'));
        u8Pause = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'pause-24.png'));
        
        % {uint8 24x24} - images for the device real/virtual toggle
        u8ToggleOn = imread(fullfile(mic.Utils.pathImg(), 'toggle', 'horiz-1', 'toggle-horiz-24-true.png'));     
        u8ToggleOff = imread(fullfile(mic.Utils.pathImg(), 'toggle', 'horiz-1', 'toggle-horiz-24-false-yellow.png'));           
        
        % {uint8 24x24} - images for the initialize button/state UI
        u8InitTrue = imread(fullfile(mic.Utils.pathImg(), 'init', 'init-button-true.png'));
        u8InitFalse = imread(fullfile(mic.Utils.pathImg(), 'init', 'init-button-false-yellow.png'));
    
        cLabelDevice = 'Api'
        cLabelInit = 'Init'
        cLabelInitState = 'Init'
        
        % {mic.ui.common.Toggle 1x1} toggle for the virtual device / real
        % device
        uitDevice     
        
        % {mic.ui.common.Button 1x1} clicking it calls device.initialize()
        % Its logical state is updated on clock cycle by calling device.isInitialized()  
        % see lShowInitButon
        uibInit  
        
        % {logical 1x1} true in moments after calling device.initialize()
        % and before device.isInitialized() returns true. false otherwise
        lIsInitializing = false
        
        %{ mic.ui.common.ImageLogical 1x1} image logical whose state is set
        % on every clock cycle by the value of device.isInitialized() it is
        % redundant if already showing uibInit.  See lShowInitState
        uiilInitState % image logical to show isInitialized state
        
    
        uitxLabelDevice
        uitxLabelInit
        uitxLabelInitState
        
        
        % {logical 1x1} - ask the user if they are sure when clicking API
        % button/toggle
        lAskOnDeviceClick = true
        
        % {logical 1x1} - ask the user if they are sure when clicking the
        % Init button
        lAskOnInitClick = true
        
        
        cTooltipDeviceOff = 'Connect to the real Device / hardware';
        cTooltipDeviceOn = 'Disconnect the real Device / hardware (go into virtual mode)';
        cTooltipInitButton = 'Send the initialize command to this device';
        
        lDeviceIsSet = false
        
        
    end
    
    
    events
        eTurnOn
        eTurnOff
        
    end
    
    methods 
        
        function this = Base()

        end
        
        
        function l = isActive(this)
            l = this.lActive;
        end
        
        function device = getDevice(this)
            if this.lActive
                device = this.device;
            else
                device = this.deviceVirtual;
            end 
        end
        
        
        % Do a switch on the class of the device
        % switch class(this)
        
        function setDevice(this, device)
            
            if this.isDevice(device)
                this.device = device;
                
                this.lDeviceIsSet = true;
                this.uitDevice.enable();
            end
        end
                
        function setDeviceVirtual(this, device)
            if ~isempty(this.deviceVirtual) && ...
                isvalid(this.deviceVirtual)
                delete(this.deviceVirtual);
            end
            
            if this.isDevice(device)
                this.deviceVirtual = device;
            end
            
        end
        
        % @param {x 1x1} device - the value to check
        % @return {logical 1x1} 
        function l = isDevice(this, device)
            
            switch class(this)
                case 'mic.ui.device.GetSetNumber'
                    if ~isa(device, 'mic.interface.device.GetSetNumber')
                        cMsg = '"mic.ui.device.GetSetNumber" UI controls require devices that implement the "mic.interface.device.GetSetNumber" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'warn');
                        l = false;
                        return
                    end
                case 'mic.ui.device.GetSetText'
                    if ~isa(device, 'mic.interface.device.GetSetText')
                        cMsg = '"mic.ui.device.GetSetText" UI controls require devices that implement the "mic.interface.device.GetSetText" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'warn');
                        l = false;
                        return
                    end
                   
                case 'mic.ui.device.GetSetLogical'
                    if ~isa(device, 'mic.interface.device.GetSetLogical')
                        cMsg = '"mic.ui.device.GetSetLogical" UI controls require devices that implement the "mic.interface.device.GetSetLogical" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'warn');
                        l = false;
                        return
                    end
                   
                case 'mic.ui.device.GetNumber'
                    if ~isa(device, 'mic.interface.device.GetNumber')
                        cMsg = '"mic.ui.device.GetNumber" UI controls require devices that implement the "mic.interface.device.GetNumber" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'warn');
                        l = false;
                        return
                    end
                    
                case 'mic.ui.device.GetText'
                    if ~isa(device, 'mic.interface.device.GetText')
                        cMsg = '"mic.ui.device.GetText" UI controls require devices that implement the "mic.interface.device.GetText" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'warn');
                        l = false;
                        return
                    end
                   
                case 'mic.ui.device.GetLogical'
                    if ~isa(device, 'mic.interface.device.GetLogical')
                        cMsg = '"mic.ui.device.GetLogical" UI controls require devices that implement the "mic.interface.device.GetLogical" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'warn');
                        l = false;
                        return
                    end
                   
            end
            
            l = true;
            
        end
        
        
        function turnOn(this)
        
            if ~this.lDeviceIsSet
                % show message
                
                cMsg = 'Cannot turn on mic.ui.device.* instances until a device that implements mic.interface.device.* has been provided with setDevice()';
                cTitle = 'turnOn() Error';
                msgbox(cMsg, cTitle, 'warn');
                
                this.uitDevice.set(false);
                this.uitDevice.setTooltip(this.cTooltipDeviceOff);
            
                return
            end
            % Channel device  
        % See also TURNOFF

            this.lActive = true;
            
            this.uitDevice.set(true);
            this.uitDevice.setTooltip(this.cTooltipDeviceOn);
            % set(this.hPanel, 'BackgroundColor', this.dColorOn);
            % set(this.hImage, 'Visible', 'off');
                        
            % Update destination values to match device values
            % this.setDestCalDisplay(this.getValCalDisplay());
            
            % Kill the deviceVirtual 
            %{
            if ~isempty(this.deviceVirtual) && ...
                isvalid(this.deviceVirtual)
                delete(this.deviceVirtual);
            end
            %}
            
            notify(this, 'eTurnOn');
            
        end
        
        
        function turnOff(this)
        
            % CA 2014.04.14: Make sure Devicev is available
            
            if isempty(this.deviceVirtual)
                this.setDeviceVirtual(this.newDeviceVirtual());
            end
            
            this.lActive = false;
            this.uitDevice.set(false);
            this.uitDevice.setTooltip(this.cTooltipDeviceOff);
            
            % this.setDestCalDisplay(this.getValCalDisplay());
            % set(this.hImage, 'Visible', 'on');
            % set(this.hPanel, 'BackgroundColor', this.dColorOff);
            
            notify(this, 'eTurnOff');
        end
        
        function initialize(this)
            
            this.lIsInitializing = true;
            this.getDevice().initialize();
            
        end

    end
    
    methods (Access = protected)
        
        
        function initDeviceToggle(this)
            
            this.uitxLabelDevice = mic.ui.common.Text(...
                'cVal', this.cLabelDevice, ...
                'cAlign', 'center'...
            );
        
            st1 = struct();
            st1.lAsk        = this.lAskOnDeviceClick;
            st1.cTitle      = 'Switch?';
            st1.cQuestion   = 'Do you want to change from the virtual Device to the real Device?';
            st1.cAnswer1    = 'Yes of course!';
            st1.cAnswer2    = 'No not yet.';
            st1.cDefault    = st1.cAnswer2;


            st2 = struct();
            st2.lAsk        = this.lAskOnDeviceClick;
            st2.cTitle      = 'Switch?';
            st2.cQuestion   = 'Do you want to change from the real Device to the virtual Device?';
            st2.cAnswer1    = 'Yes of course!';
            st2.cAnswer2    = 'No not yet.';
            st2.cDefault    = st2.cAnswer2;

            this.uitDevice = mic.ui.common.Toggle( ...
                'cTextFalse', 'enable', ...   
                'cTextTrue', 'disable', ...  
                'lImg', true, ...
                'u8ImgOff', this.u8ToggleOff, ...
                'u8ImgOn', this.u8ToggleOn, ...
                'stF2TOptions', st1, ...
                'stT2FOptions', st2 ...
            );
        
            this.uitDevice.disable();
            
            addlistener(this.uitDevice,   'eChange', @this.onDeviceChange);
        end
        
        
        function initInitializeToggle(this)
            
            this.uitxLabelInit = mic.ui.common.Text(...
                'cVal', this.cLabelInit, ...
                'cAlign', 'center' ...
            );
        
            this.uibInit = mic.ui.common.Button( ...
                'cText', 'Init', ...
                'lImg', true, ...
                'u8Img', this.u8InitFalse, ...
                'lAsk', true, ...
                'cMsg', 'Are you sure you want to initialize this device?  It may take a couple minutes.' ...
            );
            this.uibInit.setTooltip(this.cTooltipInitButton);
            addlistener(this.uibInit,   'eChange', @this.onInitChange);

        end
        
        
        function initInitializeStateImageLogical(this)
            
            this.uiilInitState = mic.ui.common.ImageLogical();
            this.uitxLabelInitState = mic.ui.common.Text(...
                'cVal', this.cLabelInitState, ...
                'cAligh', 'center' ...
            );
        
        
        end
        
        function init(this)
            
            % Stuff common to all mic.ui.device.*
            this.initDeviceToggle();
            this.initInitializeToggle();
            this.initInitializeStateImageLogical();
        
        end
        
        function onDeviceChange(this, src, evt)
            if src.get()
                this.turnOn();
            else
                this.turnOff();
            end
        end
        
        
        function onInitChange(this, src, evt)
            
            this.msg('onInitChange()');
            
            this.initialize()
            
        end
        
        
        
        
        
    end
    
end

