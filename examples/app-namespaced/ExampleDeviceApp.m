classdef ExampleDeviceApp < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        clock
        vendorDevice
        uiDeviceX
        uiDeviceY
        uiDeviceMode
        uiDeviceAwesome
        uiToggleAll
        
        hFigure
    end
    
    methods
        
        function this = ExampleDeviceApp()
            
            this.initClock();
            this.initUi();
            this.addUiListeners();
            this.initDevices();
            this.build();
            
        end
        
        function initClock(this)
            this.clock = mic.Clock('master');
        end
        
        function initUi(this)
            

            this.uiDeviceX = mic.ui.device.GetSetNumber( ...
                'cName', 'x', ...
                'clock', this.clock, ...
                'cLabel', 'x' ...
            );

            this.uiDeviceY = mic.ui.device.GetSetNumber( ...
                'cName', 'y', ...
                'clock', this.clock, ...
                'cLabel', 'y', ...
                'lShowLabels', false ...
            );

            this.uiDeviceMode = mic.ui.device.GetText( ...
                'clock', this.clock, ...
                'cName', 'mode', ...
                'cLabel', 'mode', ...
                'lShowLabels', false ...
            );

            this.uiDeviceAwesome = mic.ui.device.GetSetLogical( ...
                'clock', this.clock, ...
                'cName', 'awesome', ...
                'cLabel', 'awesome', ...
                'lShowLabels', false ...
            );


            this.uiToggleAll = mic.ui.common.Toggle(...
                'cTextFalse', 'Turn On All', ...
                'cTextTrue', 'Turn Off All' ...
            );
        
        end
        
        
        function addUiListeners(this)
            
            addlistener(this.uiToggleAll, 'eChange', @this.onToggleAllChange);

        end
        
        
        function initDevices(this)
            
            this.vendorDevice = VendorDevice();
            
            % You can store a reference to these devices you want but there
            % is no need since you can access thrm through the
            % mic.ui.device.*

            getSetNumberX = VendorDevice2GetSetNumber(this.vendorDevice, 'x');
            getSetNumberY = VendorDevice2GetSetNumber(this.vendorDevice, 'y');
            getTextMode = VendorDevice2GetText(this.vendorDevice, 'mode');
            getSetLogicalAwesome = VendorDevice2GetSetLogical(this.vendorDevice, 'awesome');

            this.uiDeviceX.setDevice(getSetNumberX);
            this.uiDeviceY.setDevice(getSetNumberY);
            this.uiDeviceMode.setDevice(getTextMode);
            this.uiDeviceAwesome.setDevice(getSetLogicalAwesome);
            
        end
        
        function build(this)
            
            this.hFigure = figure();
            this.uiDeviceX.build(this.hFigure, 10, 10);
            this.uiDeviceY.build(this.hFigure, 10, 80);
            this.uiDeviceMode.build(this.hFigure, 10, 130);
            this.uiDeviceAwesome.build(this.hFigure, 10, 170);
            this.uiToggleAll.build(this.hFigure, 10, 210, 80, 30);
            
        end
        
        
        function turnOnAllDeviceUi(this)
            this.uiDeviceX.turnOn();
            this.uiDeviceY.turnOn();
            this.uiDeviceMode.turnOn();
            this.uiDeviceAwesome.turnOn();
        end
        
        function turnOffAllDeviceUi(this)
            this.uiDeviceX.turnOff();
            this.uiDeviceY.turnOff();
            this.uiDeviceMode.turnOff();
            this.uiDeviceAwesome.turnOff();
            
        end
    
    end
    
    
    methods (Access = protected)
        
        function onToggleAllChange(this, src, evt)
            
            if this.uiToggleAll.get()
                this.turnOnAllDeviceUi();
            else
                this.turnOffAllDeviceUi()
            end
            
        end
        
    end
    
end

