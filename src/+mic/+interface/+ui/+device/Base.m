classdef  Base < mic.Base
    
    
    methods (Abstract)
    
        % Build the UI on a figure or uipanel. 
        % mic.ui.common.* elements can be built in multiple places
        % @param {handle 1x1} hParent - handle of panel or figure where UI
        % control is to be drawn
        % @param {double 1x1} dOffsetLeft - pixels from left side of
        % hParent to left edge of UI control
        % @param {double 1x1} dOffsetTop - pixels from top of hParent to
        % top of UI control. 
        build(this, hParent, dOffsetLeft, dOffsetTop)
        
        % Route device calls through real device.  Same as user toggling
        % "Device" on
        turnOn(this)
        
        % Route device calls through virtual device.  Same as user toggling
        % "Device" off (default)
        turnOff(this)
        
        % @param {< mic.interface.device.* 1x1} device 
        setDevice(this, device)
        
        % @param {< mic.interface.device.* 1x1} device 
        setDeviceVirtual(this, device)
        
        % @return  {< mic.interface.device.* 1x1} device.  Returns the 
        % real or virtual device based on the state of the "Device" toggle
        device = getDevice(this)
        
        % Call .initialize() method on active device
        initialize(this)
        
        % Call enable() on all children mic.ui.common.*
        enable(this)
        
        % Call disable() on all children mic.ui.common.*
        disable(this)
        
        %{
        % Get the width of the UI control.  It changes based on which
        % features are shown / hidden
        d = getWidth(this)
        %}
        
    end
    
end


