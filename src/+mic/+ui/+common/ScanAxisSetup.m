classdef ScanAxisSetup < mic.Base
    
    
    properties (Constant)
        
    end
    
    
    properties (SetAccess = private)
        
        
    end
    
    properties
        uieStart
        uieStep
        uieEnd
        uieNSteps
        uipSelectInput
        uicbCenterOnValue
        
    end
    
    properties (Access = protected)
        
        dLeft
        dTop
        dWidth = 460
        dHeight = 25;
        
        ceScanOptions = {'Axis 1', 'Axis 2', 'Axis 3'}
                        

        hParent % parent should be a scan axis setup
        hPanel
        
        
        
        uitxLabelStart
        uitxLabelStep
        uitxLabelEnd
        uitxLabelNSteps
        
        
        
        
        
        
        uibFill
        uibCenter0
        uibComputeStep
        uibComputeEnd        
        
           % height of the row for controls
        dHeightBtn = 24;
        dHeightEdit = 20;
        dHeightPopup = 24;
        dHeightLabel = 16;
        dHeightText = 16;
        
        dWidthPad = 8;
        dWidthName = 50;
        dWidthVal = 75;
        dWidthUnit = 80;
        dWidthDest = 50;
        dWidthEdit = 35;
        dWidthBtn = 24;
        dWidthStores = 100;
        dWidthStep = 50;
        dWidthRange = 120;
        
        
        dWidth2 = 250;
        dHeight2 = 50;
        dPad2 = 0;
        dWidthStatus = 5;
        
        cScanLabel = 'Scan axis'
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
        
        dColorOff   = [244 245 169]./255;
        dColorOn    = [241 241 241]./255; 
        
        dColorBg = [.94 .94 .94]; % MATLAB default
    end
    
    
    
    methods
        
        % constructor
        
        
        function this = ScanAxisSetup(varargin)
            
            this.msg('constructor', this.u8_MSG_TYPE_CREATE_UI_COMMON);
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.initScanAxes();
        end
        
        function initScanAxes(this)
            
%             this.uitxLabelStart =  mic.ui.common.Text(...
%                 'cVal', 'Start', ...
%                 'cAlign', 'left' ...
%             );
%         
%             this.uitxLabelStep = mic.ui.common.Text(...
%                 'cVal', 'Step', ...
%                 'cAlign', 'left' ...
%             );
%         
%             this.uitxLabelEnd = mic.ui.common.Text(...
%                 'cVal', 'End', ...
%                 'cAlign', 'left' ...
%             );
%         
%             this.uitxLabelNSteps = mic.ui.common.Text(...
%                 'cVal', 'N Steps', ...
%                 'cAlign', 'left' ...
%             );
%         
            
            this.uieStart = mic.ui.common.Edit(...
                'cLabel', 'Start', ...
                'cType', 'd', ...
                'lShowLabel', true, ...
                'lBypassValidation', true ...
            );
        
            this.uieStep = mic.ui.common.Edit(...
                'cLabel', 'Step', ...
                'cType', 'd', ...
                'lShowLabel', true, ...
                'lBypassValidation', true ...
            );
        
            this.uieEnd = mic.ui.common.Edit(...
                'cLabel', 'End', ...
                'cType', 'd', ...
                'lShowLabel', true, ...
                'lBypassValidation', true ...
            );
        
            this.uieNSteps = mic.ui.common.Edit(...
                'cLabel', 'N', ...
                'cType', 'd', ...
                'lShowLabel', true, ...
                'lBypassValidation', true ...
            );
        
            this.uipSelectInput = mic.ui.common.Popup(...
                    'cLabel', this.cScanLabel, ...
                    'ceOptions', this.ceScanOptions, ...
                    'lShowLabel', true ...
                );

            
            this.uicbCenterOnValue = mic.ui.common.Checkbox(...
                    'cLabel', 'Use Deltas', ...
                    'dColor', this.dColorBg...
                    );
            this.uibFill = mic.ui.common.Button(...
                    'cText', 'Fill', ...
                    'fhDirectCallback', @this.fill);
            this.uibCenter0 = mic.ui.common.Button(...
                'cText', 'Center', ...
                'fhDirectCallback', @this.center0);

                
               
            
        end
        
        % if End is 0, fill end using Nsteps, start and step
        % if Steps is 0, fill using Nsteps, start, and end
        function fill(this)
            % get values:
            dStart = this.uieStart.get();
            dStep = this.uieStep.get();
            dEnd = this.uieEnd.get();
            dNSteps = this.uieNSteps.get();
            
            if (dNSteps == 0)
                msgbox('To fill scan parameters, enter a non-zero NSteps');
                return
            end
            if (dStep == 0)
                % fill step using start, end and nSteps:
                dStep = (dEnd - dStart)/dNSteps;
                
                this.uieStep.set(dStep);
                
                
            elseif dEnd == 0
                % if End is 0, fill end using Nsteps, start and step
                dEnd = (dStart + (dNSteps - 1) * dStep);
                this.uieEnd.set(dEnd);
                
            end
    
        end
        
        function center0(this)
            % get values:
            dStart = this.uieStart.get();
            dStep = this.uieStep.get();
            dEnd = this.uieEnd.get();
            dNSteps = this.uieNSteps.get();
            
            dAve = (dEnd + dStart)/2;
            
            dStart = dStart - dAve;
            dEnd = dEnd - dAve;
            
            this.uieStart.set(dStart);
            this.uieEnd.set(dEnd);
            
        end
        
        
        % Gets the array of values specified by this scan range
        function dScanRange = getScanRanges(this)
            dStart = this.uieStart.get();
            dStep = this.uieStep.get();
            dEnd = this.uieEnd.get();
            
            dScanRange = dStart:dStep:dEnd*1.001;
        end
        
        function cName = getScanAxisName(this)
            cName = this.uipSelectInput.getSelectedValue();
        end
        
        function u8Val = getScanAxisIndex(this)
            u8Val = this.uipSelectInput.getSelectedIndex();
        end
        
        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UI element associated with the class
        %   HardwareIO.build(hParent, dLeft, dTop)
        %
        % See also HARDWAREIO, INIT, DELETE       
            
        
            
                                    %'BorderWidth',0, ... 

            dHeight = this.dHeight ; %#ok<*PROPLC>
            dHeight = dHeight + this.dHeightLabel + 5;

            dWidth = this.dWidth;

            this.hPanel = uipanel( ...
                'Parent', hParent, ...
                'Units', 'pixels', ...
                'Title', blanks(0), ...
                'Clipping', 'on', ...
                'BackgroundColor', this.dColorBg, ...
                'BorderWidth',0, ... 
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent));
            drawnow


            y_rel = -1;


           

            dTop = -1;
            dTop = 0;
            dTopLabel = -1;
            dTop = this.dHeightLabel - 10;

            dLeft = 1;


            


            % uiEdits
            
            this.uipSelectInput.build(this.hPanel, dLeft, dTop, 110, 20);
            dLeft = dLeft + 110;
            
            
%             this.uitxLabelStart.build(this.hPanel,  dLeft, dTopLabel, this.dWidthEdit, this.dHeightLabel);
                
            this.uieStart.build(this.hPanel, dLeft, dTop, this.dWidthEdit, this.dHeightEdit);
            dLeft = dLeft + this.dWidthEdit + this.dWidthPad;
            
%             this.uitxLabelStep.build(this.hPanel, dLeft, dTopLabel, this.dWidthEdit, this.dHeightLabel);
            
            this.uieStep.build(this.hPanel, dLeft, dTop, this.dWidthEdit, this.dHeightEdit);
            dLeft = dLeft + this.dWidthEdit + this.dWidthPad;
            
%             this.uitxLabelEnd.build(this.hPanel, dLeft, dTopLabel, this.dWidthEdit, this.dHeightLabel);
            
            this.uieEnd.build(this.hPanel, dLeft, dTop, this.dWidthEdit, this.dHeightEdit);
            dLeft = dLeft + this.dWidthEdit + this.dWidthPad;
            
%             this.uitxLabelNSteps.build(this.hPanel, dLeft, dTopLabel, this.dWidthEdit, this.dHeightLabel);
            
            this.uieNSteps.build(this.hPanel, dLeft, dTop, this.dWidthEdit - 10, this.dHeightEdit);
            dLeft = dLeft + this.dWidthEdit - 10 + this.dWidthPad;
        
            this.uibFill.build(this.hPanel, dLeft, dTop + 14, 30, 18);
            dLeft = dLeft +  30 +  this.dWidthPad;
            
            this.uibCenter0.build(this.hPanel, dLeft, dTop + 14, 45, 18);
            dLeft = dLeft +  45 +  this.dWidthPad;
            
            
            this.uicbCenterOnValue.build(this.hPanel, dLeft, dTop + 14, 80, 18);
            

                    
        end
        
       
        
        
        
        
    end
    
    methods (Access = protected)
        
        
        
        
        
        
    end
end