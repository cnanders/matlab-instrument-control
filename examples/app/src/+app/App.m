classdef App < handle
    
    properties
        
        clock
        vendorDevice
        uiDeviceX
        uiDeviceY
        uiDeviceMode
        uiDeviceAwesome
        uiToggleAll
        uiButtonUseDeviceData
        
        hFigure
    end
    
    properties (Access = private)
        cDirSave
    end
    
    methods
        
        function this = App()
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSave = fullfile( ...
                cDirThis, ...
                '..', ...
                '..', ...
                'save' ...
            );
        
            this.initClock();
            this.initUi();
            this.addUiListeners();
            this.setUiTooltips();
            this.initDevices();
            this.build();
            
            this.loadStateFromDisk();
            
        end
        
        function initClock(this)
            this.clock = mic.Clock('app');
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
        
            this.uiButtonUseDeviceData = mic.ui.common.Button(...
                'cText', 'Use Device Data' ...
            );
        
        end
        
        function setUiTooltips(this)
            
            this.uiButtonUseDeviceData.setTooltip('Click me to echo the value of each device to the command line')
            
        end
        
        function addUiListeners(this)
            
            addlistener(this.uiToggleAll, 'eChange', @this.onToggleAllChange);
            addlistener(this.uiButtonUseDeviceData, 'eChange', @this.onButtonUseDeviceDataChange);
        end
        
        
        function initDevices(this)
            
            this.vendorDevice = VendorDevice();
            
            % You can store a reference to these devices you want but there
            % is no need since you can access thrm through the
            % mic.ui.device.*

            getSetNumberX = app.device.VendorDevice2GetSetNumber(this.vendorDevice, 'x');
            getSetNumberY = app.device.VendorDevice2GetSetNumber(this.vendorDevice, 'y');
            getTextMode = app.device.VendorDevice2GetText(this.vendorDevice, 'mode');
            getSetLogicalAwesome = app.device.VendorDevice2GetSetLogical(this.vendorDevice, 'awesome');

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
            this.uiToggleAll.build(this.hFigure, 10, 210, 120, 30);
            this.uiButtonUseDeviceData.build(this.hFigure, 10, 250, 120, 30);
            
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
        
        function delete(this)
            this.saveStateToDisk();

            this.deleteUi();
        end
        
        function deleteUi(this)
                        
            delete(this.uiDeviceX);
            delete(this.uiDeviceY);
            delete(this.uiDeviceMode);
            delete(this.uiDeviceAwesome);
            delete(this.uiButtonUseDeviceData);
            delete(this.uiToggleAll);
            delete(this.clock);
            
        end
        
        function st = save(this)
           st = struct();
           st.uiDeviceX = this.uiDeviceX.save();
           st.uiDeviceY = this.uiDeviceY.save();
        end
        
        function load(this, st)
           this.uiDeviceX.load(st.uiDeviceX);
           this.uiDeviceY.load(st.uiDeviceY);
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
        
        
        function onButtonUseDeviceDataChange(this, src, evt)
            
            this.uiDeviceX.getValCalDisplay()
            this.uiDeviceY.getValCalDisplay()
            this.uiDeviceMode.get()
            this.uiDeviceAwesome.get()
            
        end
        
        function saveStateToDisk(this)
            st = this.save();
            save(this.file(), 'st');
            
        end
        
        function loadStateFromDisk(this)
            if exist(this.file(), 'file') == 2
                fprintf('loadStateFromDisk()\n');
                load(this.file()); % populates variable st in local workspace
                this.load(st);
            end
        end
        
        function c = file(this)
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['saved-state', '.mat']...
            );
        end
        
    end
    
end

