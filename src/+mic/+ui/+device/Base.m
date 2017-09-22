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
    
    properties (SetAccess = private)
        
        % {uint8 24x24} images for play/pause
        u8Play = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'play-24.png'));
        u8Pause = imread(fullfile(mic.Utils.pathImg(), 'play', '4', 'pause-24.png'));
        
        % {uint8 24x24} - images for the device real/virtual toggle
        u8ToggleOn = imread(fullfile(mic.Utils.pathImg(), 'toggle', 'horiz-1', 'toggle-horiz-24-true.png'));     
        u8ToggleOff = imread(fullfile(mic.Utils.pathImg(), 'toggle', 'horiz-1', 'toggle-horiz-24-false-yellow.png'));           
        
        % {uint8 24x24} - images for the initialize button/state UI
        u8InitTrue = imread(fullfile(mic.Utils.pathImg(), 'init', 'init-button-true.png'));
        u8InitFalse = imread(fullfile(mic.Utils.pathImg(), 'init', 'init-button-false-yellow.png'));
    end
    
    methods 
        
        function this = Base()

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
            
            switch class(this)
                case 'mic.ui.device.GetSetNumber'
                    if ~isa(device, 'mic.interface.device.GetSetNumber')
                        cMsg = '"mic.ui.device.GetSetNumber" UI controls require devices that implement the "mic.interface.device.GetSetNumber" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'error');
                        return
                    end
                case 'mic.ui.device.GetSetText'
                    if ~isa(device, 'mic.interface.device.GetSetText')
                        cMsg = '"mic.ui.device.GetSetText" UI controls require devices that implement the "mic.interface.device.GetSetText" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'error');
                        return
                    end
                   
                case 'mic.ui.device.GetSetLogical'
                    if ~isa(device, 'mic.interface.device.GetSetLogical')
                        cMsg = '"mic.ui.device.GetSetLogical" UI controls require devices that implement the "mic.interface.device.GetSetLogical" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'error');
                        return
                    end
                   
                case 'mic.ui.device.GetNumber'
                    if ~isa(device, 'mic.interface.device.GetNumber')
                        cMsg = '"mic.ui.device.GetNumber" UI controls require devices that implement the "mic.interface.device.GetNumber" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'error');
                        return
                    end
                    
                case 'mic.ui.device.GetText'
                    if ~isa(device, 'mic.interface.device.GetText')
                        cMsg = '"mic.ui.device.GetText" UI controls require devices that implement the "mic.interface.device.GetText" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'error');
                        return
                    end
                   
                case 'mic.ui.device.GetLogical'
                    if ~isa(device, 'mic.interface.device.GetLogical')
                        cMsg = '"mic.ui.device.GetLogical" UI controls require devices that implement the "mic.interface.device.GetLogical" interface.';
                        cTitle = 'Device error';
                        msgbox(cMsg, cTitle, 'error');
                        return
                    end
                   
            end
            
            this.device = device;
        end
                
        function setDeviceVirtual(this, device)
            if ~isempty(this.deviceVirtual) && ...
                isvalid(this.deviceVirtual)
                delete(this.deviceVirtual);
            end
            this.deviceVirtual = device;
            
        end
                
        
    end
    
end

