classdef ScalableAxes < mic.Base

   
    properties (Constant, Access = private)
    end
    

    properties

        
        % val is not a property because it can be several different types.
        % We use get() and set() methods that force the correct type
    end


    properties (Access = private)

        hPanel
        hAxes
        
        hXAxes
        hYAxes
        
        dHeight
        dWidth
        cLabel = 'Axes'
        cHorizontalAlignment = 'left'
        
        lShowLabel = true;
        lShowXSectionAxes = true;

        hZoomState
        
        dXData = []
        dYData = []
        dZData = 0
        
        cPlotType       = 'image' % 'plot' or 'image'
        cImageDomain    = 'real'
        cLogState       = 'none'
        cColormap       = 'default'
        cMedState       = 'normal'
        dCLim           = [0, 1]
        
        uiButton5_95
        uiButton0_100
        uiButtonMed
        uiButtonFft
        uiButtonLog
        uiButtonZoomToggle
        uiButtonColormapToggle
        
        uiSliderL
        uiSliderH
        
        uitCL
        uitCH
        
        uitMax
        uitMin
        uitAve
        uitPnt
        uitSat
        
        
    end


    properties (SetAccess = private)
        
        % hUI was here but we cannot have SetAccess = private properties
        % because load tries to set them
        
        xVal    % mixed type to store typecast version of cData
        xMin 
        xMax
        dColorGray = [.94 .94 .94]; % MATLAB default
        dColorBlue = [.85 .85 1];
    end


    events
    end

    %%
    methods
        
        %% constructor
        % cLabel, cType, lShowLabel, cHorizontalAlignment
        function this = ScalableAxes(varargin)

            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            

            this.uiButton5_95 = mic.ui.common.Button(...
                'cText', '5%/95%', 'fhDirectCallback', @(~,~)this.changeState(this.uiButton5_95) ...
            );
            this.uiButton0_100 = mic.ui.common.Button(...
                'cText', '0%/100%', 'fhDirectCallback', @(~,~)this.changeState(this.uiButton0_100) ...
            );
            this.uiButtonFft = mic.ui.common.Button(...
                'cText', 'FFT', 'fhDirectCallback', @(~,~)this.changeState(this.uiButtonFft) ...
            );
            this.uiButtonLog = mic.ui.common.Button(...
                'cText', 'LOG', 'fhDirectCallback',@(~,~)this.changeState(this.uiButtonLog) ...
            );
            this.uiButtonZoomToggle = mic.ui.common.Button(...
                'cText', 'Zoom', 'fhDirectCallback', @(~,~)this.changeState(this.uiButtonZoomToggle) ...
            );
            this.uiButtonColormapToggle = mic.ui.common.Button(...
                'cText', 'C/BW', 'fhDirectCallback', @(~,~)this.changeState(this.uiButtonColormapToggle) ...
            );
            this.uiButtonMed = mic.ui.common.Button(...
                'cText', '|MED - 2s|', 'fhDirectCallback', @(~,~)this.changeState(this.uiButtonMed) ...
            );
        
            this.uitCH = mic.ui.common.Text('cVal', 'H: 100%');
            this.uitCL = mic.ui.common.Text('cVal', 'L: 0%');
            
            this.uitMax = mic.ui.common.Text('cVal', 'Max: ');
            this.uitMin = mic.ui.common.Text('cVal', 'Min: ');
            this.uitAve = mic.ui.common.Text('cVal', 'Ave: ');
            this.uitPnt = mic.ui.common.Text('cVal', 'Point: ');
            this.uitSat = mic.ui.common.Text('cVal', 'Saturated Px: ');
        
        
        end

        %% Build
        function build(this, hParent, dLeft, dTop, dWidth, dHeight)
            
            if isa(hParent, 'matlab.ui.Figure')
                this.hZoomState = zoom(hParent);
            else
                try
                    this.hZoomState = zoom(hParent.hParent);
                catch me
                    fprintf('scalableAxes: no parent available for zoom');
                end
            end
               
            
            this.uiSliderL = uicontrol(hParent, 'style', 'slider', 'Callback', @(src,evt)this.changeState(src), ...
                                        'Position', [60, 5, dWidth - 50, 15], 'value', 0);
            this.uiSliderH = uicontrol(hParent, 'style', 'slider', 'Callback', @(src,evt)this.changeState(src), ...
                                        'Position', [60, 21, dWidth - 50, 15], 'value', 1);

            % Set zoom handle:
            
            
            % texts:
            this.uitCH.build(hParent, 5, dHeight + 10, 50, 15)
            this.uitCL.build(hParent, 5, dHeight + 29, 50, 15);
            
            
            
            
            % build panel:
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cLabel,...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'Position', [dLeft, dTop + 40, dWidth, dHeight - 40] ...
                );
            
            if (this.lShowXSectionAxes)
                this.hAxes = axes( ...
                    'Parent', this.hPanel, ...
                    'XTick', [0, 1], ...
                    'YTick', [0, 1], ...
                    'Position', [.15, .165, .8, .8]...
                    );
                
                this.hXAxes = axes( ...
                    'Parent', this.hPanel, ...
                    'XTick', [], ...
                    'YTick', [], ...
                    'Position', [.15, .045, .8, .07]...
                    );
                
                this.hYAxes = axes( ...
                    'Parent', this.hPanel, ...
                    'XTick', [], ...
                    'YTick', [], ...
                    'Position', [0.03, .165, .07, .8]...
                    );
                
            else
                this.hAxes = axes( ...
                    'Parent', this.hPanel, ...
                    'XTick', [0, 1], ...
                    'YTick', [0, 1], ...
                    'Position', [.05, .1, .9, .85]...
                    );
                
            end
           
            this.uitMax.build(this.hPanel, 10, dHeight - 150 + 10, 80, 15);
            this.uitMin.build(this.hPanel, 10, dHeight - 150 + 25, 80, 15);
            this.uitAve.build(this.hPanel, 10, dHeight - 150 + 40, 80, 15);
            this.uitPnt.build(this.hPanel, 10, dHeight - 150 + 55, 80, 15);
            this.uitSat.build(this.hPanel, 10, dHeight - 150 + 70, 80, 15);
        
            
         % 'Position', [dLeft/dParentPos(1), dTop/dParentPos(2), ...
               %                   this.dWidth/dParentPos(1), this.dHeight/dParentPos(2)]...
           
        
            this.uiButton5_95.build(this.hPanel, 0, dHeight - 60, 60, 20);
            this.uiButton0_100.build(this.hPanel, 60, dHeight - 60, 60, 20);
            this.uiButtonMed.build(this.hPanel, 120, dHeight - 60, 60, 20);
            this.uiButtonLog.build(this.hPanel, 180, dHeight - 60, 60, 20);
            this.uiButtonFft.build(this.hPanel, 240, dHeight - 60, 60, 20);
            this.uiButtonZoomToggle.build(this.hPanel, 300, dHeight - 60, 60, 20);
            this.uiButtonColormapToggle.build(this.hPanel, 360, dHeight - 60, 60, 20);
            
            this.uiButton5_95.setColor(this.dColorGray);
            this.uiButton0_100.setColor(this.dColorBlue);
            this.uiButtonMed.setColor(this.dColorGray);
            this.uiButtonLog.setColor(this.dColorGray);
            this.uiButtonFft.setColor(this.dColorGray);
            this.uiButtonZoomToggle.setColor(this.dColorBlue);
            this.uiButtonColormapToggle.setColor(this.dColorBlue);
            
            this.hZoomState.Enable = 'on';
                       
        end
        
  
        % Need to build plot tools
        function plot(this, varargin)
            this.cPlotType = 'plot';
            this.replot();
        end
        
        function manny(this)
            img = sum(imread('assets/manny_tophat.png'), 3);
            this.imagesc(img)
            
        end
        
        function imagesc(this, varargin)
            this.cPlotType = 'image';

            if length(varargin) == 1
                [sr, sc] = size(varargin{1});
                this.dXData = 1:sc;
                this.dYData = 1:sr;
               
                this.dZData = varargin{1};
            else
                this.dXData = varargin{1};
                this.dYData = varargin{2};
                this.dZData = varargin{3};
            end
            
            this.replot();
        end
        
      
        
        function changeState(this, src, ~)
            switch src
                case this.uiButtonFft 
                    if strcmp(this.cImageDomain, 'real')
                        this.cImageDomain = 'fft';
                        this.uiButtonFft.setColor(this.dColorBlue);
                    else
                        this.cImageDomain = 'real';
                        this.uiButtonFft.setColor(this.dColorGray);
                    end
                case this.uiButtonLog
                    if strcmp(this.cLogState, 'normal')
                        this.cLogState = 'log';
                        this.uiButtonLog.setColor(this.dColorBlue);
                    else
                        this.cLogState = 'normal';
                        this.uiButtonLog.setColor(this.dColorGray);
                    end
                case this.uiButtonColormapToggle
                    if strcmp(this.cColormap, 'default')
                        this.cColormap = 'gray';
                        this.uiButtonColormapToggle.setColor(this.dColorGray);
                    else
                        this.cColormap = 'default';
                        this.uiButtonColormapToggle.setColor(this.dColorBlue);
                    end     
                case this.uiButton5_95
                    this.uiSliderL.Value = 0.05;
                    this.uiSliderH.Value = 0.95;
                    this.uitCL.set(sprintf('L: %d%%', 5));
                    this.uitCH.set(sprintf('H: %d%%', 95));
                    
                    this.dCLim = [5, 95]/100;
                    this.uiButton0_100.setColor(this.dColorGray);
                    this.uiButton5_95.setColor(this.dColorBlue);
                case this.uiButton0_100
                    this.uiSliderL.Value = 0;
                    this.uiSliderH.Value = 1;
                    this.uitCL.set(sprintf('L: %d%%', 0));
                    this.uitCH.set(sprintf('H: %d%%', 100));
                    
                    this.dCLim = [0, 1];
                    this.uiButton5_95.setColor(this.dColorGray);
                    this.uiButton0_100.setColor(this.dColorBlue);
                case this.uiButtonMed
                    if strcmp(this.cMedState, 'normal')
                        this.cMedState = 'med';
                        this.uiButtonMed.setColor(this.dColorBlue);
                    else
                        this.cMedState = 'normal';
                        this.uiButtonMed.setColor(this.dColorGray);
                    end   
                case this.uiButtonZoomToggle
                     switch this.hZoomState.Enable
                         case 'on'
                             this.hZoomState.Enable = 'off';
                             
                             this.uiButtonZoomToggle.setColor(this.dColorGray);
                         case 'off'
                             this.hZoomState.Enable = 'on';
                             this.uiButtonZoomToggle.setColor(this.dColorBlue);
                     end
                case this.uiSliderH
                    if this.uiSliderL.Value >= this.uiSliderH.Value
                        this.uiSliderL.Value = this.uiSliderH.Value - .01;
                    end
                    
                    this.dCLim(1) = this.uiSliderL.Value;
                    this.dCLim(2) = this.uiSliderH.Value;
                    
                    this.uiButton0_100.setColor(this.dColorGray);
                    this.uiButton5_95.setColor(this.dColorGray);
                    
                    this.uitCH.set(sprintf('H: %d%%', round(this.uiSliderH.Value*100)));
                    this.uitCL.set(sprintf('L: %d%%', round(this.uiSliderL.Value*100)));
                    
                    
                case this.uiSliderL
                    if this.uiSliderL.Value >= this.uiSliderH.Value
                        this.uiSliderH.Value = this.uiSliderL.Value + .01;
                    end
                    
                    this.dCLim(1) = this.uiSliderL.Value;
                    this.dCLim(2) = this.uiSliderH.Value;
                    
                    this.uiButton0_100.setColor(this.dColorGray);
                    this.uiButton5_95.setColor(this.dColorGray);
                    
                    this.uitCH.set(sprintf('H: %d%%', round(this.uiSliderH.Value*100)));
                    this.uitCL.set(sprintf('L: %d%%', round(this.uiSliderL.Value*100)));
                    
                    
            end
            this.replot();
        end
        
        function replot(this)
            switch this.cPlotType
                case 'none'
                case 'plot'
                    
                case 'image'
                    dData = this.dZData;
                    
                    this.uitMax.set(sprintf('Max: %d', round(max(dData(:)))));
                    this.uitMin.set(sprintf('Min: %d', round(min(dData(:)))));
                    this.uitAve.set(sprintf('Ave: %0.1f', mean(dData(:))));
                    this.uitPnt.set(sprintf('Pnt:'));
                    this.uitSat.set(sprintf('Saturated Px: %d', sum(double(dData(:) > 65535))));
            
            
                    if strcmp(this.cImageDomain, 'fft')
                        dData = abs(fftshift(fft2(this.dZData)));
                    end
                    if strcmp(this.cLogState, 'log')
                        dData = log(dData);
                    end
                    if strcmp(this.cMedState, 'med')
                        dScaleFac = 2;
                        dMed = median(dData(:));
                        dMedMin = min(abs([(dMed - min(dData(:))), (dMed - max(dData(:)))]));
                        dStd = std(dData(:)) * dScaleFac;
                        dData(dData < dMed - dStd ) = dMed - dStd;
                        dData(dData > dMed + dStd) = dMed + dStd;
                    end
                    
                    % create image:
                    imagesc(this.hAxes, this.dXData, this.dYData, dData);
                    set(this.hAxes, 'YDir', 'normal');
                    
                    
                    
                    % Get min and max values:
                    dMin = min(this.hAxes.Children.CData(:));
                    dMax = max(this.hAxes.Children.CData(:));
                    
                    dRange = dMax - dMin;
                    colorbar('peer',this.hAxes)
                    colormap(this.hAxes, this.cColormap)
                    dLim =  [(dMin + dRange*this.dCLim(1)) (dMin + dRange*this.dCLim(2))];
                    if ~any(isnan(dLim))
                        this.hAxes.CLim =dLim;
                    end
                    
                    if (this.lShowXSectionAxes)
                        % generate cross sections:
                        xSec = sum(dData,1);
                        ySec = sum(dData,2);
                        
                        plot(this.hXAxes, this.dXData, xSec, 'm', 'linewidth', 1.5);
                        plot(this.hYAxes, this.dYData, ySec, 'm', 'linewidth', 1.5);
                        this.hYAxes.CameraUpVector = [1 0 0 ];
                        this.hXAxes.XTick = [];
                        this.hXAxes.YTick = [];
                        this.hYAxes.XTick = [];
                        this.hYAxes.YTick = [];
                        this.hXAxes.Color = [0 0 0];
                        this.hYAxes.Color = [0 0 0];
                        
                        this.hXAxes.XLim = [0, length(xSec)];
                        this.hYAxes.XLim = [0, length(ySec)];
                        
                        
                        
                        % Resize X x-section to fit colorbar:
                        dPosMain = this.hAxes.Position;
                        dPosX = this.hXAxes.Position;
                        dPosX(3) = dPosMain(3);
                        this.hXAxes.Position = dPosX;
                        
                    end
                    
                    
                   
            end
            
        end
        
        function letMeIn(this)
           1; 
        end

    end

    methods (Access = protected)


        


    end
end