classdef ScanSetup < mic.Base
    
    
    properties (Constant)
        
    end
    
    
    properties (SetAccess = private)
        
        
    end
    
    
    properties (Access = protected)
        
        % {1xn ScanAxis}
        saScanAxisSetups
        
        % Callback
        fhOnScanButtonPress
        
        % UI
        hParent
        hPanel
        uibStartScan
        uipOutput
        uicbRaster
        dLeft
        dTop
        dWidth
        dHeight
        
        % Output options
        ceOutputOptions = {'Image capture', 'Image intensity', 'Line Contrast', 'Line Pitch'}
       
        % Number of scan axes
        dScanAxes = 1
        
        % Default values for scan axes
        u8selectedDefaults = uint8([1 2 3]);
        
        % Save load list for scan parameters
        uiSLScanSetup
        
        % Path to configuration directory where recipes are stored
        cConfigPath
        
        % Name of scan
        cName
        
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
                this.saScanAxisSetups{k} = mic.ui.common.ScanAxisSetup('cScanLabel', sprintf('Scan axis %d', k));
                
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
            
            this.uiSLScanSetup = mic.ui.common.PositionRecaller(...
                'cConfigPath', this.cConfigPath, ...
                'cName', this.cName, ...
                'hGetCallback', @this.getScanParams, ...
                'hSetCallback', @this.setScanParams);
            
            
            this.uicbRaster = mic.ui.common.Checkbox(...
                    'cLabel', 'Raster', ...
                    'dColor', this.dColorBg...
                    );
        end
        
        
        function routeScanInfoToCallback(this)
            % Get index of scan axes:
            u8ScanAxisIdx = [];
            
            for k = 1:this.dScanAxes
                u8ScanAxisIdx(k) = this.saScanAxisSetups.getScanAxisIndex();
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
            switch this.dScanAxes
                case 1
                    for k = 1:length(ceScanRanges{1})
                        ceScanStates{end + 1} =  struct('axes', u8ScanAxisIdx, 'values', ceScanRanges{1}(k)); %#ok<*AGROW>
                    end
                case 2
                    for k = 1:length(ceScanRanges{1})
                        for m = 1:length(ceScanRanges{2})
                            if this.uicbRaster.get() && isodd(m)
                                ceScanStates{end + 1} = struct('axes', u8ScanAxisIdx, 'values',...
                                    [ceScanRanges{1}(k), ...
                                    ceScanRanges{2}(m)]);
                            else % raster direction
                                ceScanStates{end + 1} = struct('axes', u8ScanAxisIdx, 'values',...
                                    [ceScanRanges{1}(k), ...
                                    ceScanRanges{2}(length(ceScanRanges{2}) - m + 1)]);
                            end
                        end
                    end
                case 3
                    for k = 1:length(ceScanRanges{1})
                        for m = 1:length(ceScanRanges{2})
                            for p = 1:length(ceScanRanges{3})
                                if ~this.uicbRaster.get() || (this.uicbRaster.get() && isodd(m) && isodd(p))
                                    ceScanStates{end + 1} = struct('axes', u8ScanAxisIdx, 'values',...
                                        [ceScanRanges{1}(k), ceScanRanges{2}(m), ceScanRanges{3}(p)]);
                                elseif this.uicbRaster.get() && iseven(m) && isodd(p) % raster m
                                    ceScanStates{end + 1} = struct('axes', u8ScanAxisIdx, 'values',...
                                        [ceScanRanges{1}(k), ...
                                        ceScanRanges{2}(length(ceScanRanges{2}) - m + 1), ...
                                        ceScanRanges{3}(p)]);
                                elseif this.uicbRaster.get() && isodd(m) && iseven(p) % raster p
                                    ceScanStates{end + 1} = struct('axes', u8ScanAxisIdx, 'values',...
                                        [ceScanRanges{1}(k), ...
                                        ceScanRanges{2}(m), ...
                                        ceScanRanges{3}(length(ceScanRanges{3}) - p + 1)]);
                                elseif this.uicbRaster.get() && iseven(m) && iseven(p) % raster m and p
                                    ceScanStates{end + 1} = struct('axes', u8ScanAxisIdx, 'values',...
                                        [ceScanRanges{1}(k), ...
                                        ceScanRanges{2}(length(ceScanRanges{2}) - m + 1), ...
                                        ceScanRanges{3}(length(ceScanRanges{3}) - p + 1)]);
                                end
                            end
                        end
                    end
            end % Switch
                    
            u8OutputIdx = this.uipOutput.getSelectedIndex();
            this.fhOnScanButtonPress(ceScanStates, u8OutputIdx);
            
            % scan "states" are structures with properties: axes, values
            % where axes is an array of the indices of axes as defined in
            % the scanAxisSetup uipopup, and values are the corresponding
            % values
        end
        
        % Gets scan ranges for each scan axis
        function ceScanRanges = getScanRanges(this)
            for k = 1:this.dScanAxes
                ceScanRanges{k} = this.saScanAxisSetups.getScanRange(); 
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
            dY = 35;
            dScanButHeight = 70;
            dTop = 2;
            
            for k = 1:this.dScanAxes
                this.saScanAxisSetups{k}.build(this.hPanel, dLeft, ...
                    dTop);
                dTop = dTop + dPad + dY;
            end
            
             dTop = dTop + 3*dPad;
             
            % Build only if there is more than one axis
            if (this.dScanAxes > 1)
                this.uicbRaster.build(this.hPanel, 190, dTop + 2, 70, 25);
                this.uibStartScan.build(this.hPanel, 140, dTop, 45, 30);
                this.uipOutput.build(this.hPanel, 10, dTop - 10, 130, 40);
            else
                this.uibStartScan.build(this.hPanel, 140, dTop, 45, 30);
                this.uipOutput.build(this.hPanel, 10, dTop - 10, 130, 40);
            end
            
            this.uiSLScanSetup.build(this.hPanel, 487, 10, 340, dHeight - 20);
            
            
        end
        
       
        
        
        
        
    end
    
    methods (Access = protected)
        
        
        
        
        
        
    end
end