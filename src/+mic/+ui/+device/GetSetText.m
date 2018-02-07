classdef GetSetText < mic.interface.ui.device.GetSetText & ...
                      mic.ui.device.Base
    
    properties (Constant)
       
    end

    properties      
        u8UnitIndex = 1;
    end

    properties (SetAccess = private)
        
        % {char 1xm} name MUST BE UNIQUE within entire application
        cName = 'CHANGE ME'
        

    end

    properties (Access = protected)
        
        % {double 1x1} height of the UI element
        dHeight = 24;   
        dHeightLabel = 16;
        dHeightBtn = 24;
        dHeightEdit = 24;
        dHeightPopup = 24;
        dHeightText = 16;
        

        dWidthName = 50;
        dWidthVal = 75;
        dWidthUnit = 80;
        dWidthDest = 50;
        dWidthBtn = 24;
        dWidthStores = 100;
        dWidthStep = 50;
        
        
        dWidthPadDevice = 0;
        dWidthPadInitButton = 0;
        dWidthPadName = 5;
        dWidthPadVal = 0;
        dWidthPadDest = 5;
        dWidthPadPlay = 0;
        dWidthPadStores = 0;
        
        dWidthStatus = 5;
        
        
        cLabelName = 'Name'
        cLabelValue = 'Value'
        cLabelDest = 'Goal'
        cLabelPlay = 'Go'
        cLabelStores = 'Stores';
        
        
        clock       % clock 
        cLabel = 'CHANGE ME' % name to be displayed by the UI element
        cDir        % current directory
        cDirSave    
        

        uieDest     % textbox to input the desired position
        uitxVal     % label to display the current value
        
        
        uibtPlay     % 2014.11.19 - Using a button instead of a toggle
        
        uitxName  % label to displau the name of the element
        
        
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff   = [244 245 169]./255;
        dColorOn    = [241 241 241]./255; 
        
                
        config
        dZeroRaw = 0;
        fhValidateDest
        dValRaw % value in raw units (updated by clock)
        
        uipStores % UIPopupStruct
        
        lShowName = true
        lShowVal = true
        lShowDest = true
        lShowPlay = true
        lShowLabels = true
        lShowStores = true
        lShowDevice = true
        lDisableSet = false
        lShowInitButton = true
                
        uitxLabelName
        uitxLabelVal
        uitxLabelDest
        uitxLabelStores
        uitxLabelPlay
        
        % {char 1xm} storage of the last display value.  Used to emit
        % eChange events
        cValPrev = '...'
        
           
        
        % {logical 1x1} true when stopped or at its target
        lReady = true
        
       
        % RM (2/2018): Adding new methods for implementing function callback mode:
        % {function handle 1x1} 
        fhGet = @() ''

        % {function handle 1x1} 
        fhSet = @(cVal) []

        % {function handle 1x1} 
        fhIsInitialized

        % {function handle 1x1} 
        fhInitialize

        fhIsVirtual = @() true % overload this otherwise will always use virtual
        fhGetV 
        fhSetV
        fhIsInitializedV
        fhInitializeV
        
    end
    

    events
        
        eUnitChange
        eChange
    end

    
    methods       
        
        % See HardwareIOPlus documentation
        
        function this = GetSetText(varargin)  
                  
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_DEVICE);
            
            % Default properties
            this.fhValidateDest = this.validateDest;
            this.config = mic.config.GetSetText();
            
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 6);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
                           
            this.cDirSave = fullfile( ...
                mic.Utils.pathSave(), ...
                'ui', ...
                'get-set-text' ...
            );
            
            if this.lDisableSet == true
                this.lShowStores = false; 
                this.lShowPlay = false; 
                this.lShowDest = false; 
            end
            
            this.init();
        end

        

        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element associated with the class
        %   HardwareIO.build(hParent, dLeft, dTop)
        %
        % See also HARDWAREIO, INIT, DELETE       
            
        
            
            
            dHeight = this.dHeight;
            if this.lShowLabels
                dHeight = dHeight + this.dHeightLabel;
            end

            dWidth = this.getWidth();

            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent));
            drawnow

            axis('image');
            axis('off');

            dTop = -1;
            dTopLabel = -1;
            if this.lShowLabels
                dTop = this.dHeightLabel;
            end

            dLeft = 0;

            % Device toggle
            if (this.lShowDevice)
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

            % Val
            if this.lShowVal
                dLeft = dLeft + this.dWidthPadVal;
                if this.lShowLabels
                    this.uitxLabelVal.build(this.hPanel, dLeft, dTopLabel, this.dWidthVal, this.dHeightLabel);
                end
                this.uitxVal.build(this.hPanel, dLeft,  dTop + (this.dHeight - this.dHeightText)/2, this.dWidthVal, this.dHeightText);
                dLeft = dLeft + this.dWidthVal + 5;
            end

            % Dest
            if this.lShowDest
                dLeft = dLeft + this.dWidthPadDest;
                if this.lShowLabels
                    this.uitxLabelDest.build(this.hPanel, dLeft, dTopLabel, this.dWidthDest, this.dHeightLabel);
                end
                this.uieDest.build(this.hPanel, dLeft, dTop, this.dWidthDest, this.dHeightEdit);
                dLeft = dLeft + this.dWidthDest;
            end


            % Play
            if this.lShowPlay
                dLeft = dLeft + this.dWidthPadPlay;
                if this.lShowLabels
                    this.uitxLabelPlay.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibtPlay.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;

            end 

            % Stores
            if this.lShowStores && ...
               ~isempty(this.config.ceStores)
                
                dLeft = dLeft + this.dWidthPadStores;
                if this.lShowLabels
                    this.uitxLabelStores.build(this.hPanel, dLeft, dTopLabel, this.dWidthStores, this.dHeightLabel);
                end
                
               
                
                this.uipStores.build(this.hPanel, dLeft, dTop, this.dWidthStores, this.dHeightPopup);
                dLeft = dLeft + this.dWidthStores;
            end

        end
      
        
        function moveToDest(this)
        %MOVETODEST Performs the HIO motion to the destination shown in the
        %GUI display.  It converts from the display units to raw and tells
        %the Device 
        %   HardwareIO.moveToDest()
        %
        %   See also SETDESTCAL, SETDESTRAW, MOVE
        
            this.msg(sprintf('moveToDest %s', this.uieDest.get()));
            
            if this.fhValidateDest() ~= true                
                this.msg('moveToDest returning');
                return;
                
            end
            
            
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    this.fhSetV(this.uieDest.get());
                else
                    this.fhSet(this.uieDest.get());
                end
            else
                this.getDevice().set(this.uieDest.get());
            end

                       
        end
        
        
        
        
        
       
      
        
        
        
        function delete(this)
        %DELETE Class Destructor
        %   HardwareIO.Delete()
        %
        % See also HARDWAREIO, INIT, BUILD

            this.msg('delete', this.u8_MSG_TYPE_CLASS_INIT_DELETE);
            this.save();
            
           % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.clock.remove(this.id());
            end
            
            % The Devicev instances have clock tasks so need to delete them
            % first
            
            delete(this.deviceVirtual);
            
            if ~isempty(this.device) && ... % isvalid(this.device) && ...
                isa(this.device, 'DevicevGetSetText')
                delete(this.device)
            end
            
            delete(this.uieDest);  
            delete(this.uitxVal);
            delete(this.uitDevice);
            delete(this.uibtPlay);
            delete(this.uitxName);
            delete(this.uipStores);
            
            delete(this.uitxLabelName);
            delete(this.uitxLabelVal);
            delete(this.uitxLabelDest);
            delete(this.uitxLabelStores);
            delete(this.uitxLabelPlay);
            delete(this.uitxLabelDevice);
                      
            delete(this.config)

                        
        end
        
        function onClock(this) 
        %onClock Callback triggered by the clock
        %   HardwareIO.onClock()
        %   updates the position reading and the hio status (=/~moving)
        
            try
                if this.lUseFunctionCallbacks
                    cVal = this.fhGet();
                else
                    cVal = this.getDevice().get();
                end

                
            catch mE
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
        
                % CA 2016 remove the task from the timer
                if isvalid(this.clock) && ...
                   this.clock.has(this.id())
                    this.clock.remove(this.id());
                end
            end
            
            if ~strcmp(this.cValPrev, cVal)
                notify(this, 'eChange');
            end
            this.uitxVal.set(cVal);
            
            this.updateInitializedButton();
                
            
        end 
        
        function c = get(this)
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    c = this.fhGetV();
                else
                    c = this.fhGet();
                end
            else
                c = this.getDevice().get();
            end

        end
        
        function c = getDest(this)
            c = this.uieDest.get();
        end
        
        function setDest(this, cVal)
            this.uieDest.set(cVal);
        end
        
        
        function enable(this)
            this.uieDest.enable();
            this.uibInit.enable();

            this.uitxVal.enable();
            this.uitDevice.enable();
            this.uibtPlay.enable();
            this.uitxName.enable();
            this.uipStores.enable();
            
            this.uitxLabelInit.enable();
            this.uitxLabelName.enable();
            this.uitxLabelVal.enable();
            this.uitxLabelDest.enable();
            this.uitxLabelPlay.enable();
            this.uitxLabelDevice.enable();
            this.uitxLabelStores.enable();

        end
        
        
        
        function disable(this)
            this.uieDest.disable();
            this.uibInit.disable();

            this.uitxVal.disable();
            this.uitDevice.disable();
            this.uibtPlay.disable();
            this.uitxName.disable();
            this.uipStores.disable();
            
            this.uitxLabelInit.disable();
            this.uitxLabelName.disable();
            this.uitxLabelVal.disable();
            this.uitxLabelDest.disable();
            this.uitxLabelPlay.disable();
            this.uitxLabelDevice.disable();
            this.uitxLabelStores.disable();
        end
        
        function st = save(this)
            st = struct();
            st.uieDest = this.uieDest.save();
        end
                
        function load(this, st)
            
            this.msg('load()');
    
            if  this.lShowDest && ...
                ~isempty(this.uieDest)
                this.uieDest.load(st.uieDest)
            end

        end
        
        
       
        

    end %methods
    
    methods (Access = protected)
            

        function init(this)           
        %INIT Initializes the class
        %   HardwareIO.init()
        %
        % See also HARDWAREIO, INIT, BUILD
        
            init@mic.ui.device.Base(this);                        

            %GoTo button
            this.uibtPlay = mic.ui.common.ButtonToggle( ...
                'lImg', true, ...
                'u8ImgT', this.u8Pause, ...
                'u8ImgF', this.u8Play ...
            );
        
            
            % Dest
            this.uieDest = mic.ui.common.Edit('lShowLabel', false);
            
            % Value
            this.uitxVal = mic.ui.common.Text('cVal', '...');

            % Name (on the left)
            this.uitxName = mic.ui.common.Text('cVal', this.cLabel);

            % Set virtual device callbacks
            vdVirtualDevice         = this.newDeviceVirtual();
            this.fhGetV             = @()vdVirtualDevice.get();
            this.fhSetV             = @(cVal)vdVirtualDevice.set(cVal);
            this.fhIsInitializedV   = @()vdVirtualDevice.isInitialized();
            this.fhInitializeV      = @()vdVirtualDevice.initialize();
        
            this.setDeviceVirtual(vdVirtualDevice);
            
            % if ~isempty(this.config.ceStores)
                this.uipStores = mic.ui.common.PopupStruct(...
                    'ceOptions', this.config.ceStores, ...
                    'lShowLabel', false, ...
                    'cField', 'name' ...
                );
                
                addlistener(this.uipStores,   'eChange', @this.onStoresChange);
                this.uipStores.setTooltip('Go to a stored position');                
            % end
                        
            addlistener(this.uieDest,   'eChange', @this.onDestChange);
            %AW(5/24/13) : populating the destination
            this.uieDest.set(this.deviceVirtual.get());
            
            addlistener(this.uibtPlay,   'eChange', @this.onPlayChange);

          
            
            this.uitxLabelName = mic.ui.common.Text('cVal', this.cLabelName);
            this.uitxLabelVal = mic.ui.common.Text('cVal', this.cLabelValue);
            this.uitxLabelDest = mic.ui.common.Text('cVal', this.cLabelDest);
            this.uitxLabelPlay = mic.ui.common.Text('cVal', this.cLabelPlay);
            
            this.uitxLabelStores = mic.ui.common.Text('cVal', this.cLabelStores);
            
            this.uitDevice.setTooltip(this.cTooltipDeviceOff);
            this.uitxName.setTooltip('The name of this device');
            this.uitxVal.setTooltip('The value of this device');
            this.uieDest.setTooltip('Change the goal value');
            this.uibtPlay.setTooltip('Go to goal');
                        
            if ~isempty(this.clock)
                this.clock.add(@this.onClock, this.id(), this.config.dDelay);
            end
            
            
        end
        

        
        
        function onStoresChange(this, src, evt)
            this.setDest(this.uipStores().get().val);
            this.moveToDest();
        end
        
        function onDestChange(this, src, evt)
            % notify(this, 'eChange');
        end
                
        function onPlayChange(this, src, evt)
            this.moveToDest();
        end
        
        
        
        % Deprecated (un-deprecitate if you want to move to dest on enter
        % keypress
        
        function onDest(this, src, evt)
            if uint8(get(this.hParent,'CurrentCharacter')) == 13
                this.moveToDest();
            end
        end
        
       

        function updatePlayButton(this)
            
            % UIButtonTobble
            if this.lReady && ~this.uibtPlay.get()
                this.uibtPlay.set(true);
            end

            if ~this.lReady && this.uibtPlay.get()
                this.uibtPlay.set(false);
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
        
        function lOut = validateDest(this)
            lOut = true;
        end
                
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowDevice
               dOut = dOut + this.dWidthPadDevice + this.dWidthBtn;
            end
            
            if this.lShowInitButton
               dOut = dOut + this.dWidthPadInitButton + this.dWidthBtn;
            end

            if this.lShowName
                dOut = dOut + this.dWidthPadName + this.dWidthName;
            end
            
            if this.lShowVal
                dOut = dOut + this.dWidthPadVal + this.dWidthVal;
            end
            
            if this.lShowDest
                dOut = dOut + this.dWidthPadDest + this.dWidthDest;
            end
            if this.lShowPlay
                dOut = dOut + this.dWidthPadPlay + this.dWidthBtn;
            end
            
            if this.lShowStores && ~isempty(this.config.ceStores)
                dOut = dOut + this.dWidthPadStores + this.dWidthStores;
            end
                        
            
        end
        
        function device = newDeviceVirtual(this)
            if this.lDisableSet
                device = mic.device.GetText();
            else
                device = mic.device.GetSetText();
            end
        end
        

        
        
        
    end

end %class
