classdef ScalableAxes < mic.Base

   
    properties (Constant, Access = private)
        U8DOMAIN_REAL       = 1
        U8DOMAIN_FFT        = 2
        
        U8LOGSTATE_LOG      = 1
        U8LOGSTATE_NORMAL   = 2
        
        U8COLORSTATE_DEFAULT = 1
        U8COLORSTATE_GRAY   = 2
        
    end
    

    properties

        
        % val is not a property because it can be several different types.
        % We use get() and set() methods that force the correct type
    end


    properties (Access = private)

        hParentFigure
        hPanelAxes
        hPanelMain
        hAxes
        hImageChild
        
        dFigOffsetXY = [0, 0]
        
        hXAxes
        hYAxes
        
        dHeight
        dWidth
        cLabel = 'Axes'
        cHorizontalAlignment = 'left'
        
        lShowLabel = true;
        lShowXSectionAxes = true;
        
        fhOnDomainChange = @(cAnalysisDomain)[]

        hZoomState
        
        dXData = []
        dYData = []
        dZData = 0
        
        cImageDomain 
        cLogState       = 'none'
        cColormap       = 'default'
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
        
        uitRange
        uitAve
        uitPnt
        uitSat
        
        lnMainLineX
        lnMainLineY
        lnSecLineX
        lnSecLineY
        ptCircle
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
            
            this.cImageDomain = this.U8DOMAIN_REAL;
            this.cLogState = this.U8LOGSTATE_NORMAL;
            this.cColormap = this.U8COLORSTATE_DEFAULT;

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
            
            this.uitRange = mic.ui.common.Text('cVal', '[0 0]');
            this.uitAve = mic.ui.common.Text('cVal', 'Av: ');
            this.uitPnt = mic.ui.common.Text('cVal', 'Point: ');
            this.uitSat = mic.ui.common.Text('cVal', 'Sat: ');
        
        
        end

        %% Build
        function build(this, hParent, hParentFigure, dLeft, dTop, dWidth, dHeight)
            
            this.hParentFigure = hParentFigure;
            if isa(this.hParentFigure, 'matlab.ui.Figure')
                this.hZoomState = zoom(this.hParentFigure);
            end
               

            
             % build panel:
            this.hPanelMain = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cLabel,...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',1, ... 
                'Position', [dLeft, dTop, dWidth, dHeight] ...
                );
            % build panel:
            this.hPanelAxes = uipanel(...
                'Parent', this.hPanelMain,...
                'Units', 'pixels',...
                'FontWeight', 'Bold',...
                'Clipping', 'on',...
                'BorderWidth',0, ... 
                'Position', [0,  40, dWidth, dHeight - 40] ...
                );
            
            
            this.uiSliderL = uicontrol(this.hPanelMain, 'style', 'slider', 'Callback', @(src,evt)this.changeState(src), 'Units', 'pixels', ...
                                        'Position', [55, 3, dWidth - 60, 15], 'value', 0);
            this.uiSliderH = uicontrol(this.hPanelMain, 'style', 'slider', 'Callback', @(src,evt)this.changeState(src), 'Units', 'pixels',...
                                        'Position', [55, 19, dWidth - 60, 15], 'value', 1);

            % Set zoom handle:
            
            
            % texts:
            this.uitCH.build(this.hPanelMain, 5, dHeight - 36, 50, 15)
            this.uitCL.build(this.hPanelMain, 5, dHeight - 20, 50, 15);
            
            if (this.lShowXSectionAxes)
                this.hAxes = axes( ...
                    'Parent', this.hPanelAxes, ...
                    'XTick', [0, 1], ...
                    'YTick', [0, 1], ...
                    'Position', [.15, .165, .8, .78]...
                    );
                this.hXAxes = axes( ...
                    'Parent', this.hPanelAxes, ...
                    'XTick', [], ...
                    'YTick', [], ...
                    'Position', [.15, .045, .8, .07]...
                    );
                
                this.hYAxes = axes( ...
                    'Parent', this.hPanelAxes, ...
                    'XTick', [], ...
                    'YTick', [], ...
                    'Position', [0.03, .165, .07, .78]...
                    );
                
            else
                this.hAxes = axes( ...
                    'Parent', this.hPanelAxes, ...
                    'XTick', [0, 1], ...
                    'YTick', [0, 1], ...
                    'Position', [.05, .1, .9, .85]...
                    );
                
            end
           
            this.uitRange.build(this.hPanelAxes, 10, dHeight - 150 + 40, 60, 15);
            this.uitAve.build(this.hPanelAxes, 10, dHeight - 150 + 55, 60, 15);
%             this.uitPnt.build(this.hPanelAxes, 10, dHeight - 150 + 55, 80, 15);
            this.uitSat.build(this.hPanelAxes, 10, dHeight - 150 + 70, 60, 15);
        
            
         % 'Position', [dLeft/dParentPos(1), dTop/dParentPos(2), ...
               %                   this.dWidth/dParentPos(1), this.dHeight/dParentPos(2)]...
           
        
            this.uiButton5_95.build(this.hPanelAxes, 0, dHeight - 60, 60, 20);
            this.uiButton0_100.build(this.hPanelAxes, 60, dHeight - 60, 60, 20);
%             this.uiButtonMed.build(this.hPanelAxes, 120, dHeight - 60, 60, 20);
            this.uiButtonLog.build(this.hPanelAxes, 180, dHeight - 60, 60, 20);
            this.uiButtonFft.build(this.hPanelAxes, 240, dHeight - 60, 60, 20);
            this.uiButtonZoomToggle.build(this.hPanelAxes, 300, dHeight - 60, 60, 20);
            this.uiButtonColormapToggle.build(this.hPanelAxes, 360, dHeight - 60, 60, 20);
            
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
        function hPlotHandle = plot(this, varargin)
            hPlotHandle = plot(this.hAxes, varargin{:});
        end
        
        function manny(this)
            img = sum(imread('assets/manny_tophat.png'), 3);
            this.imagesc(img)
            
        end
        
        function setAxesOffset(this, dOffset)
            this.dFigOffsetXY = dOffset;
        end
        
        function imagesc(this, varargin)

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
        
        function setHoldState(this, cState) % 'on' or 'off'
            switch cState
                case 'on'
                    this.hAxes.NextPlot = 'add';
                case 'off'
                    this.hAxes.NextPlot = 'replace';
            end
        end
      
        function cDomain = getAnalysisDomain(this)
            cDomain = this.cImageDomain;
        end
        
        function setAnalysisDomain(this, cDomain)
            if this.cImageDomain == this.U8DOMAIN_REAL
                this.cImageDomain = cDomain;
                this.uiButtonFft.setColor(this.dColorBlue);
            else
                this.cImageDomain = cDomain;
                this.uiButtonFft.setColor(this.dColorGray);
            end
            this.replot();
        end
        
        function changeState(this, src, ~)
            switch src
                case this.uiButtonFft 
                    
                    if this.cImageDomain == this.U8DOMAIN_REAL
                        this.cImageDomain =  this.U8DOMAIN_FFT;
                        this.uiButtonFft.setColor(this.dColorBlue);
                    else
                        this.cImageDomain = this.U8DOMAIN_REAL;
                        this.uiButtonFft.setColor(this.dColorGray);
                    end
                    this.replot();
                    this.fhOnDomainChange(this.cImageDomain)
                case this.uiButtonLog
                    if this.cLogState == this.U8LOGSTATE_NORMAL
                        this.cLogState = this.U8LOGSTATE_LOG;
                        this.uiButtonLog.setColor(this.dColorBlue);
                    else
                        this.cLogState = this.U8LOGSTATE_NORMAL;
                        this.uiButtonLog.setColor(this.dColorGray);
                    end
                    this.replot();
                case this.uiButtonColormapToggle
                    if this.cColormap == this.U8COLORSTATE_DEFAULT
                        this.cColormap = this.U8COLORSTATE_GRAY;
                        this.uiButtonColormapToggle.setColor(this.dColorGray);
                        colormap(this.hAxes, 'gray')
                    else
                        this.cColormap = this.U8COLORSTATE_DEFAULT;
                        this.uiButtonColormapToggle.setColor(this.dColorBlue);
                         colormap(this.hAxes, 'default')
                    end     
                case this.uiButton5_95
                    this.uiSliderL.Value = 0.05;
                    this.uiSliderH.Value = 0.95;
                    this.uitCL.set(sprintf('L: %d%%', 5));
                    this.uitCH.set(sprintf('H: %d%%', 95));
                    
                    this.dCLim = [5, 95]/100;
                    this.uiButton0_100.setColor(this.dColorGray);
                    this.uiButton5_95.setColor(this.dColorBlue);
                    
                    this.rescale();
                case this.uiButton0_100
                    this.uiSliderL.Value = 0;
                    this.uiSliderH.Value = 1;
                    this.uitCL.set(sprintf('L: %d%%', 0));
                    this.uitCH.set(sprintf('H: %d%%', 100));
                    
                    this.dCLim = [0, 1];
                    this.uiButton5_95.setColor(this.dColorGray);
                    this.uiButton0_100.setColor(this.dColorBlue);
                    
                    this.rescale();
%                 case this.uiButtonMed
%                     if strcmp(this.cMedState, 'normal')
%                         this.cMedState = 'med';
%                         this.uiButtonMed.setColor(this.dColorBlue);
%                     else
%                         this.cMedState = 'normal';
%                         this.uiButtonMed.setColor(this.dColorGray);
%                     end   
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
                    
                    this.rescale();
                    
                    
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
                    
                    this.rescale();
            end
%             this.replot();
        end
        
        function rescale(this)
            % Get min and max values:
            dMin = min(this.hImageChild.CData(:));
            dMax = max(this.hImageChild.CData(:));
            dRange = dMax - dMin;
            colorbar('peer',this.hAxes)
            if (this.cColormap == this.U8COLORSTATE_DEFAULT)
                colormap(this.hAxes, 'default')
            else
                colormap(this.hAxes, 'gray')
            end
            
            dLim =  [(dMin + dRange*this.dCLim(1)) (dMin + dRange*this.dCLim(2))];
            if dLim(2) == dLim(1)
                dLim(2) = dLim(1) + 1e-6;
            end
            
            if ~any(isnan(dLim))
                this.hAxes.CLim =dLim;
            end
 
            this.hXAxes.YLim = dLim;
            this.hYAxes.YLim = dLim;
            this.hAxes.CLim = dLim;    
        end
        
        function replot(this)
           
      
            dData = this.dZData;
            
            this.uitRange.set(sprintf('[%d -> %d]', round(min(dData(:))), round(max(dData(:))) ));
            this.uitAve.set(sprintf('Av: %0.1f', mean(dData(:))));
            %                     this.uitPnt.set(sprintf('Pnt:'));
            this.uitSat.set(sprintf('Sat: %d', sum(double(dData(:) >= 65535))));
            
            
            if this.cImageDomain == this.U8DOMAIN_FFT
                dData = abs(fftshift(fft2(this.dZData)));
            end
            if this.cLogState == this.U8LOGSTATE_LOG
                dData = log(dData);
            end
%             if strcmp(this.cMedState, 'med')
%                 dScaleFac = 2;
%                 dMed = median(dData(:));
%                 dMedMin = min(abs([(dMed - min(dData(:))), (dMed - max(dData(:)))]));
%                 dStd = std(dData(:)) * dScaleFac;
%                 dData(dData < dMed - dStd ) = dMed - dStd;
%                 dData(dData > dMed + dStd) = dMed + dStd;
%             end
            
            % create image:
            this.hImageChild = imagesc(this.hAxes, this.dXData, this.dYData, dData);
            set(this.hAxes, 'YDir', 'normal');
            
            
            
  
            
            if (this.lShowXSectionAxes)
                % generate cross sections:
                xSec = mean(dData,1);
                ySec = mean(dData,2);
                
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
                
                
                
            end      
            
            this.rescale();
            this.alignXsec();

        end
        
        function alignXsec(this)
            drawnow
            % Resize X x-section to fit colorbar:
            dPosMain = this.hAxes.Position;
            dPosX = this.hXAxes.Position;
            
%             fprintf('Changing xsec len from %0.2f to %0.2f\n', dPosX(3), dPosMain(3));
            dPosX(3) = dPosMain(3);
            this.hXAxes.Position = dPosX;
             
        end
        
        function letMeIn(this)
           1; 
        end
        
        
        function xy = ginput(this, dCircRad)
            if nargin == 1
                dCircRad = 1;
            end
            
            
            colormap(this.hAxes, 'gray')
            
            delete(this.lnMainLineX);
            delete(this.lnMainLineY);
            delete(this.lnSecLineX);
            delete(this.lnSecLineY);
            delete(this.ptCircle);
            
            dMin = min(this.hImageChild.CData(:));
            dMax = max(this.hImageChild.CData(:));
            
            % Turn off zoom
            this.hZoomState.Enable = 'off';
            this.uiButtonZoomToggle.setColor(this.dColorGray);
            
            drawnow

            xy = zeros(1,2);
            
            set(this.hParentFigure,'WindowButtonMotionFcn',@changepointer)
            set(this.hAxes,'ButtonDownFcn',@getpoints)
            
            set(this.hImageChild,'hittest','off')
            
            % make base circle:
            idx = linspace(0, 2*pi, 51)';
            dX = dCircRad*cos(idx);
            dY = dCircRad*sin(idx);
           
            this.lnMainLineX = line(this.hAxes, [0, 1], [0, 1]);
            this.lnMainLineY = line(this.hAxes, [0, 1], [0, 1]);
            this.lnSecLineX = line(this.hXAxes, [0, 1], [0, 1]);
            this.lnSecLineY = line(this.hYAxes, [0, 1], [0, 1]);
            this.ptCircle   = patch(this.hAxes, dX, dY, 'y');
            
            
            
            
            % Line Styling
            this.lnMainLineX.Color = 'g';
            this.lnMainLineY.Color = 'g';
            this.lnSecLineX.Color = 'g';
            this.lnSecLineY.Color = 'g';
            this.lnMainLineX.LineWidth = 2;
            this.lnMainLineY.LineWidth = 2;
            this.lnSecLineX.LineWidth = 2;
            this.lnSecLineY.LineWidth = 2;
            this.lnMainLineX.HitTest = 'off';
            this.lnMainLineY.HitTest = 'off';
            this.lnSecLineX.HitTest = 'off';
            this.lnSecLineY.HitTest = 'off';
            this.ptCircle.HitTest = 'off';
            this.ptCircle.FaceAlpha = 0.2;
            this.ptCircle.EdgeColor = 'r';
            this.ptCircle.EdgeAlpha = 0.3;
            this.ptCircle.LineWidth = 2;
            
            waitfor(this.hParentFigure,'WindowButtonMotionFcn',[])
            
            delete(this.lnMainLineX);
            delete(this.lnMainLineY);
            delete(this.lnSecLineX);
            delete(this.lnSecLineY);
            delete(this.ptCircle);
            
            if this.cColormap == this.U8COLORSTATE_DEFAULT
                colormap(this.hAxes, 'default')
            end

            function changepointer(~,~)
                PLaxes = get(this.hAxes, 'CurrentPoint');
                dXVal = PLaxes(1,1);
                dYVal = PLaxes(1, 2);
                    
                    
                    
                if dXVal > 0 && dYVal > 0 && dXVal < this.dXData(end) && dYVal < this.dYData(end)
                    set(this.hParentFigure,'Pointer','crosshair')

                    
                    % display lines on axes:
                    this.lnMainLineX.XData = [this.dXData(1), this.dXData(end)];
                    this.lnMainLineX.YData = dYVal*[1, 1];
                    this.lnMainLineY.XData = dXVal*[1, 1];
                    this.lnMainLineY.YData = [this.dYData(1), this.dYData(end)];
                    this.ptCircle.Vertices = [dXVal + dX, dYVal + dY];

                    
                    this.lnSecLineX.XData = dXVal*[1, 1];
                    this.lnSecLineX.YData = [dMin, dMax];
                    this.lnSecLineY.XData = dYVal*[1, 1];
                    this.lnSecLineY.YData = [dMin, dMax];
                    
                    
                else
                    set(this.hParentFigure,'Pointer','arrow')
                end
                
               
            end
            
            function getpoints(hObj,~,~)
                fprintf('getting points now!');
                cp = get(hObj,'CurrentPoint');
                xy(1,:) = cp(1,1:2);
                set(this.hParentFigure,'Pointer','arrow')
                set(this.hParentFigure,'WindowButtonMotionFcn',[])
                set(this.hAxes,'ButtonDownFcn',[])

            end
            
        end
        
        

    end

    methods (Access = protected)


        


    end
end