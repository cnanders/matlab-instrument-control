classdef ZoomPanAxes < mic.Base
    
    % zpa
    
    % The class creates a panel in a parent figure that contains an axes.
    % The axes has a single direct child, which is an instance of a hgGroup
    % (Handle Graphics Group).  The idea of this class is to
    % provide a zoom/pan layer for viewing 2D graphical information.  All
    % you do is tell the class how big its axes is (pixels x pixels) and
    % the bounds (in arbitrary units) of the 2D graphical information it is
    % displaying
    %
    %   dXMin           (arb. units)
    %   dXMax           (arb. units)
    %   dyMin           (arb. units)
    %   dYMax           (arb. units)
    %   dAxesWidth      (pixels)
    %   dAxesHeight     (pixels)
    %
    % this class takes care of all of the math that is involved updating
    % the xlim and ylim properties of the axes as you move the zoom, panX,
    % and panY sliders around.  
    %
    % If you need to change the graphical information that is displayed
    % within the axes, all you do is modify the single hgGroup instance
    % that is the master parent for all graphical information.  If you are
    % unfamiliar with hgGroup, it is a way to group graphical elements that
    % matlab creates.  For example h = patch() returns a handle whose 
    % 'Parent' property can be set to the handle of an axis, the handle of
    % a hggroup, or the handle of a hgtransform. 
    %
    % Use:
    %
    % Create a ZoomPanAxes instanze
    %   zpa = ZoomPanInstance(-1, 1, -1, 1, 800, 500);
    % Set the hHggroup property
    %   zpa.hHggroup = hLocalHgGroup
    % Update hLocalHgGroup (including transformations, adding, removing
    % children, etc
    
    % h = hggroup creates an hggroup object as a child of the current axes
    % and returns its handle, h.
    
	properties
                
        
        hHggroup
                
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        
        lDragging = false
        
        dXDrag
        dYDrag
        
        dDragStartLeft
        dDragStartLeftRel
        dDragStartBottom
        dDragStartBottomRel
        
        dXPan
        dYPan
        dZoom
        
        hParent
        hPanel
        hSliderZoom
        hSliderXPan
        hSliderYPan
        hAxes
        hCenterText
        hZoomText
                
        dXMin = -1
        dXMax = 1
        dYMin = -1
        dYMax = 1
                
        dZoomMin = 1
        dZoomMax = 5
        
        dAxesWidth = 1000
        dAxesHeight = 500
        
        % Minor step is when you click the little arrow at the end of the
        % slider; major step is when you click on the slider track to make
        % it jump by a large amount
        
        dMinorStep = 1/50;  % positive value that indicates the size of the major and minor steps as a percent change in slider value
        dMajorStep = 1/10;
        
        dXRange         % set in init()
        dYRange         % set in init()
        dAxesAR         % set in init()
        dCanvasAR       % set in init()
        
        dSliderPad = 10
        dSliderThick = 15
        dAxesColor = [0.7 0.7 0.7]
                        
    end
    
        
    events
        
        eClick
        eZoom
        ePanX
        ePanY
        
    end
    

    
    methods
        
        
        function this = ZoomPanAxes( ...
            dXMin, ...
            dXMax, ...
            dYMin, ...
            dYMax, ...
            dAxesWidth, ...
            dAxesHeight, ...
            dZoomMax ...
        )
            
            
            this.dXMin = dXMin;
            this.dXMax = dXMax;
            this.dYMin = dYMin;
            this.dYMax = dYMax;
            this.dAxesWidth = dAxesWidth;
            this.dAxesHeight = dAxesHeight;
            this.dZoomMax = dZoomMax;
            this.init();
            
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent

            % Panel
            this.hPanel = uipanel(...
                'Parent', this.hParent,...
                'Units', 'pixels',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dAxesWidth this.dAxesHeight], this.hParent), ...
                'ButtonDownFcn', @this.onPanelButtonDown ...
            );
        
            % 'Title', 'Reticle Coarse Stage',...

        
			drawnow;
            
            % The axes fills the entire panel.  Sliders are "on top" of the
            % ases
            
            this.hAxes = axes(...
                'Parent', this.hPanel,...
                'Units', 'pixels',...
                'Position', mic.Utils.lt2lb([0 0 this.dAxesWidth this.dAxesHeight], this.hPanel), ...
                'XTick', [], ...
                'YTick', [], ...
                'XLim', [this.dXMin this.dXMax], ...
                'YLim', [this.dYMin this.dYMax], ...
                'XColor', 'white',...
                'YColor', 'white',...
                'Color', this.dAxesColor ,...
                'DataAspectRatio', [1 1 1],...
                'PlotBoxAspectRatio', [this.dAxesWidth this.dAxesHeight 1],...
                'HandleVisibility', 'on', ...
                'ButtonDownFcn', @this.onAxesButtonDown ...
            );
            
            this.hSliderXPan = uicontrol(...
                'Parent', this.hPanel,...
                'Style', 'slider', ...
                'Min', this.dXMin, ...
                'Max', this.dXMax, ...
                'Value', (this.dXMax + this.dXMin)/2, ...
                'SliderStep', [this.dMinorStep this.dMajorStep],...
                'Position', mic.Utils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dAxesHeight - 2*this.dSliderPad - 2*this.dSliderThick ...
                    this.dAxesWidth - 2*this.dSliderPad ...
                    this.dSliderThick], this.hPanel) ...
            );
        
        
            this.hSliderYPan = uicontrol(...
                'Parent', this.hPanel,...
                'Style', 'slider', ...
                'Min', this.dYMin, ...
                'Max', this.dYMax, ...
                'Value', (this.dYMax + this.dYMin)/2, ...
                'SliderStep', [this.dMinorStep this.dMajorStep],...
                'Position', mic.Utils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dSliderPad ...
                    this.dSliderThick ...
                    this.dAxesHeight - 4*this.dSliderPad - 2*this.dSliderThick], this.hPanel) ...
            );
        

            this.hSliderZoom = uicontrol(...
                'Parent', this.hPanel, ...
                'Style', 'slider', ...
                'Min', this.dZoomMin, ...
                'Max', this.dZoomMax, ...
                'Callback', @this.onSliderZoom, ...
                'Value', 1, ...
                'SliderStep', [this.dMinorStep this.dMajorStep],...
                'Position', mic.Utils.lt2lb( ...
                    [this.dSliderPad ...
                    this.dAxesHeight - this.dSliderPad - this.dSliderThick ...
                    this.dAxesWidth - 2*this.dSliderPad ...
                    this.dSliderThick], this.hPanel) ... 
            ); 
        
            %{
            this.hCenterText = uicontrol(...
                'Parent',this.hParent,...
                'Units','pixels',...
                'HorizontalAlignment','left',...
                'Position',[this.xpos ...
                    mic.Utils.uicontrolY(this.ypos,this.hParent,15) ...
                    40 ...
                    15 ...
                 ],...
                'String','Center',...
                'Style','text');
            
            this.hZoomText = uicontrol(...
                'Parent',this.hParent,...
                'Units','pixels',...
                'HorizontalAlignment','left',...
                'Position',[this.xpos ...
                    mic.Utils.uicontrolY(this.ypos+20,this.hParent,15) ...
                    40 ...
                    15 ...
                ],...
                'String','Zoom',...
                'Style','text');
            %}
                        
            
            lh2 = addlistener(this.hSliderXPan, 'ContinuousValueChange', @this.onSliderXPan);
            lh3 = addlistener(this.hSliderYPan, 'ContinuousValueChange', @this.onSliderYPan);
            lh1 = addlistener(this.hSliderZoom, 'ContinuousValueChange', @this.onSliderZoom);
            
            
            this.hHggroup = hggroup(...
                'Parent', this.hAxes, ...
                'ButtonDownFcn', @this.onGroupButtonDown ...
            );
            
            % set(this.hSliderZoom, 'Value', .99);
            set(this.hSliderZoom, 'Value', 1);
            this.onSliderZoom()
            set(this.hParent, 'WindowScrollWheelFcn', @this.onScrollWheel);
            
            set(this.hParent,'WindowButtonDownFcn', @this.onWindowButtonDown);
            set(this.hParent,'WindowButtonUpFcn', @this.onWindowButtonUp);
            set(this.hParent,'WindowButtonMotionFcn', @this.onWindowButtonMotion);
            % set(this.hParent,'WindowFocusLostFcn', @this.onWindowFocusLost);
            %set(this.hParent,'KeyPressFcn', @this.onKeyPress);
            %set(this.hParent,'KeyReleaseFcn', @this.onKeyRelease);
            %set(this.hParent,'ModeStartFcn', @this.onModeStart);
            %set(this.hParent,'ModeStopFcn', @this.onModeEnd);

            
        end
        
        
        function d = getVisibleSceneWidth(this)
            dXLim = get(this.hAxes, 'Xlim');
            d = dXLim(2) - dXLim(1);
        end
        
        function d = getVisibleSceneHeight(this)
            dYLim = get(this.hAxes, 'Ylim');
            d = dYLim(2) - dYLim(1);
        end
        
        function d = getVisibleSceneLeft(this)
            dXLim = get(this.hAxes, 'Xlim');
            d = dXLim(1);
            
        end
        
        function d = getVisibleSceneBottom(this)
            dYLim = get(this.hAxes, 'Ylim');
            d = dYLim(1);
        end
        
        function [dLeft, dBottom, dWidth, dHeight] = getVisibleSceneLBWH(this)
            
            dXLim = get(this.hAxes, 'Xlim');
            dYLim = get(this.hAxes, 'Ylim');
            
            dWidth = dXLim(2) - dXLim(1);
            dHeight = dYLim(2) - dYLim(1);
           
            dLeft = dXLim(1);
            dBottom = dYLim(1);
            
        end
                
        
        %% Destructor
        
        function delete(this)
            
            
        end
        
                               
        function show(this)
    
            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
            end
            
        end
        
        %{
        function this = set.hHggroup(this, h)
            
           % Clear the axes
           cla(this.hAxes, 'reset');
           
           % Set the parent of h to this 
           set(h, 'Parent', this.hAxes);
           
           this.hHggroup = h;
            
        end
        %}

        
        function d = getPanX(this)
            d = get(this.hSliderXPan, 'Value');
        end
        
        function d = getPanY(this)
            d = get(this.hSliderYPan, 'Value');
        end
        
        function d = getZoom(this)
            d = get(this.hSliderZoom, 'Value'); 
        end
                

    end
    
    methods (Access = private)
        
        function updateLimitsOnZoom(this)
            
            % Depending on the aspect ratio of the axes vs the aspect ratio
            % of the content you want to display within the axes, we do
            % different things for zoom:
            % 
            % When the aspect ratio of the axis (width/height) is > than
            % the aspect ratio of the content (the content is relatively 
            % taller) we do this :
            %
            %       At zoom 1, the x direction of the canvas fills the axis
            %       and there is canvas content hidden in the y direction
            %       above and below the axis limits
            %
            % When the aspect ratio of the axis is < the aspect ratio of
            % the content we do this (the content is relatively wider):
            % 
            %       At zoom 1, the y direction of the canvas fills the axis
            %       and there is canvas content hidden in the x direction to
            %       the left and right of the axis
            %
            % General notes:
            % 
            % As we zoom in, we change the viewed range by a factor 'zoom'.
            % The 'right amount of zoom' is simply achieved by setting the
            % xlim and ylim values to the canvas limits scaled by the zoom
            % value, and scaled by any aspect ratio factors as hinted at
            % above. However, this would always keep the geometric center
            % of the oMotorStage limits in the center of the axis - which
            % is not what we want to do.  We want to keep the current
            % center (pan) position as the center position while zooming.
            % So we first find the center position using the average of the
            % current limits in x and y and then shift the newly scaled
            % (zoomed) limits by the current center position.
        
            dVal = get(this.hSliderZoom, 'Value'); 
            
            dXLimits = get(this.hAxes, 'Xlim');
            dYLimits = get(this.hAxes, 'Ylim');
            
            dXCenter = (dXLimits(1) + dXLimits(2))/2;
            dYCenter = (dYLimits(1) + dYLimits(2))/2;
            
            %{
            this.msg(sprintf(...
                'xrange: %1.1f, yrange: %1.1f', ...
                this.dXRange, ...
                this.dYRange ...
            ));
            %}
            
            
            if (this.dAxesAR > this.dCanvasAR)
                                
                % At zoom 1, the x direction of the canvas fills the axis
                % and there is canvas content hidden in the y direction
                % above and below the axis limits
                
                % this.msg('this.dAxesAR > this.dCanvasAR');
                
                dXMin = dXCenter - this.dXRange/2/dVal;
                dXMax = dXCenter + this.dXRange/2/dVal;
                
                dYMin = dYCenter - this.dXRange/2/dVal/this.dAxesAR;
                dYMax = dYCenter + this.dXRange/2/dVal/this.dAxesAR;
                
                                
            else
                
                % At zoom 1, the y direction of the canvas fills the axis
                % and there is canvas content hidden in the x direction to
                % the left and right of the axis
                
                % this.msg('this.dAxesAR < this.dCanvasAR');
                
                dYMin = dYCenter - this.dYRange/2/dVal;
                dYMax = dYCenter + this.dYRange/2/dVal;
                
                dXMin = dXCenter - this.dYRange/2/dVal*this.dAxesAR;
                dXMax = dXCenter + this.dYRange/2/dVal*this.dAxesAR;
                
            end

            %{
            this.msg(sprintf('x: [%1.1f, %1.1f] y: [%1.1f, %1.1f]', ...
                dXMin, ...
                dXMax, ...
                dYMin, ...
                dYMax ...
            ));
            %}
                            
            
            % Enforce limit constraints to the min/max range in both
            % directions
            
            if (dXMin < this.dXMin)
                dXMin = this.dXMin;
                
                %this.msg('dXMin < this.dXMin');
                
                
                if (this.dAxesAR > this.dCanvasAR)
                    dXMax = this.dXMin + this.dXRange/dVal;
                else
                    dXMax = this.dXMin + this.dYRange/dVal*this.dAxesAR;
                end
                    
            end
            
            if (dXMax > this.dXMax)
                
                %this.msg('dXMax > this.dXMax');
                dXMax = this.dXMax;
                
                 if (this.dAxesAR > this.dCanvasAR)
                    dXMin = this.dXMax - this.dXRange/dVal;
                 else
                    dXMin = this.dXMax - this.dYRange/dVal*this.dAxesAR;
                 end
            end
            
            if (dYMin < this.dYMin)
                %this.msg('dYMin < this.dYMin');
                dYMin = this.dYMin;
                
                if (this.dAxesAR > this.dCanvasAR)
                    dYMax = this.dYMin + this.dXRange/dVal/this.dAxesAR;
                else
                    dYMax = this.dYMin + this.dYRange/dVal;
                end
                
            end
            
            if (dYMax > this.dYMax)
                %this.msg('dYMax > this.dYMax');
                dYMax = this.dYMax;
                
                if (this.dAxesAR > this.dCanvasAR)
                    dYMin = this.dYMax - this.dXRange/dVal/this.dAxesAR;
                else
                    dYMin = this.dYMax - this.dYRange/dVal;
                end
                
            end
            
            % Set the limits
            
            set(this.hAxes, 'Xlim', [dXMin dXMax]);
            set(this.hAxes, 'Ylim', [dYMin dYMax]);
            
            % If we zoom out and hit the stage limit, the center of the view will
            % be at a different location on the stage.  We will update the
            % value of the xpan slider to reflect this change.
            
            set(this.hSliderXPan, 'Value', (dXMin + dXMax)/2);
            set(this.hSliderYPan, 'Value', (dYMin + dYMax)/2);
            % this.dXPan = (dXMin + dXMax)/2;
            
            
            % 2014.05.16 I think the steps for the pan should be set so
            % that at every zoom level it takes 20 steps to pan the one
            % edge of the viewable canvas across the axis
            
            
            set(this.hSliderXPan, 'SliderStep', [this.dMinorStep/dVal this.dMajorStep/dVal]);
            set(this.hSliderYPan, 'SliderStep', [this.dMinorStep/dVal this.dMajorStep/dVal]);
             
            notify(this, 'eZoom');
        end
        
        function updateLimitsOnPanX(this)
            dVal = get(this.hSliderXPan, 'Value');
            
            % The pan slider has a value of lowCAL on the left and
            % increases linearly to a value of highCAL on the right. As we
            % pan, we want to keep the zoom level fixed.  This means we
            % need to make sure the xlim and ylim properties have the same
            % range (max-min) before and after the pan.
            
            
            dLimits = get(this.hAxes, 'Xlim');
            dRange = dLimits(2) - dLimits(1);
            
            % Set low and high limits based on pan value and range
            % (determined by zoom level)
            
            dLimMin = dVal - dRange/2;
            dLimMax = dVal + dRange/2;
            
                        
            % Check that xmin/xmax are within low/high stage limits
            
            if dLimMin < this.dXMin
                dLimMin = this.dXMin;
                dLimMax = dLimMin + dRange;
            end
            
            if dLimMax > this.dXMax
                dLimMax = this.dXMax;
                dLimMin = this.dXMax - dRange;
            end
            
            % Set axis limits
            
            set(this.hAxes, 'Xlim', [dLimMin dLimMax]);
            
            notify(this, 'ePanX');
              
        end
        
        function updateLimitsOnPanY(this)
            
            dVal = get(this.hSliderYPan, 'Value');
            
            % The pan slider has a value of lowCAL on the left and
            % increases linearly to a value of highCAL on the right. As we
            % pan, we want to keep the zoom level fixed.  This means we
            % need to make sure the xlim and ylim properties have the same
            % range (max-min) before and after the pan.
            
            dLimits = get(this.hAxes, 'Ylim');
            dRange = dLimits(2) - dLimits(1);
            
            % Set low and high limits based on pan value and range
            % (determined by zoom level)
            
            dLimMin = dVal - dRange/2;
            dLimMax = dVal + dRange/2;
            
                        
            % Check that xmin/xmax are within low/high stage limits
            
            if dLimMin < this.dYMin
                dLimMin = this.dYMin;
                dLimMax = dLimMin + dRange;
            end
            
            if dLimMax > this.dYMax
                dLimMax = this.dYMax;
                dLimMin = this.dYMax - dRange;
            end
            
            % Set axis limits
            
            set(this.hAxes, 'Ylim', [dLimMin dLimMax]);
            notify(this, 'ePanY');
        end
        
        function onSliderXPan(this, ~, ~)
            this.updateLimitsOnPanX()
        end
        
        function onSliderYPan(this, ~, ~)
            this.updateLimitsOnPanY()
        end
        
        function onSliderZoom(this, ~, ~)
            this.updateLimitsOnZoom()
        end        
                
        function init(this)
            
            this.dXRange = this.dXMax - this.dXMin;
            this.dYRange = this.dYMax - this.dYMin;
                        
            this.dAxesAR = this.dAxesWidth/this.dAxesHeight;
            this.dCanvasAR = this.dXRange/this.dYRange;

        end 
        
        %{
        set(this.hParent,'WindowButtonDownFcn', @this.onWindowButtonDown);
            set(this.hParent,'WindowButtonUpFcn', @this.onWindowButtonUp);
            set(this.hParent,'WindowButtonMotionFcn', @this.onWindowButtonMotion);
            set(this.hParent,'WindowFocusLostFcn', @this.onWindowFocusLost);
       %}     
            
        function onWindowButtonDown(this, src, evt)
            
            this.lDragging = true;
            
            % Get the scene position the mouse clicked
            
            % [this.dXDrag, this.dYDrag] = this.getScenePositionOfMouse();
             %{
            cMsg = sprintf(...
                'onWindowButtonDown clicked (%1.3f, %1.3f)', ...
                this.dXDrag, ...
                this.dYDrag ...
            );
            %}
        
            
            [this.dDragStartLeftRel, this.dDragStartBottomRel] = this.getRelativePositionOfMouse();
            [this.dDragStartLeft, this.dDragStartBottom, dWidth, dHeight] = this.getVisibleSceneLBWH();
           
            cMsg = sprintf(...
                'onWindowButtonDown clicked REL (%1.3f, %1.3f); left,bottom = (%1.3f, %1.3f)', ...
                this.dDragStartLeftRel, ...
                this.dDragStartBottomRel, ...
                this.dDragStartLeft, ...
                this.dDragStartBottom ...
            );
            this.msg(cMsg);
            
        end
        
        function onWindowButtonUp(this, src, evt)
            
            this.lDragging = false;
            this.msg('onWindowButtonUp');
            
        end
        
        
        
        function onWindowButtonMotion(this, src, evt)
            
            if ~this.lDragging
                return
            end
            
            % Adjust the left and bottom limit of the axes to keep
            % this.dXDrag and dYDrag under the mouse
            
            [dLeftRel, dBottomRel] = this.getRelativePositionOfMouse();
            [dLeft, dBottom, dWidth, dHeight] = this.getVisibleSceneLBWH();
            
            % x1 = left1 + width * leftRel1 
            % x2 = left2 + width * leftRel2
            %
            % Set x2 = x1
            %
            % left1 + width * leftRel1 = left2 + width * leftRel2
            % left1 + width * (leftRel1 - leftRel2) = left2
            
            
            dLeft2 = this.dDragStartLeft + dWidth * (this.dDragStartLeftRel - dLeftRel);
            dBottom2 = this.dDragStartBottom + dHeight * (this.dDragStartBottomRel - dBottomRel);
            
            % cMsg = sprintf('L_before %1.3f, L_after % 1.3f', this.dDragStartLeft, dLeft2);
            % this.msg(cMsg);
            
            dXPan = dLeft2 + dWidth / 2;
            dYPan = dBottom2 + dHeight / 2;
            
            set(this.hSliderXPan, 'Value', dXPan);
            set(this.hSliderYPan, 'Value', dYPan);

            this.updateLimitsOnPanX();
            this.updateLimitsOnPanY();
            
            % this.msg('onWindowButtonMotion');
            
        end
        
        function onWindowFocusLost(this, src, evt)
            this.msg('onWindowFocusLost');
            
        end
        
        function onGroupButtonDown(this, src, evt)
            
            this.msg('.onGroupButtonDown()');
            
            
        end
        
        function onAxesButtonDown(this, src, evt)
            
            % 2017.03.09 Right now this only fires when the user clicks on
            % the background, i.e., not on a patch feature that has been drawn
            
            this.msg('.onAxesButtonDown()');
            
            % Update crosshair
            
            % dCursor = get(this.hFigure, 'CurrentPoint')     % [left bottom]
            dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
            dPanel = get(this.hPanel, 'Position');
            
            notify(this,'eClick');

        end
        
        function onPanelButtonDown(this, src, evt)
            
            % 2017.03.09 Right now this only fires when the user clicks on
            % the background, i.e., not on a patch feature that has been drawn
            
            this.msg('onPanelButtonDown()');
            
            % Update crosshair
            
            % dCursor = get(this.hFigure, 'CurrentPoint')     % [left bottom]
            dAxes = get(this.hAxes, 'Position');             % [left bottom width height]
            dPanel = get(this.hPanel, 'Position');
            
            notify(this,'eClick');

        end
        
        % Get fractional position of mouse cursor relative to position
        % of the bounding panel
        
        function [dLeftRel, dBottomRel] = getRelativePositionOfMouse(this)
             
            % [left bottom] location of cursor in parent figure.  
            % Will need to check if the cursor is inside this axes
            dCursor = get(this.hParent, 'CurrentPoint');
            
            % {double 1x1} dLeft mouse position relative to left side of
            % the parent figure (pixels)
            dLeft = dCursor(1);
            
            % {double 1x1} dBottom mouse position relative to bottom of
            % the parent figure (pixels)
            dBottom = dCursor(2);
            
            dPanelPos = get(this.hPanel, 'Position');
            dPanelLeft =      dPanelPos(1);
            dPanelBottom =    dPanelPos(2);
            dPanelWidth =     dPanelPos(3);
            dPanelHeight =    dPanelPos(4);
                    
            % Fractional position how far mouse is from left bottom of the
            % panel.  (1,1) is all the way in the top right corner. 
            
            dLeftRel = (dLeft - dPanelLeft) / dPanelWidth;
            dBottomRel = (dBottom - dPanelBottom) / dPanelHeight;
            
            %{
            cMsg = sprintf('panel (L,B) (%1.0f,%1.0f), mouse (%1.0f,%1.0f) rel (%1.3f, %1.3f)', ...
                dPanelLeft, ...
                dPanelBottom, ...
                dLeft, ...
                dBottom, ...
                dLeftRel, ...
                dBottomRel ...
            );
            
            this.msg(cMsg);
            %}
            
        end
        
        function [dX, dY] = getScenePositionOfMouse(this)
            
            [dLeftRel, dBottomRel] = this.getRelativePositionOfMouse();
            
            dXLim = get(this.hAxes, 'Xlim');
            dYLim = get(this.hAxes, 'Ylim');
            
            dWidth = dXLim(2) - dXLim(1);
            dHeight = dYLim(2) - dYLim(1);
           
            dLeft = dXLim(1);
            dBottom = dYLim(1);
            
            dX = dLeft + dWidth * dLeftRel;
            dY = dBottom + dHeight * dBottomRel;
            
        end
        
        
        
       
        function onScrollWheel(this, src, evt)
            
           % this.msg(num2str(evt.VerticalScrollCount));
            
           % Store x and y limits before zoom for later
           
           dXLim1 = get(this.hAxes, 'Xlim');
           dYLim1 = get(this.hAxes, 'Ylim');
            
           dWidth1 = dXLim1(2) - dXLim1(1);
           dHeight1 = dYLim1(2) - dYLim1(1);
           
           dLeft1 = dXLim1(1);
           dBottom1 = dYLim1(1);
            
           % Increase/decrease zoom by a constant raised to the power
           % VerticalScrollCount
           % scale factor
           
           dMult = 1.08^(-evt.VerticalScrollCount);
           dZoom1 = this.getZoom();
           dZoom2 = dZoom1 * dMult;
           
           if dZoom2 < 1
               return
           end
           
           if dZoom2 > this.dZoomMax
               return
           end
           
           % this.msg(sprintf('zoom (before) %1.2f', dZoom1));
           % this.msg(sprintf('zoom (after) %1.2f', dZoom2));
           
           if (dZoom2 < this.dZoomMin)
               dZoom2 = this.dZoomMin;
           end
           
           if (dZoom2 > this.dZoomMax)
               dZoom2 = this.dZoomMax;
           end
           
           
           set(this.hSliderZoom, 'Value', dZoom2);
           this.updateLimitsOnZoom();
           
            
            % 2 2017.03.09
            % Now want the scene coordinate under the mouse to stay under
            % the mouse during zoom (like Google Maps).  This requires
            % adjusting pan x and pan y during the zoom.  
                       
            [dLeftRel, dBottomRel] = this.getRelativePositionOfMouse();

            
            % Use fractional position and limits to compute the scene
            % coordinate that the mouse is over.  
            % dXMin <= x <= dXMax
            % dYMin <= x <= dYMax
                        
            dX = dLeft1 + dWidth1 * dLeftRel;
            dY = dBottom1 + dHeight1 * dBottomRel;
            
            % After zooming, we need to satisfy the above equations again.
            %
            % Since the mouse does not move:
            % dLeftRel stays constant 
            % dBottomRel stays constnat
            %
            % Additionally, we want the scene coordinate under the mouse 
            % to stay the same before and after.  This
            % lets us solve for a new lower x lim and lower y lim
            
            % x1 = xLeft1 + width1 * rel (before)
            % x2 = xLeft2 + width2 * rel (after)
           
            
            % Set: x1 = x2 
            % Set: width2 = width1 / relzoom
            % (positive zoom causes that the width to shrink by the zoom
            % factor)
            
            
            % Solution
            %
            % (before)              = (after)
            % xLeft1 + width1 * rel = xLeft2 + (width1 / relzoom) * rel
            % xLeft1 + width1 * rel * (1 - 1/relzoom) = xLeft2
            
            % Now solve for pan
            %
            % Pan = xLeft2 + width2 / 2
            % Pan = xLeft2 + width1 / relzoom / 2
                       
            % Update the value of the pan 
             
            dLeft2 = dLeft1 + dWidth1 * dLeftRel * ( 1 - 1/dMult);
            dBottom2 = dBottom1 + dHeight1 * dBottomRel * (1 - 1/dMult);

            dXPan2 = dLeft2 + dWidth1 / dMult / 2;
            dYPan2 = dBottom2 + dHeight1 / dMult / 2;

            set(this.hSliderXPan, 'Value', dXPan2);
            set(this.hSliderYPan, 'Value', dYPan2);

            this.updateLimitsOnPanX();
            this.updateLimitsOnPanY();
          
                       
        end

    end % private
    
    
end