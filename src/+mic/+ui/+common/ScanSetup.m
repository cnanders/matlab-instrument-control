%{
ScanSetup is a ui element used to set up scan states for use in the
mic.scan class.  ScanSetup is implemented by instantiating ScanAxisSetups
which control parameters for the individual axes.

Instantiate with at least parameter dScanAxes,  ceOutputOptions, and
ceScanAxisLabels, which control the dimensionality of the scan, the labels
for the output options, and the labels for the input axis options
respectively

Pass parameter 
    fhOnScanChangeParams = @(ceScanStates, u8ScanAxisIdx, lUseDeltas)
To initialize a callback that will be called any time a scan parameter is
changed, passing a cell array of scanstates, the axis numbers of the active
scans as defined in the uipopup, and the useDeltas boolean array to
determine whether scans will be about the current axis value

%}

classdef ScanSetup < mic.Base
    
    
    properties (Constant)
        
    end
    
    
    properties (SetAccess = private)
        
        % Name of scan
        cName
        
        
    end
    
    
    properties (Access = protected)
        
        % {1xn ScanAxis}
        saScanAxisSetups
        
        % Callback
        fhOnScan
        fhOnStopScan
        
        fhOnScanChangeParams = @(ceScanStates, u8ScanAxisIdx, lUseDeltas)[]
        
        
        % UI
        hParent
        hPanel
        uibStartScan
        uibStopScan
        
        uipOutput
        uicbRaster
        dLeft
        dTop
        dWidth
        dHeight
        
        % Output options
        ceOutputOptions = {'Output 1', 'Output 2', 'Output 3'}
       
        % Scan axis labels:
        ceScanAxisLabels = {'Axis 1', 'Axis 2', 'Axis 3'}
        
        % Number of scan axes
        dScanAxes = 1
        
        % Default values for scan axes
        u8selectedDefaults = uint8([1 2 3]);
        
        % Save load list for scan parameters
        uiSLScanSetup
        
        % Path to configuration directory where recipes are stored
        cConfigPath
        
        
        dColorBg = [.94 .94 .94]; % MATLAB default
    end
    
    
    
    methods
        
        % constructor
        
        
        function this = ScanSetup(varargin)
            
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init()
            
        end
        
        function init(this)
            
            for k = 1:this.dScanAxes
                this.saScanAxisSetups{k} = mic.ui.common.ScanAxisSetup('cScanLabel', sprintf('Scan axis %d', k), ...
                                                                        'ceScanOptions', this.ceScanAxisLabels, ...
                                                                        'fhDirectCallback', @(~, ~)this.paramChangeCallback);
                
                % Set default values for popup:
                this.saScanAxisSetups{k}.uipSelectInput.setSelectedIndex(this.u8selectedDefaults(k));
            end
            
            this.uipOutput  = mic.ui.common.Popup(...
                    'cLabel', 'Output', ...
                    'ceOptions', this.ceOutputOptions, ...
                    'lShowLabel', true ...
                );
            
            this.uibStartScan = mic.ui.common.Button(...
                    'cText', 'Scan', ...
                    'fhDirectCallback', @this.routeScanInfoToCallback);
                
            this.uibStopScan = mic.ui.common.Button(...
                    'cText', 'Stop', ...
                    'fhDirectCallback', @(~,~)this.onStopScan);
                
            this.uiSLScanSetup = mic.ui.common.PositionRecaller(...
                'cConfigPath', this.cConfigPath, ...
                'cName', this.cName, ...
                'hGetCallback', @this.getScanParams, ...
                'hSetCallback', @this.setScanParams);
            
            
            this.uicbRaster = mic.ui.common.Checkbox(...
                    'cLabel', 'Raster', ...
                    'dColor', this.dColorBg,...
                    'fhDirectCallback', @(~, ~)this.paramChangeCallback...
                    );
                
        end
        
        % Externally trigger a scan setup param change callback
        function triggerCallback(this)
            this.paramChangeCallback();
        end
        

        
        function paramChangeCallback(this)
            % For testing just echo somethign:
            disp('param change callback');
            
            % Get current scan parameters and route to param change
            % callback:
            [ceScanStates, u8ScanAxisIdx, lUseDeltas, ceScanRanges] = this.buildScanStateArray();
            cAxisNames = this.ceScanAxisLabels(u8ScanAxisIdx);
            this.fhOnScanChangeParams(ceScanStates, u8ScanAxisIdx, lUseDeltas, cAxisNames, ceScanRanges);
        end
        
        % Called when the stop button is pressed
        function onStopScan(this)
            this.fhOnStopScan();
        end
        
        function [ceScanStates, u8ScanAxisIdx, lUseDeltas, ceScanRanges] = buildScanStateArray(this)
            
            % Save the scan idx of each axis and whether to use deltas
            u8ScanAxisIdx = [];
            lUseDeltas = [];
            for k = 1:this.dScanAxes
                u8ScanAxisIdx(k) = this.saScanAxisSetups{k}.getScanAxisIndex();
                lUseDeltas(k) = this.saScanAxisSetups{k}.useDelta();
            end
            
            % Create a cell array of the scan ranges for each
            % scanAxisSetup:
            ceScanRanges = cell(1,this.dScanAxes);
            
            for k = 1:this.dScanAxes
                ceScanRanges{k} = this.saScanAxisSetups{k}.getScanRanges();
            end
            
            % Now need to build a list of states corresponding to the scan
            % ranges:
            dNumScanStates = 1;
            for k = 1:this.dScanAxes
                dNumScanStates = dNumScanStates * length(ceScanRanges{k});
            end
            ceScanStates = cell(0);
            
            % We could try to do a clever nesting, but let's just brute
            % force, assuming we only support 3 nested scans
            isodd = @(x) mod(x, 2) == 1;
            iseven = @(x) mod(x, 2) == 0;
            switch this.dScanAxes
                case 1
                    for k = 1:length(ceScanRanges{1})
                        ceScanStates{end + 1} =  struct('axes', u8ScanAxisIdx, 'values', ceScanRanges{1}(k)); %#ok<*AGROW>
                    end
                case 2
                    for k = 1:length(ceScanRanges{1})
                        for m = 1:length(ceScanRanges{2})
                            if ~this.uicbRaster.get() || isodd(k)
                                kidx = k;
                                midx = m;
                                
                            else % raster direction
                                kidx = k;
                                midx = length(ceScanRanges{2}) - m + 1;
                            end
                            ceScanStates{end + 1} = struct('indices', [kidx, midx], 'axes', u8ScanAxisIdx, 'values',...
                                    [ceScanRanges{1}(kidx), ceScanRanges{2}(midx)]);
                        end
                    end
                case 3 % raster only dimensions 2 and 3
                    for p = 1:length(ceScanRanges{1})
                        for k = 1:length(ceScanRanges{2})
                            for m = 1:length(ceScanRanges{3})
                                if ~this.uicbRaster.get() || isodd(k)
                                    kidx = k;
                                    midx = m;
                                    
                                else % raster direction
                                    kidx = k;
                                    midx = length(ceScanRanges{2}) - m + 1;
                                end
                                ceScanStates{end + 1} = struct('indices', [p, kidx, midx], 'axes', u8ScanAxisIdx, 'values',...
                                        [ceScanRanges{1}(p), ceScanRanges{2}(kidx), ceScanRanges{3}(midx)]);
                                
                            end
                        end
                    end
            end % Switch
            
        end
            
        
        % Builds scan states and passes them to the fhOnScan callback
        function routeScanInfoToCallback(this, ~, ~)
            
            [ceScanStates, u8ScanAxisIdx, lUseDeltas]  = this.buildScanStateArray();
            % Pass out scan axes and output for validation
            u8OutputIdx = this.uipOutput.getSelectedIndex();
            
            cAxisNames = this.ceScanAxisLabels(u8ScanAxisIdx);
            if ~isempty(ceScanStates)
                this.fhOnScan(ceScanStates, u8ScanAxisIdx, lUseDeltas, u8OutputIdx, cAxisNames);
            else
                msgbox('No states to scan, check scan parameters');
            end
            
            % scan "states" are structures with properties: axes, values
            % where axes is an array of the indices of axes as defined in
            % the scanAxisSetup uipopup, and values are the corresponding
            % values
        end
        
        % Gets scan ranges for each scan axis
        function ceScanRanges = getScanRanges(this)
            for k = 1:this.dScanAxes
                ceScanRanges{k} = this.saScanAxisSetups{k}.getScanRanges(); 
            end
        end
        
        
        % gets edit box and uipopup parameters for use in position recaller
        function ceParams = getScanParams(this)
            ceParams = {};
            for k = 1:this.dScanAxes
                % make a 5-element array for each scan axis: popupIdx,
                % start, step, end, nsteps:
                
                ceParams{k} = {this.saScanAxisSetups{k}.uipSelectInput.getSelectedValue(), ...
                               this.saScanAxisSetups{k}.uieStart.get(), ... 
                               this.saScanAxisSetups{k}.uieStep.get(), ...
                               this.saScanAxisSetups{k}.uieEnd.get(), ...
                               this.saScanAxisSetups{k}.uieNSteps.get(),...
                               this.saScanAxisSetups{k}.uicbCenterOnValue.get()}; 
                 
            end
            
            ceParams{k+1} = this.uipOutput.getSelectedValue();
            ceParams{k+2} = this.uicbRaster.get();
        end
        
        % Sets edit box and uipopup parameters from position recaller
        function setScanParams(this, ceParams)
            for k = 1:this.dScanAxes
                % make a 5-element array for each scan axis: popupIdx,
                % start, step, end, nsteps:
                
                this.saScanAxisSetups{k}.uipSelectInput.setSelectedValue(ceParams{k}{1});
                this.saScanAxisSetups{k}.uieStart.set(ceParams{k}{2});
                this.saScanAxisSetups{k}.uieStep.set(ceParams{k}{3});
                this.saScanAxisSetups{k}.uieEnd.set(ceParams{k}{4});
                this.saScanAxisSetups{k}.uieNSteps.set(ceParams{k}{5});
                this.saScanAxisSetups{k}.uicbCenterOnValue.set(logical(ceParams{k}{6}));
                 
            end
            
            this.uipOutput.setSelectedValue(ceParams{k+1});
            this.uicbRaster.set(logical(ceParams{k+2}));
            
            % After loading parameters, call calback:
            this.paramChangeCallback();
        end
        
        function ceNames = getScanAxisNames(this)
            ceNames = this.ceScanAxisLabels(this.u8selectedDefaults);
        end
        
        function cOutput = getOutputName(this)
            cOutput = this.uipOutput.getSelectedValue;
        end
        
        % Builds the UI elements
        function build(this,  hParent,  dLeft,  dTop,  dWidth,  dHeight)
            
            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BorderWidth',0, ... 
                'Position', ([dLeft dTop dWidth dHeight]));
            drawnow
            
            % First build scan axes:
            
            dLeft = 10;
            dPad = 6;
            dY = 45;
            dTop = 2;
            
            for k = 1:this.dScanAxes
                this.saScanAxisSetups{k}.build(this.hPanel, dLeft, ...
                    dTop);
                dTop = dTop + dPad + dY;
            end
            
             dTop = dTop + 3*dPad;
             
            % Build only if there is more than one axis
            if (this.dScanAxes > 1)
                this.uicbRaster.build(this.hPanel, 250, dTop + 2, 70, 25);
                this.uibStartScan.build(this.hPanel, 140, dTop, 45, 30);
                this.uibStopScan.build(this.hPanel, 195, dTop, 45, 30);
                
                this.uipOutput.build(this.hPanel, 10, dTop - 10, 120, 40);
            else
                this.uibStartScan.build(this.hPanel, 140, dTop, 45, 30);
                this.uipOutput.build(this.hPanel, 10, dTop - 10, 120, 40);
                this.uibStopScan.build(this.hPanel, 195, dTop, 45, 30);
            end
            
            this.uiSLScanSetup.build(this.hPanel, 487, 10, 340, dHeight - 20);
            
            this.uibStartScan.setColor([.7, .9, .7]);
            this.uibStopScan.setColor([.9, .7, .7]);
            
        end
        
       
        
        
        
        
    end
    
    methods (Access = protected)
        
        
        
        
        
        
    end
end