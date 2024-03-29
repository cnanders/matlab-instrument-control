
classdef GetSetNumber < mic.interface.ui.device.GetSetNumber & ...
                        mic.ui.device.Base 
    
%HARDWAREIO Class that creates the controls to a specific piece of hardware
% Contrary to Axis Class, this class is meant to have direct access to the
% hardware (whatever it is : motor, galvo, etc)
%
%   hio = HardwareIO('name', clock)creates an instance with a name 'name'
%   hio = HardwareIO('name', clock, 'display name') will do the same, except
%       that the displayed name will not be default 'name'
%
% See also HARDWAREO, AXIS
    
    % Hungarian: hio

    properties (Constant)
        
    end

    properties      
        % {uint8 1x1} storage of the index of uipUnit
        u8UnitIndex = uint8(1);
        % {double 1x1 zero offset in raw units when in relative mode}
        dOffsetRel = 0;
        % {logical 1x1 value of uitRel}
        lRelVal = false;
    end

    properties (SetAccess = private)
        
        % @param {char 1xm} cName - the name of the instance.  
        %   Must be unique within the entire project / codebase
        cName = 'CHANGE ME' % name identifier
        
        lReady = false  % true when stopped or at its target
        
        % {logical 1x1} store if delete() has been called.  When true,
        % immediately back out of onClock()
        lDeleted = false
        
        % @param {uint8 1x1} [u8Layout = uint8(1)] - the layout.  1 = wide, not
        %   tall. 2 = narrow, twice as tall. 
        u8Layout = uint8(1); 
        % lIsThere 


        


    end

    properties (SetAccess = private, GetAccess = protected)
        
        dHeight = 26;   % height of the row for controls
        dHeightBtn = 24;
        dHeightEdit = 24;
        dHeightPopup = 24;
        dHeightLabel = 16;
        dHeightText = 16;
        
        dWidthName = 50;
        dWidthVal = 75;
        dWidthUnit = 80;
        dWidthDest = 50;
        dWidthEdit = 70;
        dWidthBtn = 24;
        dWidthStores = 100;
        dWidthStep = 50;
        dWidthRange = 120;
        
        dWidthPadDevice = 0;
        dWidthPadInitButton = 0;
        dWidthPadInitState = 0;
        dWidthPadName = 5;
        dWidthPadVal = 0;
        dWidthPadDest = 5;
        dWidthPadPlay = 0;
        dWidthPadJog = 0;
        dWidthPadStepNeg = 0;
        dWidthPadStep = 0;
        dWidthPadStepPos = 0;
        dWidthPadUnit = 0;
        dWidthPadRel = 0;
        dWidthPadZero = 0;
        dWidthPadStores = 0;
        dWidthPadRange = 5;
        
        dWidth2 = 250;
        dHeight2 = 50;
        dPad2 = 0;
        dWidthStatus = 5;
        
        
        cLabelName = 'Name';
        cLabelValue = 'Val';
        cLabelDest = 'Goal'
        cLabelPlay = 'Go'
        cLabelStores = 'Stores'
        cLabelRange = 'Range'
        cLabelUnit = 'Unit'
        cLabelJogL = '';
        cLabelJog = 'Step';
        cLabelJogR = '';
        
        
        
        % @param {clock 1x1} clock - the clock
        clock 
        % @param {char 1x1} cLabel - the label in the GUI
        cLabel = 'CHANGE ME' % name to be displayed by the UI element
        cDir        % current directory
        cDirSave    
        

        uieDest     % textbox to input the desired position
        uieStep     % textbox to input the desired step in disp units
        uitxVal     % label to display the current value
        

        uibtPlay     % 2014.11.19 - Using a button instead of a toggle
        uitRel      % mic.ui.common.Toggle to switch between abs units and rel units (rel to the value when the toggle was clicked)      
        uibZero     % Button to store current position as zero
        
        uibStepPos  % button to perform a positive step move
        uibStepNeg  % button to perform a negative step move
        uitxName  % label to displau the name of the element
        uipUnit    % popup menu
        
        
        hPanel      % panel container for the UI element
        hAxes       % container for th UI images
        hImage      % container for th UI images
        dColorOff   = [244 245 169]./255;
        dColorOn    = [241 241 241]./255; 
        
        dColorBg = [.94 .94 .94]; % MATLAB default
        
        
        dColorTextMoving = [56 162 183]/255; %[219 237 247]/255; %[0 170 0]./255;
        dColorTextStopped = [0 0 0]./255;
        dColorTextWarning = [170 170 0]./255;
        
        
        u8Bg
                
        
        %u8Plus = imread(fullfile(mic.Utils.pathImg(), 'axis-plus-24.png'));
        %u8Minus = imread(fullfile(mic.Utils.pathImg(), 'axis-minus-24.png'));
        u8Plus = imread(fullfile(mic.Utils.pathImg(), 'jog', 'axis-step-forward-24-7.png'));
        u8Minus = imread(fullfile(mic.Utils.pathImg(), 'jog', 'axis-step-back-24-7.png'));
        
        %u8Rel = imread(fullfile(mic.Utils.pathImg(), 'abs-rel', '1', 'rel-24.png'));
        %u8Abs = imread(fullfile(mic.Utils.pathImg(), 'abs-rel', '1', 'abs-24.png'));
        %u8Zero = imread(fullfile(mic.Utils.pathImg(), 'zero', 'axis-zero-24-2.png'));
        
        u8Rel = imread(fullfile(mic.Utils.pathImg(), 'abs-rel', '5', 'rel-24.png'));
        u8Abs = imread(fullfile(mic.Utils.pathImg(), 'abs-rel', '5', 'abs-24.png'));
        u8Zero = imread(fullfile(mic.Utils.pathImg(), 'set', 'set-24.png'));
        
        
        % @param {ConfigGetSetNumber 1x1} [config = new ConfigGetSetNumber()] - the config instance
        %   !!! WARNING !!!
        %   DO NOT USE a single Config for multiple HardwareIO instances
        %   because deleting one HardwareIO will delete the reference to
        %   the Config instance that the other Hardware IO is using
        config
        
        % @param {function_handle 1x1} a function that returns a
        %   locical that validates if the requested move is allowed.
        %   It is called within moveToDest() and if it returns false, a
        %   message is displayed sayint the current move is not
        %   allowed.  Is expected that the higher-level class that
        %   implements this (which may access more than one HardwareIO
        %   instance) implements this function
        fhValidateDest = @() true
        
        
        uipStores % UIPopupStruct
        
        % {char 1xm} - string format for value. See formatSpec. 'e', 'f'
        % asupported as of 2016.10.24.  To add support for other formats,
        % search for uitxVal.cVal and add more to the switch block.
        cConversion = 'f'; 
       
        % {logical 1x1} - show the clickable toggle / status that shows if
        % is using real Device or virtual Device
        lShowDevice = false
        % {logical 1x1} - show the clickable initialize toggle
        lShowInitButton = false
        % {logical 1x1} - show isInitialized() state
        lShowInitState = false
        % {logical 1x1} - show the name (on left)
        lShowName = true;
        % {logical 1x1} - show the value (right of the edit)
        lShowVal = true;
        % {logical 1x1}
        lShowUnit = true;
        % {logical 1x1} - show the "set/re-zero" button
        lShowZero = true
        % {logical 1x1}
        lShowRel = true
        % {logical 1x1}
        lShowJog = true
        % {logical 1x1}
        lShowStepNeg = true
        % {logical 1x1}
        lShowStep = true
        % {logical 1x1}
        lShowStepPos = true;
        % {logical 1x1}
        lShowDest = true
        % {logical 1x1}
        lShowPlay = true
        % {logical 1x1} - labels above name, val, dest, play, jog, etc.
        lShowLabels = true
        % {logical 1x1} - show the list of stored positions (only if they
        % are present in config)
        lShowStores = true
        
        
        
        % {logical 1x1} - show allowed range (config.min - config.max)
        lShowRange = false
        
        % {logical 1x1} - disable the "set" part of GetSet (removes jog,
        % play, dest, stores)
        lDisableSet = false
        
        % {logical 1x1} - enable to have config file set valid destinations
        lValidateByConfigRange = false
        
        lDisableMoveToDestOnDestEnter = false
                
        uitxLabelName
        uitxLabelVal
        uitxLabelUnit
        uitxLabelDest
        uitxLabelJog
        uitxLabelJogL
        uitxLabelJogR
        uitxLabelStores
        uitxLabelPlay
        
        uitxLabelRange
        
        uitxRange
        
        % {char 1xm} storage of the last display value.  Used to emit
        % eChange events
        cValPrev = '...'
        
        % {char 1xm} - type to use for mic.ui.common.Edit for the destination
        % This ended up opening up a can of worms.  All of the raw/cal
        % logic assumes we are dealing with doubles, not uint or int.  For
        % now, I'm going to cast all values as double
        % cTypeDest = 'd'
        
        dValDeviceDefault = 0
        
        % RM (2/2018): Adding new methods for implementing function callback mode:
        % {function handle 1x1} 
        fhGet 

        % {function handle 1x1} 
        fhSet

        % {function handle 1x1} 
        fhStop = @() []

        % {function handle 1x1} 
        fhIsReady = @() true

        % {function handle 1x1} 
        fhIsInitialized = @() true
        
        % {function handle 1x1} - 2019.05.06 configure in
        % mic.ui.device.Base
        % fhInitialize = @() []
        
        % {function handle 1x1} 
        fhIndex = @() []
        
        
        fhGetV 
        fhSetV
        fhIsReadyV
        fhStopV
        fhIsInitializedV
        % fhInitializeV - 2019.05.06 configure in
        % mic.ui.device.Base
        fhIndexV

    end
    

    events
        
        eUnitChange
        eChange

    end

    
    methods       
        
        
        %HARDWAREIO Class constructor
        
        function this = GetSetNumber(varargin)  
                 
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_DEVICE);
            % Default properties
            
            
            
            
            this.msg('constructor() default config = mic.config.GetSetNumber()');
            this.config = mic.config.GetSetNumber();
                       
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if isempty(this.fhValidateDest)
                if (this.lValidateByConfigRange)
                    this.fhValidateDest = @this.validateByConfigRange; 
                else 
                    % By default, fhValidateDest returns true.
                    this.fhValidateDest = this.validateDest;
                end
            end
                
            this.cDirSave = fullfile( ...
                mic.Utils.pathSave(), ...
                'ui', ...
                'get-set-number' ...
            );
                
            
            if this.lDisableSet == true
                this.lShowJog = false;
                this.lShowStepNeg = false;
                this.lShowStep = false;
                this.lShowStepPos = false;
                this.lShowStores = false; 
                this.lShowPlay = false; 
                this.lShowDest = false; 
            end
            
            if this.lUseFunctionCallbacks
                if ~isa(this.fhGet, 'function_handle')
                    error('fhGet must function_handle');
                end
                
                if ~this.lDisableSet
                    if ~isa(this.fhSet, 'function_handle')
                        error('fhSet must function_handle');
                    end
                end
            end
                
            
            this.init();
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
            
            this.uitxLabelDest.setBackgroundColor(dColor);
            this.uitxLabelDevice.setBackgroundColor(dColor);
            this.uitxLabelInit.setBackgroundColor(dColor);
            this.uitxLabelInitState.setBackgroundColor(dColor);
            this.uitxLabelJog.setBackgroundColor(dColor);
            this.uitxLabelJogL.setBackgroundColor(dColor);
            this.uitxLabelJogR.setBackgroundColor(dColor);
            this.uitxLabelName.setBackgroundColor(dColor);
            this.uitxLabelPlay.setBackgroundColor(dColor);
            this.uitxLabelRange.setBackgroundColor(dColor);
            this.uitxLabelStores.setBackgroundColor(dColor);
            this.uitxLabelUnit.setBackgroundColor(dColor);
            this.uitxLabelVal.setBackgroundColor(dColor);
            this.uitxName.setBackgroundColor(dColor);
            this.uitxRange.setBackgroundColor(dColor);
            this.uitxVal.setBackgroundColor(dColor);
            this.uibZero.setColorOfBackground(dColor);
            this.uitRel.setColorOfBackground(dColor);
            this.uipStores.setColorOfBackground(dColor);
            this.uipUnit.setColorOfBackground(dColor);
            this.uieDest.setColorOfBackground(dColor);
            this.uieStep.setColorOfBackground(dColor);
            set(this.hPanel, 'BackgroundColor', dColor);
                       
        end
        
        
        function l = isReady(this)
            
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    l = this.fhIsReadyV();
                else
                    l = this.fhIsReady();
                end
            else
                l = this.getDevice().isReady();
            end
                    
        end
        
        % @param {double 1x1} dVal1 - current calibrated value (calculated
        % using config.slope and config.offset if in REL mode, or this.dOffsetRel if in REL
        % mode)
        % @param {double 1x1} dVal2 - desired calibrated value (used to
        % re-compute this.dOffsetRel)
        
        
        function setValToNewVal(this, dVal1, dVal2)
            
            if  this.uitRel.get()
                dOffset = this.dOffsetRel;
            else
                dOffset = this.getUnit().offset;
            end
            
            dOffsetNew = dOffset - (dVal2 - dVal1)/this.getUnit().slope;
            this.dOffsetRel = dOffsetNew;
            
            this.updateZeroTooltip();
            % Force to "Rel" mode
            this.uitRel.set(true);
            
        end

        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element associated with the class
        %   HardwareIO.build(hParent, dLeft, dTop)
        %
        % See also HARDWAREIO, INIT, DELETE       
            
        
            
                                    %'BorderWidth',0, ... 

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
                'BackgroundColor', this.dColorBg, ...
                'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent));
            drawnow

            %{
            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position',mic.Utils.lt2lb([0 0 this.dWidthStatus dHeight], this.hPanel),...
                'XColor', [0 0 0], ...
                'YColor', [0 0 0], ...
                'HandleVisibility','on', ...
                'Visible', 'off');

            this.hImage = image(this.u8Bg);
            set(this.hImage, 'Parent', this.hAxes);
            %}


            % set(this.hImage, 'CData', imread(fullfile(mic.Utils.pathImg(), 'HardwareIO.png')));

          

            y_rel = -1;


           

            dTop = -1;
            dTop = 0;
            dTopLabel = -1;
            if this.lShowLabels
                dTop = this.dHeightLabel;
            end

            dLeft = 1;

            % Device toggle
            if (this.lShowDevice)
                dLeft = dLeft + this.dWidthPadDevice;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelDevice.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uitDevice.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
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

            if (this.lShowInitState)
                dLeft = dLeft + this.dWidthPadInitState;
                if this.lShowLabels
                    % FIXME
                    this.uitxLabelInitState.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uiilInitState.build(this.hPanel, dLeft, dTop);
                dLeft = dLeft + this.dWidthBtn; 
            end

            % Name
            if this.lShowName
                dLeft = dLeft + this.dWidthPadName;
                if this.lShowLabels
                    this.uitxLabelName.build(this.hPanel, dLeft, dTopLabel, this.dWidthName, this.dHeightLabel);
                end
                this.uitxName.build(this.hPanel, dLeft, dTop + (this.dHeight - this.dHeightText)/2, this.dWidthName, this.dHeightText);
                dLeft = dLeft + this.dWidthName;
            end


            
            % Val
            if this.lShowVal
                dLeft = dLeft + this.dWidthPadVal;
                if this.lShowLabels
                    this.uitxLabelVal.build(this.hPanel, dLeft, dTopLabel, this.dWidthVal, this.dHeightLabel);
                end
                this.uitxVal.build(this.hPanel, dLeft, dTop + (this.dHeight - this.dHeightText)/2, this.dWidthVal, this.dHeightText);
                dLeft = dLeft + this.dWidthVal;
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

            % Jog
            if this.lShowStepNeg
                dLeft = dLeft + this.dWidthPadStepNeg;
                if this.lShowLabels
                    this.uitxLabelJogL.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibStepNeg.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;
                
            end

            if this.lShowStep
                
                dLeft = dLeft + this.dWidthPadStep;
                
                if this.lShowLabels
                    this.uitxLabelJog.build(this.hPanel, dLeft, dTopLabel, this.dWidthStep, this.dHeightLabel);
                end
                this.uieStep.build(this.hPanel, dLeft, dTop, this.dWidthStep, this.dHeightEdit);
                dLeft = dLeft + this.dWidthStep;
                
            end
            
            if this.lShowStepPos

                dLeft = dLeft + this.dWidthPadStepPos;
                if this.lShowLabels
                    this.uitxLabelJogR.build(this.hPanel, dLeft, dTopLabel, this.dWidthBtn, this.dHeightLabel);
                end
                this.uibStepPos.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;

            end

            

            % Stores
            if this.lShowStores
                dLeft = dLeft + this.dWidthPadStores;
                if this.lShowLabels
                    this.uitxLabelStores.build(this.hPanel, dLeft, dTopLabel, this.dWidthStores, this.dHeight);
                end
                
                % Only draw pulldown if not empty
                if ~isempty(this.config.ceStores)
                    this.uipStores.build(this.hPanel, dLeft, dTop, this.dWidthStores, this.dHeightPopup);
                end
                dLeft = dLeft + this.dWidthStores;
            end

            

            % Range
            if this.lShowRange
                dLeft = dLeft + this.dWidthPadRange;
                
                dLeft = dLeft + this.dWidthPadStores;
                if this.lShowLabels
                    this.uitxLabelRange.build(this.hPanel, dLeft, dTopLabel, this.dWidthStores, this.dHeight);
                end
                
                this.uitxRange.build(this.hPanel, dLeft, dTop + (this.dHeight - this.dHeightText)/2, this.dWidthRange, this.dHeightBtn)
                dLeft = dLeft + this.dWidthRange;
            end
            
            
            
            % Unit
            if this.lShowUnit
                dLeft = dLeft + this.dWidthPadUnit;
                if this.lShowLabels
                    this.uitxLabelUnit.build(this.hPanel, dLeft, dTopLabel, this.dWidthUnit, this.dHeight);
                end
                this.uipUnit.build(this.hPanel, dLeft, dTop, this.dWidthUnit, this.dHeightPopup);
                dLeft = dLeft + this.dWidthUnit;
            end
            
            % Abs/Rel (to zero)
            if this.lShowRel
                dLeft = dLeft + this.dWidthPadRel;
                this.uitRel.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;
            end

            % Zero
            if this.lShowZero
                dLeft = dLeft + this.dWidthPadZero;
                this.uibZero.build(this.hPanel, dLeft, dTop, this.dWidthBtn, this.dHeightBtn);
                dLeft = dLeft + this.dWidthBtn;
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


        % RM 11.28.14: Need to expose a method that checks if hardware IO
        % is at its desired position:
        

        function stepPos(this)
        %STEPPOS Increment dest by +jog step and move to dest.  Units don't
        %come into play here because the dest and the step are in the same
        %unit
        %   see also STEPNEG
        
            
            msg = sprintf(...
                'stepPos from %1.*f %s by + %1.*f %s', ...
                this.getUnit().precision, ...
                this.getValCalDisplay(), ...
                this.getUnit().name, ...
                this.getUnit().precision, ...
                this.uieStep.get(), ...
                this.getUnit().name ...
            );
            this.msg(msg);
            
            % dDest = this.getValCalDisplay() + this.uieStep.get()
            dDestCal = this.uieDest.get() + this.uieStep.get();
           
            this.uieDest.set(dDestCal);
            this.moveToDest();
        end
        

        function stepNeg(this)
        %STEPPOS Increment dest by -jog step and move to dest.
        %   see also STEPPOS
        
            msg = sprintf(...
                'stepNeg from %1.*f %s by - %1.*f %s', ...
                this.getUnit().precision, ...
                this.getValCalDisplay(), ...
                this.getUnit().name, ...
                this.getUnit().precision, ...
                this.uieStep.get(), ...
                this.getUnit().name ...
            );
            this.msg(msg);
        
            % dDest = this.getValCalDisplay() + this.uieStep.get()
            dDestCal = this.uieDest.get() - this.uieStep.get();
           
            this.uieDest.set(dDestCal);
            this.moveToDest();           
        end
        
        function syncDestination(this)
        % SYNCDESTINATION Set the destination mic.ui.common.Edit value to
        % read what the actual calibrated value is.  This is useful when
        % manually setting the destnation value independent of the Edit UI
            dPosCal = str2double(sprintf(...
                        '%.*f', ...
                        this.getUnit().precision, ...
                        this.getValCalDisplay() ...
                    ));
            this.uieDest.set(dPosCal);
        end
       
        % Calls setDestCal() and moveToDest()
        function setDestCalAndGo(this, dCalAbs, cUnit)
            this.setDestCal(dCalAbs, cUnit);
            this.moveToDest();
        end
        
        function setDestCal(this, dCalAbs, cUnit)
        % SETDESTCALABS Update the destination inside the mic.ui.common.Edit based on
        % an absolute value in a particular unit.
        %   @param {double} dCal - desired destination in an abs calibrated
        %       unit (regardless of the UI's "abs/rel" state).
        %   @param {char} [cUnit = this.getUnit().name] - the name of the 
        %       unit you are passing in. If this is not set, it will be
        %       assumed that the unit is unit the UI is showing.
        %   EXAMPLE: If the UI was put into "rel" mode when the value was
        %       5 mm and you want the destination to be +1 mm (relative
        %       change), dCalAbs should be 6 and cUnit should be "mm".  
        %       See also SETDESTCAL, SETDESTRAW
        
            if nargin == 2
                cUnit = this.getUnit().name;
            end
            
            % Convert the absolute value in the passed unit to raw, then convert from raw to
            % the display unit and display abs/rel
            dRaw = this.cal2raw(dCalAbs, cUnit, false);
            
            % Set dest
            this.uieDest.set(this.raw2cal(dRaw, this.getUnit().name, this.uitRel.get()));
        
            
        end
        
        function setDestCalDisplay(this, dCal, cUnit)
        %SETDESTCAL Update the destination (cal) inside the dest mic.ui.common.Edit.
        %   @param {double} dCal - desired destination in a calibrated
        %       unit that can be either "abs" or "rel" (should match UI state)
        %       If the UI is in "abs" mode, it is assumed
        %       the value passed in is an "abs" value; if the UI is in "rel"
        %       mode, it is assumed the value passed in is a "rel" value
        %       (relative to a stored zero).  If you need to set the
        %       destination with an "abs" value even when the UI is displaying
        %       a "rel" value, use setDestCalAbs.  
        %   @param {char} [cUnit = this.getUnit().name] - the name of the 
        %       unit you are passing in. If this is not set, it will be
        %       assumed that the unit is unit the UI is showing.
        %   EXAMPLE: If the UI was put into "rel" mode when the value
        %       was 5 mm and you want the absolute destination to be 6 mm,
        %       dCal should be 1 and cUnit should be "mm".  Alternatively,
        %       you could use setDestCalAbs(6, "mm")
        %   See also SETDESTCALABS, SETDESTRAW

       
            if nargin == 2
                cUnit = this.getUnit().name;
            end
            
            % Convert from the passed unit to raw, then convert from raw to
            % the display unit
            
            dRaw = this.cal2raw(dCal, cUnit, this.uitRel.get());
            this.uieDest.set(this.raw2cal(dRaw, this.getUnit().name, this.uitRel.get()));
            
           
        end
        
        

        
        function setDestRaw(this, dRaw)
        %SETDESTRAW Update the destination inside the dest mic.ui.common.Edit from a
        %raw value.  The raw value is converted to the unit and abs/rel
        %settings of the UI
        
            this.uieDest.set(this.raw2cal(dRaw, this.getUnit().name, this.uitRel.get()));
        end
                
        
        function moveToDest(this)
        %MOVETODEST Performs the HIO motion to the destination shown in the
        %GUI display.  It converts from the display units to raw and tells
        %the Device 
        %   HardwareIO.moveToDest()
        %
        %   See also SETDESTCAL, SETDESTRAW, MOVE
        
            this.lReady = false;         
            dRaw = this.cal2raw(this.uieDest.get(), this.getUnit().name, this.uitRel.get());
            
            if ~this.fhValidateDest()
                return;
            end
            
            msg = sprintf( ...
                'moving from %1.*f %s to %1.*f %s', ...
                this.getUnit().precision, ...
                this.getValCalDisplay(), ...
                this.getUnit().name, ...
                this.getUnit().precision, ...
                this.uieDest.get(), ...
                this.getUnit().name ...
            );
        
            this.msg(msg);
               
            % Need to manually set this for the situation where the lReady
            % property is accessed before onClock() has a chance to
            % update its value from the device Device.
            
           
            if this.lUseFunctionCallbacks
                mic.Utils.ternEval(this.fhIsVirtual(), ...
                    @()this.fhSetV(dRaw), @()this.fhSet(dRaw));
            else
                this.getDevice().set(dRaw);
            end
                       
        end
        
        function stop(this)
        %STOPMOVE Aborts the current motion
        %   HardwareIO.stopMove()

            if this.lUseFunctionCallbacks
                 mic.Utils.ternEval(this.fhIsVirtual(), ...
                    @this.fhStopV, @this.fhStop);
            else
                this.getDevice().stop();
            end
            
        end

        
        function index(this)
        %INDEX Moves the HIO to the index position
        %   HardwareIO.index()
            if this.lUseFunctionCallbacks
                mic.Utils.ternEval(this.fhIsVirtual(), ...
                    @this.fhIndexV, @this.fhIndex);
            else
                this.getDevice().index();
            end
            
        end
        
        
        
        
        
        
        function delete(this)
        %DELETE Class Destructor
        %   HardwareIO.Delete()
        %
        % See also HARDWAREIO, INIT, BUILD

            % I think a good rule for delete should be that it only
            % deletes things that it adds
            
            this.msg('delete', this.u8_MSG_TYPE_CLASS_DELETE);
            this.lDeleted = true;
            this.save();
            
           % Clean up clock tasks
            if ~isempty(this.clock) && ...
                isvalid(this.clock) && ...
                this.clock.has(this.id())
                this.msg('delete() removing clock task', this.u8_MSG_TYPE_INFO); 
                this.clock.remove(this.id());
            end
                
            %{
            delete(this.uieDest);  
            delete(this.uieStep);
            delete(this.uitxVal);
            delete(this.uitDevice);
            delete(this.uibInit);
            delete(this.uiilInitState);

            delete(this.uibtPlay);
            delete(this.uitRel);     
            delete(this.uibZero);

            delete(this.uibStepPos);
            delete(this.uibStepNeg);
            delete(this.uitxName);
            delete(this.uipUnit);
                
            delete(this.uipStores) 
            delete(this.uitxLabelName);
            delete(this.uitxLabelVal);
            delete(this.uitxLabelUnit);
            delete(this.uitxLabelDest);
            delete(this.uitxLabelJog);
            delete(this.uitxLabelJogL);
            delete(this.uitxLabelJogR);
            delete(this.uitxLabelStores);
            delete(this.uitxLabelPlay);
            delete(this.uitxLabelDevice);
            delete(this.uitxLabelInit);
            delete(this.uitxLabelInitState);
            %}
            
            % delete(this.config)
            
            % The Devicev instances have clock tasks so need to delete them
            % first
            
            % delete(this.deviceVirtual);
            
            %{
            if ~isempty(this.device) && ... % isvalid(this.device) && ...
                isa(this.device, 'mic.device.GetSetNumber')
                delete(this.device)
            end
            %}
                        
        end
        
        
        
        
        function dOut = getValCalAbs(this, cUnit)
        %VALCAL Get the value in a calibrated unit ignoring the active
        %abs/rel state (rel state allows user-set offsets
        %
        %   @param {char} cUnit - the name of the unit you want the result
        %       calibrated in.  We intentionally don't support a default
        %       unit so the coder is forced to provide units everywhere in
        %       the code.  This keeps the code readabale. 
        %   @returns {double} - the calibrated value
        %
        %   If you want the value showed in the display (with the active
        %   display unit and abs/rel state use getValCalDisplay()

            lRel = false;
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    dOut = this.raw2cal(this.fhGetV(), cUnit, lRel);
                else
                    dOut = this.raw2cal(this.fhGet(), cUnit, lRel);
                end
            else
                dOut = this.raw2cal(this.getDevice().get(), cUnit, lRel);
            end
            
            
        end
        
        function dOut = getValCal(this, cUnit)
        %VALCAL Get the value in a calibrated unit using the active abs/rel
        %state
        %
        %   @param {char} cUnit - the name of the unit you want the result
        %       calibrated in.  We intentionally don't support a default
        %       unit so the coder is forced to provide units everywhere in
        %       the code.  This keeps the code readabale. 
        %   @returns {double} - the calibrated value
        %
        %   If you want the value showed in the display (with the active
        %   display unit and abs/rel state use getValCalDisplay()

            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    dOut = this.raw2cal(this.fhGetV(), cUnit, this.uitRel.get());
                else
                    dOut = this.raw2cal(this.fhGet(), cUnit, this.uitRel.get());
                end
            else
                dOut = this.raw2cal(this.getDevice().get(), cUnit, this.uitRel.get());
            end
            
            
        end
        
        function dOut = getValCalDisplay(this)
        %VALCALDISPLAY Get the value as shown in the UI with the active
        %display unit and abs/rel state
        %
        %   @returns {double} - the calibrated value
        %
        %   see also VALCAL 
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    dOut = this.raw2cal(this.fhGetV(), this.getUnit().name, this.uitRel.get());
                else
                    dOut = this.raw2cal(this.fhGet(), this.getUnit().name, this.uitRel.get());
                end
                
            else
                dOut = this.raw2cal(this.getDevice().get(), this.getUnit().name, this.uitRel.get());
            end

            
            
        end
        
        function dOut = getValRaw(this)
        %VALRAW Get the value (not the destination) in raw units. 
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    dOut = this.fhGetV(); 
                else
                    dOut = this.fhGet(); 
                end
                
            else
                dOut = this.getDevice().get(); 
            end
           
        end
        
        
        function dOut = getDestCal(this, cUnit)
        %DESTCAL Get the abs destination in a calibrated unit.  
        %
        %   @param {char} cUnit - the name of the unit you want the result
        %       calibrated in. We intentionally don't support a default
        %       unit so the coder is forced to provide units everywhere in
        %       the code.  This keeps the code readabale.
        %   @return {double} - the calibrated value
        %   see also DESTCALDISPLAY
            
            % Convert from the UI (unit, rel/abs) into raw, then convert from raw
            % into the specified absolute unit
            
            dRaw = this.cal2raw(this.uieDest.get(), this.getUnit().name, this.uitRel.get());
            dOut = this.raw2cal(dRaw, cUnit, false);
            
        end
        
        
        function dOut = getDestCalDisplay(this)
        %DESTCALDISPLAY Get the destinatino as shown in the UI with the active
        %display unit and abs/rel state 
        %   @return {double} - the calibrated value
        
            dOut = this.uieDest.get();
            
        end
        

        function dOut = getDestRaw(this)
        %DESTRAW Get the abs dest value in raw units. Raw value can never
        %changed with the UI configuration so this returns the same thing
        %regardless of UI configuration.
        
        %   HardwareIO.destRAW()  
        
            % CAL =  slope * (RAW - offset)
            % (CAL / slope) + offset = RAW
            dOut = this.cal2raw(this.uieDest.get(), this.getUnit().name, this.uitRel.get());
        
        end
        
        % @return {struct 1x1}
        function stOut = getUnit(this)
        %UNIT Retrive the active display unit definition structure 
        % (slope, offset, precision)
            stOut = this.config.unit(this.uipUnit.get());
            
        end
        
        function setUnit(this, cUnit)
        %SETUNIT set the active display unit by name
        %   @param {char} cUnit - the name of the unit, i.e., "mm", "m"
        
            for n = 1 : length(this.config.ceUnits)
                this.config.ceUnits{n}.name;
                if strcmp(cUnit, this.config.ceUnits{n}.name)
                    this.uipUnit.setSelectedIndex(uint8(n));
                end
            end            
        end
        
       
        
        function enable(this)
            
            this.uitDevice.enable();
            this.uibInit.enable();
            this.uiilInitState.disable();
            this.uibtPlay.enable();
            this.uitRel.enable();
            this.uibZero.enable();
            this.uibStepPos.enable();
            this.uibStepNeg.enable();
            this.uieDest.enable();
            this.uieStep.enable();
            this.uipUnit.enable();
            this.uitxVal.enable();
            this.uitxName.enable();
            this.uipStores.enable();

                            
            this.uitxLabelName.enable();
            this.uitxLabelVal.enable();
            this.uitxLabelUnit.enable();
            this.uitxLabelDest.enable();
            this.uitxLabelJog.enable();
            this.uitxLabelJogL.enable();
            this.uitxLabelJogR.enable();
            this.uitxLabelStores.enable();
            this.uitxLabelRange.enable();
            this.uitxLabelPlay.enable();
            this.uitxLabelDevice.enable();
            this.uitxLabelInit.enable();
            this.uitxLabelInitState.enable();
            
            
        end
        
        
        function disable(this)
            
            this.uitDevice.disable();
            this.uibInit.disable();
            this.uiilInitState.disable();
            this.uibtPlay.disable();
            this.uitRel.disable();
            this.uibZero.disable();
            this.uibStepPos.disable();
            this.uibStepNeg.disable();
            this.uieDest.disable();
            this.uieStep.disable();
            this.uipUnit.disable();
            this.uitxVal.disable();
            this.uitxName.disable();
            this.uipStores.disable();

            this.uitxLabelName.disable();
            this.uitxLabelVal.disable();
            this.uitxLabelUnit.disable();
            this.uitxLabelDest.disable();
            this.uitxLabelJog.disable();
            this.uitxLabelJogL.disable();
            this.uitxLabelJogR.disable();
            this.uitxLabelStores.disable();
            this.uitxLabelRange.disable();
            this.uitxLabelPlay.disable();
            this.uitxLabelDevice.disable();
            this.uitxLabelInit.disable();
            this.uitxLabelInitState.disable();
            
            
        end
        
        
        
        function st = save(this)
            st = struct();
            st.uitRel = this.uitRel.save();
            st.uipUnit = this.uipUnit.save();
            % st.uieDest = this.uieDest.save();
            st.dOffsetRel = this.dOffsetRel;
        end
                
        function load(this, st)
            
            this.msg('load()');
    
            %{
            if  this.lShowDest && ...
                ~isempty(this.uieDest)
                this.uieDest.load(st.uieDest)
            end
            %}

            if  this.lShowRel && ...
                ~isempty(this.uitRel)
                this.uitRel.load(st.uitRel)
                % this.onRelChange([],[]);
            end

            if  this.lShowUnit && ...
                ~isempty(this.uipUnit)
                this.uipUnit.load(st.uipUnit);
            end

            if isfield(st, 'dOffsetRel')
                this.dOffsetRel = st.dOffsetRel;
            end

        end
        
        
        
    end %methods
    
    methods (Access = protected)
            
        function onClock(this) 
        %onClock Callback triggered by the clock
        %   HardwareIO.onClock()
        %   updates the position reading and the hio status (=/~moving)
        
            
            if ~ishghandle(this.hPanel)
                this.msg('onClock() returning since not build', this.u8_MSG_TYPE_INFO);
                
                % Remove task
                if isvalid(this.clock) && ...
                   this.clock.has(this.id())
                    this.clock.remove(this.id());
                end
                
            end
        
            if this.lDeleted
                fprintf('onClock() %s returning (already deleted)', this.cName);
                return
            end
        
            
            try
                
                % 2016.11.02 CNA always cast as double.  Underlying unit
                % may not be double
                
                
                  
                if ~this.lDisableSet
                    
                    
                    if this.lUseFunctionCallbacks
                        if this.fhIsVirtual()
                            this.lReady = this.fhIsReadyV();
                        else
                            this.lReady = this.fhIsReady();
                        end
                    else
                        this.lReady = this.getDevice().isReady();
                    end
                    
                    
                    this.updatePlayButton()
                else
                    % The Device(V) doesn't implement isReady since this is a
                    % HardwareIO
                end
                
                this.updateDisplayValue();
               
                
                this.updateInitializedButton();
                
                                
               
            catch mE
                this.msg(mE.message, this.u8_MSG_TYPE_ERROR);
        %         %AW(5/24/13) : Added a timer stop when the axis instance has been
        %         %deleted
        %         if (strcmp(mE.identifier,'MATLAB:class:InvalidHandle'))
        %                 %msgbox({'Axis Timer has been stopped','','NON-CRITICAL ERROR','This textbox is here for debugging error'});
        %                 stop(this.t);
        %         else
        %             this.msg(mE.message);
        %         end
        
                % CA 2016 remove the task from the timer
                if isvalid(this.clock) && ...
                   this.clock.has(this.id())
                    this.clock.remove(this.id());
                end
                
                % error(mE);
                
            end %try/catch

        end 
        
        function init(this)           
        %INIT Initializes the class
        %   HardwareIO.init()
        %
        % See also HARDWAREIO, INIT, BUILD
        
        
           init@mic.ui.device.Base(this);                        

            % Load in the config file (Need to figure out how this will
            % work with classes that extend this class
            
            
            %GoTo button
            
            this.uibtPlay = mic.ui.common.ButtonToggle( ...
                'lImg', true, ...
                'u8ImgT', this.u8Play, ...
                'u8ImgF', this.u8Pause ...
            );
        
            this.uitRel = mic.ui.common.Toggle( ...
                'cTextFalse', 'ABS', ... % off (showing abs)
                'cTextTrue', 'REL', ... % on (showing rel)
                'lImg', false, ...
                'u8ImgOff',  this.u8Abs, ...
                'u8ImgOn', this.u8Rel ...
            );
        
             this.uibZero = mic.ui.common.Button( ...
                'cText', 'SET', ...
                'lImg', false, ...
                'u8Img', this.u8Zero ...
             );

            % imread(fullfile(mic.Utils.pathImg(), 'movingoff.png')), ...
            % imread(fullfile(mic.Utils.pathImg(), 'movingon.png')) ...           
            
            %Jog+ button
            this.uibStepPos = mic.ui.common.Button( ...
                'cText', '>', ...
                'lImg', true, ...
                'u8Img', this.u8Plus ...
            );

            %Jog- button
            this.uibStepNeg = mic.ui.common.Button( ...
                'cText', '<', ...
                'lImg', true, ...
                'u8Img', this.u8Minus ...
            );

            %Editbox to enter the destination
            this.uieDest = mic.ui.common.Edit(...
                'cLabel', sprintf('%s Dest', this.cName), ...
                'cType', 'd', ...
                'lShowLabel', false ...
            );
            
            % Edit box for calibrated jog amount
            this.uieStep = mic.ui.common.Edit(...
                'cLabel', sprintf('%s Step', this.cName),...
                'cType', 'd', ...
                'lShowLabel', false, ...
                'cHorizontalAlignment', 'center' ...
            );
            this.uieStep.set(this.config.dStep);
            
            % Build cell of unit names
            units = {};
            for n = 1:length(this.config.ceUnits)
                units{end + 1} = this.config.ceUnits{n}.name;
            end
            this.uipUnit = mic.ui.common.Popup(...
                'ceOptions', units, ...
                'lShowLabel', false ...
            );
            
            
            
            %position reading
            this.uitxVal = mic.ui.common.Text(...
                'cVal', 'Pos', ...
                'cAlign', 'right' ...
            );

            % Name (on the left)
            this.uitxName = mic.ui.common.Text(...
                'cVal', this.cLabel ...
            );
        
            vdVirtualDevice = this.newDeviceVirtual();
            this.setDeviceVirtual(vdVirtualDevice);
            
            % RM 2/2018 set function callbacks:
            this.fhGetV             = @()vdVirtualDevice.get();
            this.fhSetV             = @(dVal)vdVirtualDevice.set(dVal);
            this.fhIsReadyV         = @()vdVirtualDevice.isReady();
            this.fhStopV            = @()vdVirtualDevice.stop();
            this.fhIsInitializedV   = @()vdVirtualDevice.isInitialized();
            this.fhInitializeV      = @()vdVirtualDevice.initialize();
            this.fhIndexV           = @()[];

            
            % if ~isempty(this.config.ceStores)
                this.uipStores = mic.ui.common.PopupStruct(...
                    'ceOptions', this.config.ceStores, ...
                    'lShowLabel', false, ...
                    'cField', 'name' ...
                );
                
                addlistener(this.uipStores,   'eChange', @this.onStoresChange);
                this.uipStores.setTooltip('Go to a stored position');

                
            % end
                        
            %AW(5/24/13) : populating the destination
            this.uieDest.set(this.deviceVirtual.get());


            this.uitxLabelName = mic.ui.common.Text(...
                'cVal', this.cLabelName ...
            );
            this.uitxLabelVal = mic.ui.common.Text(...
                'cVal', this.cLabelValue, ...
                'cAlign', 'Right'...
            );
            this.uitxLabelUnit = mic.ui.common.Text( ...
                'cVal', this.cLabelUnit ...
            );
            this.uitxLabelDest = mic.ui.common.Text(...
                'cVal', this.cLabelDest ...
            );
            this.uitxLabelPlay = mic.ui.common.Text( ...
                'cVal', this.cLabelPlay ...
            );
            
        
            this.uitxLabelJogL = mic.ui.common.Text(...
                'cVal', this.cLabelJogL, ...
                'cAlign', 'center' ...
            );
            this.uitxLabelJog = mic.ui.common.Text(...
                'cVal', this.cLabelJog, ...
                'cAlign', 'center' ...
            );
            this.uitxLabelJogR = mic.ui.common.Text(...
                'cVal', this.cLabelJogR, ...
                'cAlign', 'center' ...
            );
            this.uitxLabelStores = mic.ui.common.Text(...
                'cVal', this.cLabelStores ...
            );
            this.uitxLabelRange = mic.ui.common.Text(...
                'cVal', this.cLabelRange ...
            );
            this.uitxRange = mic.ui.common.Text('cVal', '[... - ...]');
           
        
         % event listeners

            
            % addlistener(this.uitPlay,   'eChange', @this.handleUI);
            
            % this.uitDevice.disable(); % enable after setDevice() is called
            
            addlistener(this.uieDest, 'eEnter', @this.onDestEnter);
            addlistener(this.uibtPlay,   'eChange', @this.onPlayChange);
            addlistener(this.uitRel,   'eChange', @this.onRelChange);
            addlistener(this.uipUnit,   'eChange', @this.onUnitChange);

            addlistener(this.uieDest, 'eChange', @this.onDestChange);
            addlistener(this.uieStep, 'eChange', @this.onStepChange);
            addlistener(this.uibStepPos, 'eChange', @this.onStepPosPress);
            addlistener(this.uibStepNeg, 'eChange', @this.onStepNegPress);
            addlistener(this.uibZero, 'eChange', @this.onSetZeroPress);
            
            
            this.uitDevice.setTooltip(this.cTooltipDeviceOff);
            this.uitxName.setTooltip('The name of this device');
            this.uitxVal.setTooltip('The value of this device');
            this.uieStep.setTooltip('Change the goal increment value.  Use < > to step goal.');
            this.uieDest.setTooltip('Change the goal value');
            this.uibtPlay.setTooltip('Go to goal');
            this.uipUnit.setTooltip('Change the display units');
            this.updateRelTooltip();
            this.updateZeroTooltip();
            this.updateStepTooltips();
            this.uipUnit.setSelectedIndex(this.u8UnitIndex);
            
            
            % this.updateRange();
            % this.load();
            
            
            
            
        end
        
        
        
        
        function onStoresChange(this, src, evt)
            this.setDestRaw(src.get().raw);
            this.moveToDest();
        end
        
        function onDestChange(this, src, evt)
            % notify(this, 'eChange');
        end
        
        function onDestEnter(this, src, evt)
            if (this.lDisableMoveToDestOnDestEnter)
                return
            end
            this.msg('onDestEnter');
            this.moveToDest();
        end
        
        function onStepChange(this, src, evt)
            this.updateStepTooltips();
        end
        
        function onStepPosPress(this, src, evt)
            this.stepPos();
        end
        
        function onStepNegPress(this, src, evt)
            this.stepNeg();
        end
        
        
        
        
        
        function onPlayChange(this, src, evt)
            % Ready means it isn't moving
            
            this.msg('onPlayChange()');
            if this.lReady
                this.msg('handleUI lReady = true. moveToDest()');
                this.moveToDest();
            else
                this.msg('handleUI lReady = false. stop()');
                this.stop();
            end
        end
        
        
        
        % Deprecated (un-deprecitate if you want to move to dest on enter
        % keypress
        
        function onDest(this, src, evt)
            if uint8(get(this.hParent,'CurrentCharacter')) == 13
                this.moveToDest();
            end
        end
        
        function onUnitChange(this, src, evt)
        % onUnitChange Convert the destination value to the new display unit 
        %   and update storage of u8UnitIndex to the new pulldown index
        
            
           % We have access to the previous display unit via
           % this.u8UnitIndex. Convert the destination value from old unit
           % to raw and then from raw into new unit
          
           
           ceOptions = this.uipUnit.getOptions();
           msg = sprintf(...
               'Changed display units from %s to %s', ...
               ceOptions{this.u8UnitIndex}, ...
               this.uipUnit.get() ...
           );
            this.msg(msg);
            
           cUnitPrev = this.config.ceUnits{this.u8UnitIndex}.name;
           dRaw = this.cal2raw(this.uieDest.get(), cUnitPrev, this.uitRel.get());
            
            this.uieDest.set(this.raw2cal(dRaw, this.getUnit().name, this.uitRel.get()));
            
            % Update u8UnitIndex
            this.u8UnitIndex = this.uipUnit.getSelectedIndex();
            
            this.updateZeroTooltip();
            this.updateStepTooltips();
            
            this.updateRange();
            
            notify(this, 'eUnitChange');
                    
        end

        
        function updateRange(this)
           
            if ~this.lShowRange
                return
            end
            
            stUnit = this.getUnit() ;
             
            if stUnit.invert
                
                % Need to check if the cal value (including offset
                % abs/rel) of rawMin/ rawMax surround zero.  If they do,
                % there will be two ranges. One from [-inf to 1/dMin] and
                % one from [1/dMax to +inf].  This is due to the inversion
                % and zero mapping to infinity.
                
                dCalMin = this.raw2cal(this.config.dMin, stUnit.name, this.uitRel.get());
                dCalMax = this.raw2cal(this.config.dMax, stUnit.name, this.uitRel.get()); 
                
                if dCalMin < 0 && dCalMax > 0
                    
                    
                    cVal = sprintf(...
                        '[-inf, %.*f] [%.*f, inf]', ...
                        stUnit.precision, ...
                        dCalMin, ...
                        stUnit.precision, ...
                        dCalMax ...
                    );
                else
                    
                    % Since we are inverting, the min value will be the cal
                    % val of dMax and the max value will be the cal value
                    % of dMin
                    
                    dCalMin = this.raw2cal(this.config.dMax, stUnit.name, this.uitRel.get());
                    dCalMax = this.raw2cal(this.config.dMin, stUnit.name, this.uitRel.get());

                    cVal = sprintf(...
                        '[%.*f, %.*f]', ...
                        stUnit.precision, ...
                        dCalMin, ...
                        stUnit.precision, ...
                        dCalMax ...
                    );

                    
                end
                
            else
                
                dCalMin = this.raw2cal(this.config.dMin, stUnit.name, this.uitRel.get());
                dCalMax = this.raw2cal(this.config.dMax, stUnit.name, this.uitRel.get());

                cVal = sprintf(...
                    '[%.*f, %.*f]', ...
                    stUnit.precision, ...
                    dCalMin, ...
                    stUnit.precision, ...
                    dCalMax ...
                );
                
            end
            
            this.uitxRange.set(cVal);
            
        end
        
        function updateDisplayValue(this)
            
            
            % Precision can be a number, or an asterisk (*) to refer to an
            % argument in the input list. For example, the input list
            % ('%6.4f', pi) is equivalent to ('%*.*f', 6, 4, pi).
                
           switch this.cConversion
                case 'f'
                    
                    cVal = sprintf(...
                        '%.*f', ...
                        this.getUnit().precision, ...
                        this.getValCalDisplay() ...
                    );
                case 'e'
                    cVal = sprintf(...
                        '%.*e', ...
                        this.getUnit().precision, ...
                        this.getValCalDisplay() ...
                    );
           end 
            
           %{
           fprintf('%s conversion: %s cVal: %s precision %1.0f val %1.4f\n', ...
               this.cName, ...
               this.cConversion, ...
               cVal, ...
               this.getUnit().precision, ...
               this.getValCalDisplay() ...
           );
           %}
           
           
           
           if ~strcmp(this.cValPrev, cVal)
               notify(this, 'eChange');
           end
           
           this.uitxVal.set(cVal);
           
           % Update text color for IO (not O) when value is changing
           if ~this.lDisableSet
               
               if this.lReady
                   
                   % Check to see if value is within 1% of destination, if not color
                   % as warning
                   
                   if abs(this.getValCalDisplay() - this.getDestCalDisplay()) < abs(this.getDestCalDisplay() / 50 )                      
                       this.uitxVal.setColor(this.dColorTextStopped);
                   else
                       this.uitxVal.setColor(this.dColorTextWarning);
                   end
               else
                   this.uitxVal.setColor(this.dColorTextMoving);
               end
           end
           
           this.cValPrev = cVal;
            
        end
        
        
        function updateInitializedButton(this)
            if this.lUseFunctionCallbacks
                if this.fhIsVirtual()
                    lInitialized = this.fhIsInitializedV();
                else
                    lInitialized = this.fhIsInitialized();
                end
                
            else
                lInitialized = this.getDevice().isInitialized();
            end

            
                
            if this.lShowInitButton
                if lInitialized
                    this.uibInit.setU8Img(this.u8InitTrue);
                else
                    this.uibInit.setU8Img(this.u8InitFalse);
                end
            end

            %{
            if this.lShowInitState
                this.uiilInitState.set(lInitialized);
            end
            %}

            if this.lIsInitializing && ...
               lInitialized
                this.lIsInitializing = false;
            end
            
        end
        
        
        function updatePlayButton(this)
            
            % UIButtonTobble
            try
                if ~islogical(this.lReady)
                    fprintf('GetSetNumber.updatePlayButton() lReady is not logical\n');
                    return
                end

                if ~islogical(this.uibtPlay.get())
                    fprintf('GetSetNumber.updatePlayButton() uibtPlay.get() is not logical\n');
                    return;
                end

                if this.lReady && ~this.uibtPlay.get()
                    this.uibtPlay.set(true);
                end

                if ~this.lReady && this.uibtPlay.get()
                    this.uibtPlay.set(false);
                end
            
            catch mE
                fprintf('GetSetNumber.updatePlayButton() caught: %s\n', mE.message);
            end

        end
        
        function dOut = cal2raw(this, dCal, cUnit, lRel)
        %CAL2RAW Convert from a calibrated unit to raw.
        %   @param {double} dCal - the calibrated value
        %   @param {char} cUnit - the unit of the calibrated value
        %   @param {logical} lRel - true if the calibrated value is
        %       relative to the stored zero, false otherwise
        %   @return {double} - the raw value
        %
        % See also RAW2CAL
        
            stUnit = this.config.unit(cUnit);
            
            
            % INVERT == false
            % cal = slope * (raw - offset)
            % (cal / slope) + offset = raw
            
            
            % INVERT == true
            % cal = slope * (raw - offset)^-1
            % slope / cal = raw - offset
            % raw = slope / cal + offset
            
            
            
            if (lRel)
                % Offset is replaced by the stored dOffsetRel in rel mode
                
                if stUnit.invert
                    dOut = stUnit.slope / dCal + this.dOffsetRel;
                else
                    dOut = dCal/stUnit.slope + this.dOffsetRel;
                end
            else
                if stUnit.invert
                    dOut = stUnit.slope / dCal + stUnit.offset;
                else
                    dOut = dCal/stUnit.slope + stUnit.offset;
                end
            end

        end

        function dOut = raw2cal(this, dRaw, cUnit, lRel)
        %RAW2CAL Convert from raw to a calibrated unit
        %   @param {double} dRaw - the raw value
        %   @param {char} cUnit - the name of the unit you want to convert to
        %   @param {logical} lRel - true if you want calibrated value
        %       relative to the stored zero, false otherwise
        %   @return {double} the calibrated value
        %
        % See also CAL2RAW
        
            stUnit = this.config.unit(cUnit);

            % cal = slope * (raw - offset)
            
            if (lRel)
                % Offset is replaced by the stored dOffsetRel in rel mode
                if (stUnit.invert)
                    dOut = stUnit.slope * (dRaw - this.dOffsetRel)^-1;
                else
                    dOut = stUnit.slope * (dRaw - this.dOffsetRel);
                end
            else
                if stUnit.invert
                    dOut = stUnit.slope * (dRaw - stUnit.offset)^-1;
                else
                    dOut = stUnit.slope * (dRaw - stUnit.offset);
                end
            end
            
            

        end
                
        
        
        
       
        
        % Allow the user to set the current raw position to any desired calibrated value
        function onSetPress(this, src, evt)
                       
            cePrompt = {'Original Calibrated Value:', 'New Calibrated Value:'};
            cTitle = 'Set a New Software Offset';
            dLines = 1;
            ceDefaultAns = {num2str(this.getValCalDisplay()), num2str(this.getValCalDisplay())};
            stOptions = struct(...
                'Resize', 'on' ...
            );
            ceAnswer = inputdlg(...
                cePrompt,...
                cTitle,...
                dLines,...
                ceDefaultAns, ...
                stOptions ...
            );
            
            if isempty(ceAnswer)
                return
            end
              
            % Two equations, one unknown.
            %
            % The motor is at raw position "RAW"
            % cal0 = curent calibrated value at RAW 
            % cal1 = future calibrated value at RAW 
            % slope0 = slope before change (from config) (unaffected by
            % this change)
            % offset0 = offset before change (from config)
            % offset1 = offset after change
            %
            % EQ1: cal0 = slope0 * (RAW - offset0)
            % EQ2: cal1 = slope0 * (RAW - offset1)
            % Subtract EQ1 from EQ2:
            % cal1 - cal0 = slope0 * (-offset1 + offset0)
            % Solve for offset1 (offsets are alway in RAW units)
            % offset1 = offset0 - (cal1 - cal0)/slope0 
            
            % 2017.03.15 This works the same way if invert is true,
            % fortunately.  I didn't write out the math but I think two
            % things cancel 1: there are different equations since in
            % invert mode the equation is cal = slope * (raw - offset)^-1
            % additionally, you have to consider that the value the person
            % types in is in inverse units.
           
            %{
            dOffsetNew = this.getUnit().offset - (str2double(ceAnswer{1}) - this.getValCalDisplay())/this.getUnit().slope;
            this.dOffsetRel = dOffsetNew;
            
            this.updateZeroTooltip();
            % Force to "Rel" mode
            this.uitRel.set(true);
            %}
            
            this.setValToNewVal(str2double(ceAnswer{1}), str2double(ceAnswer{2}));
            
            
        end
        
        function onSetZeroPress(this, src, evt)
           
            this.onSetPress(src, evt);
            return;
            
            this.dOffsetRel = this.getValRaw(); % raw units            
            this.updateZeroTooltip();
            
            % Force to "Rel" mode
            this.uitRel.set(true);
            
        end
        
        function onRelChange(this, src, evt)
           
            this.msg('onRelChange');
            % Set the destination to the hardware value in the new
            % calibrated unit
            
            this.lRelVal = this.uitRel.get();
            this.uieDest.set(this.getValCalDisplay());
            this.updateRelTooltip();
            this.updateRange();
            
        end
        
        function lOut = validateDest(this)
            lOut = true;
        end
        
        function lOut = validateByConfigRange(this)
            % By default this will check to see if goal is in between the
            % specified range.
            stUnit = this.getUnit();
            dCalMin = this.raw2cal(this.config.dMin, stUnit.name, this.uitRel.get());
            dCalMax = this.raw2cal(this.config.dMax, stUnit.name, this.uitRel.get()); 
            
            % depending on units we need to make sure that the "min" is
            % really the lower value.  If not then swap:
            if (dCalMax < dCalMin)
                dTemp = dCalMin;
                dCalMin = dCalMax;
                dCalMax = dTemp;
            end
            dDest = this.uieDest.get();
            
            lOut = (dDest >= dCalMin && dDest <= dCalMax);
            
            if ~lOut
                cMsg = [...
                    sprintf('Requested value is outside of the allowed range. Restoring previous value. Move aborted.\n\n'), ...
                    sprintf('min allowed value = %1.3e %s\n', dCalMin, stUnit.name), ...
                    sprintf('max allowed value = %1.3e %s\n', dCalMax, stUnit.name) ...
                ];
                    
                msgbox(...
                    cMsg, ...
                    'Value Not Allowed. Move Aborted.', ...
                    'error', ...
                    'modal' ...
                );
                this.syncDestination();
            end
                

        end
        
        function updateZeroTooltip(this)
            cMsg = sprintf(...
                'Set a new software offset. The offset is currently %1.*f %s', ...
                this.getUnit().precision, ...
                this.raw2cal(this.dOffsetRel, this.getUnit().name, false), ...
                this.getUnit().name ...
            );            
            this.uibZero.setTooltip(cMsg);
        end
        
        
        function updateStepTooltips(this)
            cMsgNeg = sprintf(...
                'Decrease goal by %1.*f %s.', ...
                this.getUnit().precision, ...
                this.uieStep.get(), ...
                this.getUnit().name ...
            ); 
        
            cMsgPos = sprintf(...
                'Increase goal by %1.*f %s.', ...
                this.getUnit().precision, ...
                this.uieStep.get(), ...
                this.getUnit().name ...
            ); 
            this.uibStepPos.setTooltip(cMsgPos);
            this.uibStepNeg.setTooltip(cMsgNeg);
        end
        
        function updateRelTooltip(this)
            
            switch this.uitRel.get()
                case false
                    cMsg = 'Make value relative to the stored zero. Value is currently absolute.';
                case true
                    cMsg = 'Make value absolute.  Value is currently relative to the stored zero.';
            end
            
            this.uitRel.setTooltip(cMsg);
            
        end
        
        
        function dOut = getWidth(this)
            dOut = 0;
                    
            if this.lShowDevice
               dOut = dOut + this.dWidthPadDevice + this.dWidthBtn;
            end
            
            if this.lShowInitButton
               dOut = dOut + this.dWidthPadInitButton + this.dWidthBtn;
            end
            
            if this.lShowInitState
               dOut = dOut + this.dWidthPadInitState + this.dWidthBtn;
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
            
            %{
            if this.lShowJog
                dOut = dOut + this.dWidthPadJog + 2 * this.dWidthBtn + this.dWidthStep;
            end
            %}
            
            if this.lShowStepNeg
                dOut = dOut + this.dWidthPadStepNeg + this.dWidthBtn;
            end
            
            if this.lShowStep
                dOut = dOut + this.dWidthPadStep + this.dWidthStep;
            end
            
            if this.lShowStepPos
                dOut = dOut + this.dWidthPadStepPos + this.dWidthBtn;
            end
            
            if this.lShowUnit
                dOut = dOut + this.dWidthPadUnit + this.dWidthUnit;
            end
            if this.lShowStores % && ~isempty(this.config.ceStores)
                dOut = dOut + this.dWidthPadStores + this.dWidthStores;
            end
            if this.lShowRel
                dOut = dOut + this.dWidthPadRel +  this.dWidthBtn;
            end
            if this.lShowZero
                dOut = dOut + this.dWidthPadZero + this.dWidthBtn;
            end
            
            if this.lShowRange
                dOut = dOut + this.dWidthPadRange + this.dWidthRange;
            end
            
            dOut = dOut + 5;
            % dOut = dOut + this.dWidthUnit;
            
        end
        
        
        function device = newDeviceVirtual(this)
        
            if this.lDisableSet
                device = mic.device.GetNumber(...
                    'cName', this.cName, ...
                    'clock', this.clock, ...
                    'dVal', this.dValDeviceDefault ...
                );
            else
                device = mic.device.GetSetNumber(...
                    'cName', this.cName, ...
                    'clock', this.clock, ...
                    'dVal', this.dValDeviceDefault ...
                );
            end
        end
        
        
        

    end

end %class
